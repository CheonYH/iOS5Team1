//
//  MySQLUserRepository.swift
//  iOS5Team1
//
//  MySQL 데이터베이스에서 사용자(User) 정보를 관리하는 리포지토리입니다.
//  이메일로 조회, 중복 확인, 생성 등을 담당합니다.
//
//  초보자 가이드
//  - Repository: DB와 직접 통신하는 계층. 쿼리를 캡슐화하여 상위 레이어가 쉽게 사용하도록 합니다.
//  - actor: 동시성(Concurrency)에서 데이터 경쟁을 막기 위해 순차적으로 실행되는 타입입니다.
//  - SQLKit: Swift에서 SQL을 안전하게 작성/실행할 수 있는 라이브러리입니다.

import Foundation
import SQLKit
import Vapor

actor MySQLUserRepository: UserRepository {


    /// SQL 실행에 사용할 데이터베이스 핸들
    let db: any SQLDatabase

    /// 이메일로 사용자 1명을 조회합니다. 없으면 nil 반환
    func findByEmail(_ email: String) async throws -> User? {
        let rows = try await db.raw("""
            SELECT id, email, password, nickname, provider, provider_uid, onboarding_completed, deleted_at, created_at, updated_at
            FROM users
            WHERE email = \(bind: email)
              AND (provider IS NULL OR provider = 'local')
            LIMIT 1
            """)
            .all()

        guard let row = rows.first else { return nil }

        return User(
            id: try row.decode(column: "id", as: Int.self),
            email: try row.decode(column: "email", as: String?.self),
            password: try row.decode(column: "password", as: String?.self),
            nickname: try row.decode(column: "nickname", as: String.self),
            provider: try row.decode(column: "provider", as: String?.self),
            providerUid: try row.decode(column: "provider_uid", as: String?.self),
            onboardingCompleted: try row.decode(column: "onboarding_completed", as: Bool.self),
            deletedAt: try row.decode(column: "deleted_at", as: Date?.self),
            createdAt: try row.decode(column: "created_at", as: Date?.self),
            updatedAt: try row.decode(column: "updated_at", as: Date?.self)
        )
    }

    func findById(_ id: Int) async throws -> User? {
        let rows = try await db.raw("""
            SELECT id, email, password, nickname, provider, provider_uid, onboarding_completed, deleted_at, created_at, updated_at
            FROM users
            WHERE id = \(bind: id)
            LIMIT 1
            """)
            .all()

        guard let row = rows.first else { return nil }

        return User(
            id: try row.decode(column: "id", as: Int.self),
            email: try row.decode(column: "email", as: String?.self),
            password: try row.decode(column: "password", as: String?.self),
            nickname: try row.decode(column: "nickname", as: String.self),
            provider: try row.decode(column: "provider", as: String?.self),
            providerUid: try row.decode(column: "provider_uid", as: String?.self),
            onboardingCompleted: try row.decode(column: "onboarding_completed", as: Bool.self),
            deletedAt: try row.decode(column: "deleted_at", as: Date?.self),
            createdAt: try row.decode(column: "created_at", as: Date?.self),
            updatedAt: try row.decode(column: "updated_at", as: Date?.self)
        )
    }

    /// 이메일 중복 여부 확인
    func exists(email: String) async throws -> Bool {
        let rows = try await db.raw("""
            SELECT EXISTS(
                SELECT 1 FROM users
                WHERE email = \(bind: email)
                  AND (provider IS NULL OR provider = 'local')
            ) AS user_exists
            """).all()

        guard let row = rows.first else {
            throw RepositoryError.queryFailed
        }

        return try row.decode(column: "user_exists", as: Bool.self)
    }

    /// 닉네임 중복 여부 확인
    func exists(nickname: String) async throws -> Bool {
        let rows = try await db.raw("""
            SELECT EXISTS(SELECT 1 FROM users WHERE nickname = \(bind: nickname)) AS nickname_exists
            """).all()

        guard let row = rows.first else {
            throw RepositoryError.queryFailed
        }

        return try row.decode(column: "nickname_exists", as: Bool.self)
    }

    /// 사용자 생성 후, 방금 생성한 사용자 정보를 반환합니다.
    func create(email: String, password: String, nickname: String) async throws -> User {
        try await db.raw("""
            INSERT INTO users (email, password, nickname, provider)
            VALUES (\(bind: email), \(bind: password), \(bind: nickname), 'local')
            """)
        .run()

        // 방금 생성한 유저 다시 조회(정합성 확보)
        guard let user = try await findByEmail(email) else {
            throw RepositoryError.insertFailed
        }

        return user
    }

    func findByProvider(uid: String, provider: String) async throws -> User? {
        let rows = try await db.raw("""
            SELECT id, email, password, nickname, provider, provider_uid, onboarding_completed, deleted_at, created_at, updated_at
            FROM users
            WHERE provider = \(bind: provider) AND provider_uid = \(bind: uid)
            LIMIT 1
        """).all()

        guard let row = rows.first else { return nil }

        return User(
            id: try row.decode(column: "id", as: Int.self),
            email: try row.decode(column: "email", as: String?.self),
            password: try row.decode(column: "password", as: String?.self),
            nickname: try row.decode(column: "nickname", as: String.self),
            provider: try row.decode(column: "provider", as: String?.self),
            providerUid: try row.decode(column: "provider_uid", as: String?.self),
            onboardingCompleted: try row.decode(column: "onboarding_completed", as: Bool.self),
            deletedAt: try row.decode(column: "deleted_at", as: Date?.self),
            createdAt: try row.decode(column: "created_at", as: Date?.self),
            updatedAt: try row.decode(column: "updated_at", as: Date?.self)
        )
    }



    func createSocial(email: String?, provider: String, providerUid: String, nickname: String) async throws -> User {

        try await db.raw("""
            INSERT INTO users (email, provider, provider_uid, nickname)
            VALUES (\(bind: email), \(bind: provider), \(bind: providerUid), \(bind: nickname))
        """).run()

        guard let user = try await findByProvider(uid: providerUid, provider: provider) else {
            throw Abort(.internalServerError, reason: "failed to create user")
        }

        return user
    }

    func updateNickname(userId: Int, nickname: String) async throws {
        try await db.raw("""
        UPDATE users SET nickname = \(bind: nickname),
        updated_at = CURRENT_TIMESTAMP WHERE id = \(bind: userId)
        """).run()
    }

    func updateOnboardingCompleted(userId: Int, completed: Bool) async throws {
        try await db.raw("""
        UPDATE users SET onboarding_completed = \(bind: completed),
        updated_at = CURRENT_TIMESTAMP WHERE id = \(bind: userId)
        """).run()
    }

    func softDelete(userId: Int) async throws {
        try await db.raw("""
        UPDATE users SET deleted_at = CURRENT_TIMESTAMP,
        updated_at = CURRENT_TIMESTAMP WHERE id = \(bind: userId)
        """).run()
    }



    /// 의존성 주입을 위한 생성자
    init(db: any SQLDatabase) {
        self.db = db
    }
}
