//
//  MySQLRefreshTokenRepository.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//


import SQLKit
import Foundation

struct MySQLRefreshTokenRepository: RefreshTokenRepository {
    let db: any SQLDatabase

    func create(userId: Int, token: String, expiresAt: Date) async throws {
        try await db.raw("""
            INSERT INTO refresh_tokens (user_id, token, expires_at)
            VALUES (\(bind: userId), \(bind: token), \(bind: expiresAt))
            """)
            .run()
    }

    func delete(_ token: String) async throws {
        try await db.raw("""
            DELETE FROM refresh_tokens
            WHERE token = \(bind: token)
            """)
            .run()
    }

    func deleteAll(for userId: Int) async throws {
        try await db.raw("""
            DELETE FROM refresh_tokens
            WHERE user_id = \(bind: userId)
            """)
            .run()
    }

    func find(_ token: String) async throws -> RefreshToken? {
        let rows = try await db.raw("""
            SELECT id, user_id, token, expires_at, created_at, updated_at
            FROM refresh_tokens
            WHERE token = \(bind: token)
            LIMIT 1
            """)
            .all()

        guard let row = rows.first else { return nil }

        return RefreshToken(
            id: try row.decode(column: "id", as: Int.self),
            userId: try row.decode(column: "user_id", as: Int.self),
            token: try row.decode(column: "token", as: String.self),
            expiresAt: try row.decode(column: "expires_at", as: Date.self),
            createdAt: try row.decode(column: "created_at", as: Date?.self),
            updatedAt: try row.decode(column: "updated_at", as: Date?.self)
        )
    }
}
