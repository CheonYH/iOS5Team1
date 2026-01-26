//  MyAuthService.swift
//  iOS5Team1
//
//  AuthService 프로토콜의 실제 구현체입니다.
//  로그인/토큰 재발급/로그아웃 흐름을 담당합니다.

import Vapor
import JWT
import SQLKit

import Vapor
import JWT
import SQLKit

/// 이메일 로그인 및 토큰 발급 로직을 처리합니다.
actor MyAuthService: AuthService {

    /// 사용자 리포지토리
    let users: any UserRepository
    /// 리프레시 토큰 리포지토리
    let refreshTokens: any RefreshTokenRepository

    /// 리프레시 토큰 만료 시간(초)
    let refreshTTL: TimeInterval = 60 * 60 * 24 * 90   // 90일
    /// 액세스 토큰 만료 시간(초)
    let accessTTL: TimeInterval = 60 * 60              // 1시간

    /// 의존성 주입용 생성자
    init(users: any UserRepository, refreshTokens: any RefreshTokenRepository) {
        self.users = users
        self.refreshTokens = refreshTokens
    }

    // MARK: - Email Login

    /// 이메일/비밀번호로 로그인합니다.
    func login(req: Request, email: String, password: String) async throws -> TokenPair {
        guard let user = try await users.findByEmail(email) else {
            throw Abort(.unauthorized, reason: "email or password incorrect")
        }

        guard let hashed = user.password else {
            throw Abort(.forbidden, reason: "this account uses social login")
        }

        guard try Bcrypt.verify(password, created: hashed) else {
            throw Abort(.unauthorized, reason: "email or password incorrect")
        }

        return try await createTokenPair(req: req, userId: user.id)
    }

    // MARK: - Refresh Access Token

    /// 리프레시 토큰으로 액세스 토큰을 재발급합니다.
    func refresh(req: Request, refreshToken: String) async throws -> TokenPair {
        guard let stored = try await refreshTokens.find(refreshToken) else {
            throw Abort(.unauthorized, reason: "invalid refresh token")
        }

        guard stored.revokedAt == nil else {
            throw Abort(.unauthorized, reason: "refresh revoked")
        }

        guard stored.expiresAt > Date() else {
            throw Abort(.unauthorized, reason: "refresh expired")
        }

        try await refreshTokens.markUsed(refreshToken)

        let newAccess = try await generateAccessToken(req: req, userId: stored.userId)
        let newRefresh = generateRefreshToken()
        let newExpires = Date().addingTimeInterval(refreshTTL)
        let deviceID = stored.deviceID ?? resolveDeviceID(req: req)

        try await refreshTokens.revoke(refreshToken)
        try await refreshTokens.create(
            userId: stored.userId,
            token: newRefresh,
            expiresAt: newExpires,
            deviceID: deviceID,
            userAgent: stored.userAgent,
            ip: stored.ip,
            platform: stored.platform
        )

        return TokenPair(access: newAccess, refresh: newRefresh)
    }

    // MARK: - Logout

    /// 리프레시 토큰을 폐기합니다.
    func logout(refreshToken: String) async throws {
        try await refreshTokens.revoke(refreshToken)
    }

    // MARK: - Create TokenPair

    /// 토큰 쌍을 생성하고 저장합니다.
    func createTokenPair(req: Request, userId: Int) async throws -> TokenPair {
        let access = try await generateAccessToken(req: req, userId: userId)
        let refresh = generateRefreshToken()
        let expires = Date().addingTimeInterval(refreshTTL)
        let deviceID = resolveDeviceID(req: req)

        if let deviceID {
            // Ensure a single active refresh token per device.
            try await refreshTokens.revokeAll(for: userId, deviceID: deviceID)
        } else {
            req.logger.warning("Missing device id when issuing refresh token.")
        }

        try await refreshTokens.create(
            userId: userId,
            token: refresh,
            expiresAt: expires,
            deviceID: deviceID,
            userAgent: req.headers.userAgent,
            ip: req.remoteAddress?.ipAddress,
            platform: "ios"
        )

        return TokenPair(access: access, refresh: refresh)
    }

    // MARK: - Social Registration

    /// 소셜 로그인 계정을 생성합니다.
    func createSocial(
        email: String?,
        provider: String,
        providerUid: String,
        nickname: String
    ) async throws -> User {
        return try await users.createSocial(
            email: email,
            provider: provider,
            providerUid: providerUid,
            nickname: nickname
        )
    }

    // MARK: - Helpers

    private func generateAccessToken(req: Request, userId: Int) async throws -> String {
        let payload = AccessTokenPayload(
            sub: .init(value: String(userId)),
            exp: .init(value: .init(timeIntervalSinceNow: accessTTL)),
            iat: .init(value: Date())
        )

        return try await req.jwt.sign(payload)
    }

    private func generateRefreshToken() -> String {
        UUID().uuidString + UUID().uuidString
    }

    private func resolveDeviceID(req: Request) -> String? {
        return req.headers["X-Device-ID"].first ?? req.storage[RequestDeviceIDKey.self]
    }
}


extension HTTPHeaders {
    var userAgent: String? { self.first(name: .userAgent) }
}
