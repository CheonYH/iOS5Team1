//  MySQLReviewRepository.swift
//  iOS5Team1
//
//  리뷰 데이터를 MySQL 데이터베이스에서 CRUD(생성/조회/수정/삭제)하고,
//  게임별 정렬/통계를 제공하는 리포지토리입니다.
//
//  초보자 가이드
//  - SQL 바인딩: \(bind: 값) 표기로 SQL 인젝션을 예방합니다.
//  - MySQLError: MySQL에서 발생한 오류를 잡아 사용자 친화적인 메시지로 변환할 수 있습니다.

import Vapor
import SQLKit
import MySQLKit

struct MySQLReviewRepository: ReviewRepository {

    let db: any SQLDatabase

    func create(userId: Int, gameId: Int, rating: Int, content: String) async throws -> Int {
        try await db.raw("""
            INSERT INTO reviews (user_id, game_id, rating, content)
            VALUES (\(bind: userId), \(bind: gameId), \(bind: rating), \(bind: content))
        """).run()

        let row = try await db.raw("SELECT LAST_INSERT_ID() AS id").first()
        return try row?.decode(column: "id", as: Int.self) ?? 0
    }

    func update(id: Int, userId: Int, rating: Int, content: String) async throws {
        try await db.raw("""
            UPDATE reviews
            SET rating = \(bind: rating),
                content = \(bind: content),
                updated_at = CURRENT_TIMESTAMP
            WHERE id = \(bind: id)
              AND user_id = \(bind: userId)
        """).run()
    }

    func delete(id: Int, userId: Int) async throws {
        try await db.raw("""
            DELETE FROM reviews
            WHERE id = \(bind: id)
              AND user_id = \(bind: userId)
        """).run()
    }

    func fetchByGame(gameId: Int, sort: ReviewSort) async throws -> [ReviewResponse] {
        let orderSQL: SQLQueryString

        switch sort {
        case .latest:
            orderSQL = "ORDER BY created_at DESC"
        case .highest:
            orderSQL = "ORDER BY rating DESC, created_at DESC"
        case .lowest:
            orderSQL = "ORDER BY rating ASC, created_at DESC"
        }

        let sql: SQLQueryString = """
            SELECT
                id,
                user_id   AS userId,
                game_id   AS gameId,
                rating,
                content,
                created_at AS createdAt,
                updated_at AS updatedAt
            FROM reviews
            WHERE game_id = \(bind: gameId)
            \(orderSQL)
        """

        return try await db.raw(sql).all(decoding: ReviewResponse.self)
    }

    func fetchByUser(userId: Int) async throws -> [ReviewResponse] {
        try await db.raw("""
            SELECT
                id,
                user_id   AS userId,
                game_id   AS gameId,
                rating,
                content,
                created_at AS createdAt,
                updated_at AS updatedAt
            FROM reviews
            WHERE user_id = \(bind: userId)
            ORDER BY created_at DESC
        """).all(decoding: ReviewResponse.self)
    }

    func fetchStats(gameId: Int) async throws -> ReviewStatsResponse {
        guard let row = try await db.raw("""
            SELECT AVG(rating) AS avg, COUNT(*) AS cnt
            FROM reviews
            WHERE game_id = \(bind: gameId)
        """).first()
        else {
            return .init(gameId: gameId, averageRating: 0.0, reviewCount: 0)
        }

        let avg = try row.decode(column: "avg", as: Double?.self) ?? 0
        let count = try row.decode(column: "cnt", as: Int?.self) ?? 0


        return .init(gameId: gameId, averageRating: avg, reviewCount: count)
    }
}




