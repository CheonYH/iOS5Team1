import Fluent
import FluentMySQLDriver
import MySQLKit
import SQLKit
import Vapor


func routes(_ app: Application) throws {

    // Auth Dependencies
    guard let authService = app.storage[AuthServiceKey.self] else {
        fatalError("AuthService not registered")
    }
    guard let users = app.storage[UserRepositoryKey.self] else {
        fatalError("UserRepository not registered")
    }

    let authController = AuthController(authService: authService, users: users)
    try app.register(collection: authController)

    // Review Dependencies
    guard let reviewService = app.storage[ReviewServiceKey.self] else {
        fatalError("ReviewService not registered")
    }

    let reviewController = ReviewController(service: reviewService)
    try app.register(collection: reviewController)
}


