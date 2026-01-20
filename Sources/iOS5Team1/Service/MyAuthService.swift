//  MyAuthService.swift
//  iOS5Team1
//
//  AuthService 프로토콜의 실제 구현체입니다.
//  로그인/토큰 재발급/로그아웃과 같은 인증 흐름을 담당합니다.
//
//  초보자 가이드
//  - 액세스 토큰(access): 짧은 기간 동안 API 접근을 허용하는 토큰
//  - 리프레시 토큰(refresh): 액세스 토큰 갱신에 사용하는 더 긴 수명의 토큰
//  - Bcrypt: 비밀번호를 안전하게 비교/검증하기 위한 해시 알고리즘

import Vapor
import JWT
import SQLKit

import Vapor
import JWT
import SQLKit

/// 이메일 기반 인증 및 토큰 관리를 수행하는 서비스입니다.
///
/// - Composition:
///     - users: 사용자 저장소
///     - refreshTokens: 리프레시 토큰 저장소
/// - Important:
///     - access/refresh TTL 정책은 이 타입에서 결정됩니다.
actor MyAuthService: AuthService {

    let users: any UserRepository
    let refreshTokens: any RefreshTokenRepository

    // 만료 시간
    let refreshTTL: TimeInterval = 60 * 60 * 24 * 90   // 90일
    let accessTTL: TimeInterval = 60 * 60              // 1시간

    init(users: any UserRepository, refreshTokens: any RefreshTokenRepository) {
        self.users = users
        self.refreshTokens = refreshTokens
    }

    // MARK: - Email Login

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

        try await refreshTokens.revoke(refreshToken)
        try await refreshTokens.create(
            userId: stored.userId,
            token: newRefresh,
            expiresAt: newExpires,
            deviceID: stored.deviceID,
            userAgent: stored.userAgent,
            ip: stored.ip,
            platform: stored.platform
        )

        return TokenPair(access: newAccess, refresh: newRefresh)
    }

    // MARK: - Logout

    func logout(refreshToken: String) async throws {
        try await refreshTokens.revoke(refreshToken)
    }

    // MARK: - Create TokenPair

    func createTokenPair(req: Request, userId: Int) async throws -> TokenPair {
        let access = try await generateAccessToken(req: req, userId: userId)
        let refresh = generateRefreshToken()
        let expires = Date().addingTimeInterval(refreshTTL)

        try await refreshTokens.create(
            userId: userId,
            token: refresh,
            expiresAt: expires,
            deviceID: req.headers["X-Device-ID"].first,
            userAgent: req.headers.userAgent,
            ip: req.remoteAddress?.ipAddress,
            platform: "ios"
        )

        return TokenPair(access: access, refresh: refresh)
    }

    // MARK: - Social Registration

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
}


extension HTTPHeaders {
    var userAgent: String? { self.first(name: .userAgent) }
}
