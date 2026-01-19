//  configure.swift
//  iOS5Team1
//
//  서버(Vapor) 부팅 시 최초 한 번 실행되는 설정 파일입니다.
//  포트/호스트, 데이터베이스, JWT, 의존성 주입(Repo/Service), 라우트 등록을 수행합니다.
//
//  초보자 가이드
//  - Environment.get: 서버 실행 환경변수에서 값을 읽습니다(예: DB 비밀번호).
//  - app.databases.use: DB 연결 정보를 Vapor에 등록합니다.
//  - app.jwt.keys.add: JWT(토큰) 서명/검증에 사용할 키를 등록합니다.
//  - app.storage: 전역에서 꺼내 쓸 수 있는 의존성 저장소입니다.

import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import JWT
import SQLKit

public func configure(_ app: Application) async throws {

    print("===== [BOOT] Vapor starting... =====")

    if let port = Environment.get("PORT").flatMap(Int.init) {
        print("[INFO] PORT from ENV =", port)
        app.http.server.configuration.port = port
    }
    app.http.server.configuration.hostname = "0.0.0.0"

    print("===== [ENV CHECK] =====")
    let envVars = [
        "DATABASE_HOST", "DATABASE_PORT",
        "DATABASE_USERNAME", "DATABASE_PASSWORD",
        "DATABASE_NAME", "JWT_SECRET",
        "IGDB_CLIENT_ID", "IGDB_CLIENT_SECRET",
        "FIREBASE_API_KEY", "FIREBASE_APP_ID",
        "FIREBASE_GCM_SENDER_ID", "FIREBASE_PROJECT_ID",
        "FIREBASE_STORAGE_BUCKET", "FIREBASE_CLIENT_ID"
    ]
    for key in envVars {
        print("[ENV]", key, "=", Environment.get(key) ?? "NIL")
    }

    guard
        let host = Environment.get("DATABASE_HOST"),
        let port = Environment.get("DATABASE_PORT").flatMap(Int.init),
        let user = Environment.get("DATABASE_USERNAME"),
        let password = Environment.get("DATABASE_PASSWORD"),
        let dbname = Environment.get("DATABASE_NAME")
    else {
        print("[ERROR] DB ENV missing, server still booting without DB")
        try routes(app)
        return
    }

    print("[DB] Connecting → \(host):\(port) db=\(dbname) user=\(user)")

    app.databases.use(.mysql(
        hostname: host,
        port: port,
        username: user,
        password: password,
        database: dbname,
        tlsConfiguration: .none
    ), as: .mysql)

    let sql = app.db(.mysql) as! (any SQLDatabase)
    Task {
        do {
            try await sql.raw("SELECT 1").run()
            print("[DB] Connection OK!")
        } catch {
            print("[DB ERROR] Connection failed:", error.localizedDescription)
        }
    }

    let rawSecret = Environment.get("JWT_SECRET") ?? ""
    if rawSecret.isEmpty {
        print("[WARN] JWT_SECRET not set, using random secret")
    }

    if let data = Data(base64Encoded: rawSecret) {
        let key = HMACKey(from: data)
        await app.jwt.keys.add(hmac: key, digestAlgorithm: .sha256)
        print("[JWT] Loaded base64 secret")
    } else {
        print("[WARN] JWT secret invalid base64, generating temporary")
        let generated = generateJWTSecret()
        let key = HMACKey(from: Data(base64Encoded: generated)!)
        await app.jwt.keys.add(hmac: key, digestAlgorithm: .sha256)
    }

    let userRepo = MySQLUserRepository(db: sql)
    let refreshRepo = MySQLRefreshTokenRepository(db: sql)
    let reviewRepo = MySQLReviewRepository(db: sql)

    app.storage[UserRepositoryKey.self] = userRepo
    app.storage[RefreshTokenRepositoryKey.self] = refreshRepo
    app.storage[ReviewRepositoryKey.self] = reviewRepo

    let authService = MyAuthService(users: userRepo, refreshTokens: refreshRepo)
    let reviewService = DefaultReviewService(repo: reviewRepo)
    let igdbService = IGDBService(
        clientId: Environment.get("IGDB_CLIENT_ID") ?? "",
        clientSecret: Environment.get("IGDB_CLIENT_SECRET") ?? ""
    )

    app.storage[AuthServiceKey.self] = authService
    app.storage[ReviewServiceKey.self] = reviewService
    app.storage[IGDBServiceKey.self] = igdbService

    guard
        let apiKey = Environment.get("FIREBASE_API_KEY"),
        let appId = Environment.get("FIREBASE_APP_ID"),
        let gcmSenderId = Environment.get("FIREBASE_GCM_SENDER_ID"),
        let projectId = Environment.get("FIREBASE_PROJECT_ID"),
        let clientId = Environment.get("FIREBASE_CLIENT_ID")
    else {
        throw Abort(.internalServerError, reason: "Missing required Firebase ENV variables")
    }

    app.storage[FirebaseConfigKey.self] = FirebaseConfig(
        apiKey: apiKey,
        appId: appId,
        gcmSenderId: gcmSenderId,
        projectId: projectId,
        storageBucket: Environment.get("FIREBASE_STORAGE_BUCKET"),
        clientId: clientId
    )

    // 🔹 여기 수정됨: Google JWKS + expectedAud(Firebase ClientID)
    let googleJWKS = GoogleJWKSManager(client: app.client)

    let socialAuthService = SocialAuthService(
        users: userRepo,
        refreshTokens: refreshRepo,
        authService: authService,
        providers: [
            .google: GoogleAuthProvider(
                jwks: googleJWKS,
                expectedAud: clientId // Firebase ClientID = Google Sign-In aud
            )
        ]
    )

    app.storage[SocialAuthServiceKey.self] = socialAuthService

    app.get("health") { _ in "OK" }

    try app.register(collection: AuthController(
        authService: authService,
        users: userRepo,
        socialAuthService: socialAuthService
    ))
    try app.register(collection: ReviewController(service: reviewService))

    try routes(app)
    print("===== [BOOT COMPLETE] Vapor running =====")
}


/// JWT 서명용 랜덤 시크릿을 생성합니다.
/// 개발 환경에서만 사용을 권장합니다.
func generateJWTSecret() -> String {
    var bytes = [UInt8](repeating: 0, count: 32)
    let fd = fopen("/dev/urandom", "rb")!
    fread(&bytes, 1, bytes.count, fd)
    fclose(fd)
    return Data(bytes).base64EncodedString()
}

extension Application {
    var googleOAuth: GoogleOAuthConfig {
        let clientId = Environment.get("GOOGLE_OAUTH_CLIENT_ID")
        let clientSecret = Environment.get("GOOGLE_OAUTH_CLIENT_SECRET")
        let redirectURI = Environment.get("GOOGLE_OAUTH_REDIRECT_URI")

        if clientId == nil || clientSecret == nil || redirectURI == nil {
            // 경고: 필수 ENV 누락. 개발 환경에서는 부팅을 계속하고 런타임에서 처리합니다.
            print("[WARN] Missing Google OAuth ENV. Check GOOGLE_OAUTH_CLIENT_ID/SECRET/REDIRECT_URI")
        }

        return GoogleOAuthConfig(
            clientId: clientId ?? "",
            clientSecret: clientSecret ?? "",
            redirectURI: redirectURI ?? ""
        )
    }
}
