import NIOSSL
import Fluent
import FluentMySQLDriver
import Vapor
import JWT
import SQLKit

public func configure(_ app: Application) async throws {

    // MARK: - PORT (Cloudtype 요구)
    if let port = Environment.get("PORT").flatMap(Int.init) {
        app.http.server.configuration.port = port
    }

    // MARK: - DB
    guard
       let host = Environment.get("DATABASE_HOST"),
       let port = Environment.get("DATABASE_PORT").flatMap(Int.init),
       let user = Environment.get("DATABASE_USERNAME"),
       let password = Environment.get("DATABASE_PASSWORD"),
       let dbname = Environment.get("DATABASE_NAME")
    else {
       fatalError("DB environment variables missing")
    }

    app.databases.use(.mysql(
       hostname: host,
       port: port,
       username: user,
       password: password,
       database: dbname,
       tlsConfiguration: .none
    ), as: .mysql)


    // MARK: - JWT 설정
    // MARK: - JWT
    #if DEBUG
        // allow flexible for local
        let secret = Environment.get("JWT_SECRET") ?? generateJWTSecret()
    #else
        guard let secret = Environment.get("JWT_SECRET") else {
            fatalError("JWT_SECRET required in production")
        }
    #endif

    guard let data = Data(base64Encoded: secret) else {
        fatalError("JWT_SECRET must be base64 encoded")
    }
    let key = HMACKey(from: data)
    await app.jwt.keys.add(hmac: key, digestAlgorithm: .sha256)

    // MARK: - Repository 등록
    let sql = app.db(.mysql) as! (any SQLDatabase)

    let userRepo = MySQLUserRepository(db: sql)
    let refreshRepo = MySQLRefreshTokenRepository(db: sql)
    let reviewRepo = MySQLReviewRepository(database: sql)

    app.storage[UserRepositoryKey.self] = userRepo
    app.storage[RefreshTokenRepositoryKey.self] = refreshRepo
    app.storage[ReviewRepositoryKey.self] = reviewRepo

    // MARK: - Service 등록
    let authService = MyAuthService(users: userRepo, refreshTokens: refreshRepo)
    let reviewService = DefaultReviewService(repo: reviewRepo)

    app.storage[AuthServiceKey.self] = authService
    app.storage[ReviewServiceKey.self] = reviewService

    // MARK: - Controller 등록
    try app.register(collection: AuthController(authService: authService, users: userRepo))
    try app.register(collection: ReviewController(service: reviewService))
}


func generateJWTSecret() -> String {
    var bytes = [UInt8](repeating: 0, count: 32)
    let fd = fopen("/dev/urandom", "rb")!
    fread(&bytes, 1, bytes.count, fd)
    fclose(fd)
    return Data(bytes).base64EncodedString()
}
