//
//  MyAuthService.swift
//

import Vapor
import JWT
import SQLKit

actor MyAuthService: AuthService {

    let users: any UserRepository
    let refreshTokens: any RefreshTokenRepository

    let refreshTTL: TimeInterval = 60 * 60 * 24 * 30  // 30 days
    let accessTTL: TimeInterval = 60 * 60             // 1 hour

    init(users: any UserRepository, refreshTokens: any RefreshTokenRepository) {
        self.users = users
        self.refreshTokens = refreshTokens
    }

    func login(req: Request, email: String, password: String) async throws -> TokenPair {
        guard let user = try await users.findByEmail(email) else {
            throw Abort(.unauthorized, reason: "email not found")
        }

        guard try Bcrypt.verify(password, created: user.password) else {
            throw Abort(.unauthorized, reason: "invalid password")
        }

        let access = try await generateAccessToken(req: req, userId: user.id)

        let refresh = generateRefreshToken()
        let expires = Date().addingTimeInterval(refreshTTL)

        try await refreshTokens.create(userId: user.id, token: refresh, expiresAt: expires)

        return TokenPair(access: access, refresh: refresh)
    }

    func refresh(req: Request, refreshToken: String) async throws -> TokenPair {
        guard let stored = try await refreshTokens.find(refreshToken) else {
            throw Abort(.unauthorized, reason: "invalid refresh token")
        }

        guard stored.expiresAt > Date() else {
            throw Abort(.unauthorized, reason: "refresh expired")
        }

        let newAccess = try await generateAccessToken(req: req, userId: stored.userId)
        let newRefresh = generateRefreshToken()
        let newExpires = Date().addingTimeInterval(refreshTTL)

        try await refreshTokens.delete(refreshToken)
        try await refreshTokens.create(userId: stored.userId, token: newRefresh, expiresAt: newExpires)

        return TokenPair(access: newAccess, refresh: newRefresh)
    }

    func logout(refreshToken: String) async throws {
        try await refreshTokens.delete(refreshToken)
    }

    private func generateAccessToken(req: Request, userId: Int) async throws -> String {
        let payload = AccessTokenPayload(
            subject: .init(value: String(userId)),
            expiration: .init(value: .init(timeIntervalSinceNow: accessTTL))
        )

        return try await req.jwt.sign(payload)
    }

    private func generateRefreshToken() -> String {
        UUID().uuidString + UUID().uuidString
    }

    func register(req: Request) async throws -> HTTPStatus {
        let body = try req.content.decode(RegisterRequest.self)

        // 1) 이메일 중복 확인
        if try await users.exists(email: body.email) {
            throw Abort(.conflict, reason: "email already exists")
        }

        // 2) 비밀번호 해시
        let hashed = try Bcrypt.hash(body.password)

        // 3) 저장
        _ = try await users.create(
            email: body.email,
            password: hashed,
            nickname: body.nickname
        )

        return .created
    }

}

