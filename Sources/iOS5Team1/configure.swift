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

    // MARK: - PORT (Cloudtype 요구)
    // 호스팅 환경에서 지정하는 포트를 읽어 서버에 적용합니다.
    if let port = Environment.get("PORT").flatMap(Int.init) {
        print("[INFO] PORT from ENV =", port)
        app.http.server.configuration.port = port
    }

    // 모든 인터페이스에서 요청을 받을 수 있도록 호스트 설정
    app.http.server.configuration.hostname = "0.0.0.0"

    // MARK: - ENV DEBUG
    // 디버깅을 위해 필요한 환경 변수들을 출력합니다.
    print("===== [ENV CHECK] =====")
    let envVars = [
        "DATABASE_HOST", "DATABASE_PORT",
        "DATABASE_USERNAME", "DATABASE_PASSWORD",
        "DATABASE_NAME", "JWT_SECRET",
        "IGDB_CLIENT_ID", "IGDB_CLIENT_SECRET",
        "FIREBASE_API_KEY"
    ]
    for key in envVars {
        print("[ENV]", key, "=", Environment.get(key) ?? "NIL")
    }

    // MARK: - DB 설정
    // 필수 DB 환경 변수들이 없으면 DB 없이 부팅하고, 라우트만 등록합니다.
    guard
        let host = Environment.get("DATABASE_HOST"),
        let port = Environment.get("DATABASE_PORT").flatMap(Int.init),
        let user = Environment.get("DATABASE_USERNAME"),
        let password = Environment.get("DATABASE_PASSWORD"),
        let dbname = Environment.get("DATABASE_NAME")
    else {
        print("[ERROR] DB ENV missing, server still booting without DB")
        // DB 없으면 서버는 부팅, 나중에 요청 시 실패할 수 있습니다.
        try routes(app)
        return
    }

    print("[DB] Connecting → \(host):\(port) db=\(dbname) user=\(user)")

    // MySQL 데이터베이스 연결 구성
    app.databases.use(.mysql(
        hostname: host,
        port: port,
        username: user,
        password: password,
        database: dbname,
        tlsConfiguration: .none
    ), as: .mysql)

    let sql = app.db(.mysql) as! (any SQLDatabase)
    // 🔹 DB Ping 테스트: 연결이 유효한지 간단히 확인
    Task {
        do {
            try await sql.raw("SELECT 1").run()
            print("[DB] Connection OK!")
        } catch {
            print("[DB ERROR] Connection failed:", error.localizedDescription)
        }
    }

    // MARK: - JWT 설정
    // JWT 서명에 사용할 시크릿을 Base64로 읽어 키를 등록합니다.
    let rawSecret = Environment.get("JWT_SECRET") ?? ""
    if rawSecret.isEmpty {
        print("[WARN] JWT_SECRET not set, using random secret")
    }

    if let data = Data(base64Encoded: rawSecret) {
        let key = HMACKey(from: data)
        await app.jwt.keys.add(hmac: key, digestAlgorithm: .sha256)
        print("[JWT] Loaded base64 secret")
    } else {
        // 잘못된 시크릿이면 임시로 생성하여 부팅합니다(개발용 권장).
        print("[WARN] JWT secret invalid base64, generating temporary")
        let generated = generateJWTSecret()
        let key = HMACKey(from: Data(base64Encoded: generated)!)
        await app.jwt.keys.add(hmac: key, digestAlgorithm: .sha256)
    }

    // MARK: - Repository / Service 의존성 주입
    let userRepo = MySQLUserRepository(db: sql)
    let refreshRepo = MySQLRefreshTokenRepository(db: sql)
    let reviewRepo = MySQLReviewRepository(database: sql)

    app.storage[UserRepositoryKey.self] = userRepo
    app.storage[RefreshTokenRepositoryKey.self] = refreshRepo
    app.storage[ReviewRepositoryKey.self] = reviewRepo

    let authService = MyAuthService(users: userRepo, refreshTokens: refreshRepo)
    let reviewService = DefaultReviewService(repo: reviewRepo)
    let igdbService = IGDBService(
        clientId: Environment.get("IGDB_CLIENT_ID") ?? "",
        clientSecret: Environment.get("IGDB_CLIENT_SECRET") ?? ""
    )
    let firebaseApiKey = Environment.get("FIREBASE_API_KEY") ?? ""

    app.storage[AuthServiceKey.self] = authService
    app.storage[ReviewServiceKey.self] = reviewService
    app.storage[IGDBServiceKey.self] = igdbService
    app.storage[FirebaseAPIKey.self] = firebaseApiKey

    // MARK: - Health Check (중복이지만 예시로 유지)
    app.get("health") { _ in
        return "OK"
    }

    // MARK: - Controller 등록 및 라우트 연결
    try app.register(collection: AuthController(authService: authService, users: userRepo))
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
