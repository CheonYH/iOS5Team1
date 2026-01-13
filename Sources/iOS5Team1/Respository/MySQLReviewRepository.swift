//
//  MySQLReviewRepository.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

//
//  MySQLReviewRepository.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor
import SQLKit
import MySQLKit

struct MySQLReviewRepository: ReviewRepository {

    let database: any SQLDatabase

    func create(userId: Int, gameId: Int, rating: Int, content: String) async throws -> Int {
        do {
            try await database.raw("""
                INSERT INTO reviews (user_id, game_id, rating, content)
                VALUES (\(bind: userId), \(bind: gameId), \(bind: rating), \(bind: content))
            """).run()

            let row = try await database.raw("SELECT LAST_INSERT_ID() AS id").first()
            let id = try row?.decode(column: "id", as: Int.self) ?? 0
            return id

        } catch let mysqlError as MySQLError {
            let desc = mysqlError.errorDescription?.lowercased() ?? ""

            if desc.contains("duplicate") || desc.contains("1062") {
                throw Abort(.conflict, reason: "이미 이 게임에 리뷰를 작성했습니다.")
            }

            throw mysqlError
        } catch {
            throw error
        }
    }

    func update(id: Int, userId: Int, rating: Int, content: String) async throws {
        try await database.raw("""
            UPDATE reviews
            SET rating = \(bind: rating),
                content = \(bind: content),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = \(bind: id)
              AND user_id = \(bind: userId)
        """).run()
    }

    func delete(id: Int, userId: Int) async throws {
        try await database.raw("""
            DELETE FROM reviews
            WHERE id = \(bind: id)
              AND user_id = \(bind: userId)
        """).run()
    }

    func fetchByGame(gameId: Int) async throws -> [ReviewResponse] {
        let rows = try await database.raw("""
            SELECT id, user_id, game_id, rating, content, created_at
            FROM reviews
            WHERE game_id = \(bind: gameId)
            ORDER BY created_at DESC
        """).all()

        return try rows.map {
            try ReviewResponse(
                id: $0.decode(column: "id", as: Int.self),
                userId: $0.decode(column: "user_id", as: Int.self),
                gameId: $0.decode(column: "game_id", as: Int.self),
                rating: $0.decode(column: "rating", as: Int.self),
                content: $0.decode(column: "content", as: String.self),
                createdAt: $0.decode(column: "created_at", as: Date.self),
                updatedAt: $0.decode(column: "updated_at", as: Date.self)
            )
        }
    }

    func fetchByUser(userId: Int) async throws -> [ReviewResponse] {
        let rows = try await database.raw("""
            SELECT id, user_id, game_id, rating, content, created_at
            FROM reviews
            WHERE user_id = \(bind: userId)
            ORDER BY created_at DESC
        """).all()

        return try rows.map {
            try ReviewResponse(
                id: $0.decode(column: "id", as: Int.self),
                userId: $0.decode(column: "user_id", as: Int.self),
                gameId: $0.decode(column: "game_id", as: Int.self),
                rating: $0.decode(column: "rating", as: Int.self),
                content: $0.decode(column: "content", as: String.self),
                createdAt: $0.decode(column: "created_at", as: Date.self),
                updatedAt: $0.decode(column: "updated_at", as: Date.self)
            )
        }
    }

    func fetchStats(gameId: Int) async throws -> ReviewStatsResponse {
        guard let row = try await database.raw("""
            SELECT AVG(rating) AS avg, COUNT(*) AS cnt
            FROM reviews
            WHERE game_id = \(bind: gameId)
        """).first()
        else {
            return .init(gameId: gameId, averageRating: 0.0, reviewCount: 0)
        }

        let avg = try row.decode(column: "avg", as: Double?.self) ?? 0.0
        let count = try row.decode(column: "cnt", as: Int?.self) ?? 0

        return .init(gameId: gameId, averageRating: avg, reviewCount: count)
    }


    func fetchByGame(gameId: Int, sort: ReviewSort) async throws -> [ReviewResponse] {
        let sql: SQLQueryString

        switch sort {
        case .latest:
            sql = """
                SELECT id, user_id, game_id, rating, content, created_at, updated_at
                FROM reviews
                WHERE game_id = \(bind: gameId)
                ORDER BY created_at DESC
            """
            case .highest:
                sql = """
                    SELECT id, user_id, game_id, rating, content, created_at, updated_at
                    FROM reviews
                    WHERE game_id = \(bind: gameId)
                    ORDER BY rating DESC, created_at DESC
                """
            case .lowest:
                sql = """
                    SELECT id, user_id, game_id, rating, content, created_at, updated_at
                    FROM reviews
                    WHERE game_id = \(bind: gameId)
                    ORDER BY rating ASC, created_at DESC
                """
        }

        return try await database.raw(sql).all(decoding: ReviewResponse.self)
    }
}


