import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import JWT
import SQLKit

public func configure(_ app: Application) async throws {

    print("===== [BOOT] Vapor starting... =====")

    // MARK: - PORT (Cloudtype 요구)
    if let port = Environment.get("PORT").flatMap(Int.init) {
        print("[INFO] PORT from ENV =", port)
        app.http.server.configuration.port = port
    }

    app.http.server.configuration.hostname = "0.0.0.0"

    // MARK: - ENV DEBUG
    print("===== [ENV CHECK] =====")
    let envVars = [
        "DATABASE_HOST", "DATABASE_PORT",
        "DATABASE_USERNAME", "DATABASE_PASSWORD",
        "DATABASE_NAME", "JWT_SECRET"
    ]
    for key in envVars {
        print("[ENV]", key, "=", Environment.get(key) ?? "NIL")
    }

    // MARK: - DB 설정
    guard
        let host = Environment.get("DATABASE_HOST"),
        let port = Environment.get("DATABASE_PORT").flatMap(Int.init),
        let user = Environment.get("DATABASE_USERNAME"),
        let password = Environment.get("DATABASE_PASSWORD"),
        let dbname = Environment.get("DATABASE_NAME")
    else {
        print("[ERROR] DB ENV missing, server still booting without DB")
        // DB 없으면 서버는 부팅, 나중에 요청 시 실패
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
    // 🔹 DB Ping 테스트
    Task {
        do {
            try await sql.raw("SELECT 1").run()
            print("[DB] Connection OK!")
        } catch {
            print("[DB ERROR] Connection failed:", error.localizedDescription)
        }
    }

    // MARK: - JWT 설정
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

    // MARK: - Repository / Service
    let userRepo = MySQLUserRepository(db: sql)
    let refreshRepo = MySQLRefreshTokenRepository(db: sql)
    let reviewRepo = MySQLReviewRepository(database: sql)

    app.storage[UserRepositoryKey.self] = userRepo
    app.storage[RefreshTokenRepositoryKey.self] = refreshRepo
    app.storage[ReviewRepositoryKey.self] = reviewRepo

    let authService = MyAuthService(users: userRepo, refreshTokens: refreshRepo)
    let reviewService = DefaultReviewService(repo: reviewRepo)

    app.storage[AuthServiceKey.self] = authService
    app.storage[ReviewServiceKey.self] = reviewService

    // MARK: - Health Check
    app.get("health") { _ in
        return "OK"
    }

    // MARK: - Controller 등록
    try app.register(collection: AuthController(authService: authService, users: userRepo))
    try app.register(collection: ReviewController(service: reviewService))

    try routes(app)

    print("===== [BOOT COMPLETE] Vapor running =====")
}

func generateJWTSecret() -> String {
    var bytes = [UInt8](repeating: 0, count: 32)
    let fd = fopen("/dev/urandom", "rb")!
    fread(&bytes, 1, bytes.count, fd)
    fclose(fd)
    return Data(bytes).base64EncodedString()
}
