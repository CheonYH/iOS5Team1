//
//  MySQLProfileRepository.swift
//  iOS5Team1
//
//  Created by cheon on 1/23/26.
//

import Vapor
import SQLKit

/// MySQL 기반 프로필 리포지토리입니다.
actor MySQLProfileRepository: ProfileRepository {
    /// SQL 실행용 데이터베이스 핸들
    let db: any SQLDatabase

    /// 사용자 ID로 프로필을 조회합니다.
    func findByUserId(_ userId: Int) async throws -> Profile? {
        let rows = try await db.raw("""
            SELECT id, user_id, nickname, avatar_url, created_at, updated_at
            FROM profiles
            WHERE user_id = \(bind: userId)
            LIMIT 1
            """).all()

        guard let row = rows.first else {
            return nil
        }

        return Profile(
            id: try row.decode(column: "id", as: Int.self),
            userId: try row.decode(column: "user_id", as: Int.self),
            nickname: try row.decode(column: "nickname", as: String.self),
            avatarUrl: try row.decode(column: "avatar_url", as: String?.self),
            createdAt: try row.decode(column: "created_at", as: Date?.self),
            updatedAt: try row.decode(column: "updated_at", as: Date?.self)
        )
    }

    /// 프로필을 생성하고 생성된 프로필을 반환합니다.
    func create(userId: Int, nickname: String, avatarUrl: String?) async throws -> Profile {
        try await db.raw("""
            INSERT INTO profiles (user_id, nickname, avatar_url)
            VALUES (\(bind: userId), \(bind: nickname), \(bind: avatarUrl))
            """).run()

        guard let profile = try await findByUserId(userId) else {
            throw Abort(.internalServerError, reason: "프로필 생성 실패")
        }

        return profile
    }

    /// 프로필 닉네임/이미지를 수정합니다.
    func update(userId: Int, nickname: String?, avatarUrl: String?) async throws -> Profile {
        let current = try await findByUserId(userId)

        guard let existing = current else {
            throw Abort(.notFound, reason: "profile not found")
        }

        let newNickname = nickname ?? existing.nickname
        let newAvatarUrl = avatarUrl ?? existing.avatarUrl

        try await db.raw("""
            UPDATE profiles 
            SET nickname = \(bind: newNickname),
            avatar_url = \(bind: newAvatarUrl)
            WHERE user_id = \(bind: userId)
            """).run()

        guard let updated = try await findByUserId(userId) else {
            throw Abort(.internalServerError, reason: "failed to update profile")
        }

        return updated
    }

    /// 의존성 주입용 생성자
    init(db: any SQLDatabase) {
        self.db = db
    }
}
