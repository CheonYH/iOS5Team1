//  MySQLRefreshTokenRepository.swift
//  iOS5Team1
//
//  리프레시 토큰을 MySQL 데이터베이스에 보관/조회/삭제하는 리포지토리입니다.
//
//  초보자 가이드
//  - Refresh Token: 액세스 토큰이 만료되었을 때 새 토큰을 발급받기 위한 장기 토큰
//  - db.raw: 순수 SQL문을 그대로 실행합니다. 바인딩(\(bind: ...))으로 SQL 인젝션을 방지합니다.


import SQLKit
import Foundation

struct MySQLRefreshTokenRepository: RefreshTokenRepository {
    /// SQL 실행에 사용할 데이터베이스 핸들
    let db: any SQLDatabase

    /// 새 리프레시 토큰을 저장합니다.
    func create(userId: Int, token: String, expiresAt: Date) async throws {
        try await db.raw("""
            INSERT INTO refresh_tokens (user_id, token, expires_at)
            VALUES (\(bind: userId), \(bind: token), \(bind: expiresAt))
            """)
            .run()
    }

    /// 특정 토큰을 삭제합니다(로그아웃 등).
    func delete(_ token: String) async throws {
        try await db.raw("""
            DELETE FROM refresh_tokens
            WHERE token = \(bind: token)
            """)
            .run()
    }

    /// 특정 사용자의 모든 리프레시 토큰을 삭제합니다(모든 기기 로그아웃 등).
    func deleteAll(for userId: Int) async throws {
        try await db.raw("""
            DELETE FROM refresh_tokens
            WHERE user_id = \(bind: userId)
            """)
            .run()
    }

    /// 토큰 문자열로 리프레시 토큰 정보를 조회합니다.
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
