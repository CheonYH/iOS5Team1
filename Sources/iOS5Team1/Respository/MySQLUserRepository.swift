//
//  MySQLUserRepository.swift
//  iOS5Team1
//
//  Created by cheon on 1/10/26.
//

import Foundation
import SQLKit

actor MySQLUserRepository: UserRepository {

    let db: any SQLDatabase

    func findByEmail(_ email: String) async throws -> User? {
        let rows = try await db.raw("""
            SELECT id, email, password, nickname, created_at, updated_at
            FROM users
            WHERE email = \(bind: email)
            LIMIT 1
            """)
            .all()

        guard let row = rows.first else { return nil }

        return User(
            id: try row.decode(column: "id", as: Int.self),
            email: try row.decode(column: "email", as: String.self),
            password: try row.decode(column: "password", as: String.self),
            nickname: try row.decode(column: "nickname", as: String.self),
            createdAt: try row.decode(column: "created_at", as: Date?.self),
            updatedAt: try row.decode(column: "updated_at", as: Date?.self)
        )
    }

    func exists(email: String) async throws -> Bool {
        let rows = try await db.raw("""
            SELECT EXISTS(SELECT 1 FROM users WHERE email = \(bind: email)) AS exists
            """).all()

        guard let row = rows.first else {
            throw RepositoryError.queryFailed
        }

        return try row.decode(column: "exists", as: Bool.self)
    }

    func create(email: String, password: String, nickname: String) async throws -> User {
        try await db.raw("""
            INSERT INTO users (email, password, nickname)
            VALUES (\(bind: email), \(bind: password), \(bind: nickname))
            """)
        .run()

        // 방금 생성한 유저 다시 조회
        guard let user = try await findByEmail(email) else {
            throw RepositoryError.insertFailed
        }

        return user
    }

    init(db: any SQLDatabase) {
        self.db = db
    }
}


