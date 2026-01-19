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

actor MyAuthService: AuthService {

    /// 사용자 데이터 접근 리포지토리
    let users: any UserRepository
    /// 리프레시 토큰 저장/조회 리포지토리
    let refreshTokens: any RefreshTokenRepository

    /// 리프레시 토큰 만료 시간(30일)
    let refreshTTL: TimeInterval = 60 * 60 * 24 * 30  // 30 days
    /// 액세스 토큰 만료 시간(1시간)
    let accessTTL: TimeInterval = 60 * 60             // 1 hour

    init(users: any UserRepository, refreshTokens: any RefreshTokenRepository) {
        self.users = users
        self.refreshTokens = refreshTokens
    }

    /// 로그인 처리: 자격 증명 확인 후 토큰 쌍 발급
    func login(req: Request, email: String, password: String) async throws -> TokenPair {
        guard let user = try await users.findByEmail(email) else {
            throw Abort(.unauthorized, reason: "email not found")
        }

        guard user.password != nil else {
            throw Abort(.forbidden, reason: "this account uses social login")
        }

        guard let hashed = user.password else {
            throw Abort(.forbidden, reason: "This account uses social login.")
        }

        guard try Bcrypt.verify(password, created: hashed) else {
            throw Abort(.unauthorized, reason: "invalid password")
        }

        let access = try await generateAccessToken(req: req, userId: user.id)
        let refresh = generateRefreshToken()
        let expires = Date().addingTimeInterval(refreshTTL)

        try await refreshTokens.create(userId: user.id, token: refresh, expiresAt: expires)

        return TokenPair(access: access, refresh: refresh)
    }

    /// 리프레시 토큰으로 새 토큰 쌍 발급
    func refresh(req: Request, refreshToken: String) async throws -> TokenPair {
        // 저장된 리프레시 토큰 조회
        guard let stored = try await refreshTokens.find(refreshToken) else {
            throw Abort(.unauthorized, reason: "invalid refresh token")
        }

        // 만료 여부 확인
        guard stored.expiresAt > Date() else {
            throw Abort(.unauthorized, reason: "refresh expired")
        }

        // 새 액세스/리프레시 토큰 발급
        let newAccess = try await generateAccessToken(req: req, userId: stored.userId)
        let newRefresh = generateRefreshToken()
        let newExpires = Date().addingTimeInterval(refreshTTL)

        // 기존 리프레시 토큰 폐기 후 새 토큰 저장
        try await refreshTokens.delete(refreshToken)
        try await refreshTokens.create(userId: stored.userId, token: newRefresh, expiresAt: newExpires)

        return TokenPair(access: newAccess, refresh: newRefresh)
    }

    /// 로그아웃: 리프레시 토큰 폐기
    func logout(refreshToken: String) async throws {
        try await refreshTokens.delete(refreshToken)
    }

    // MARK: - 내부 유틸리티

    /// 액세스 토큰(JWT) 생성
    private func generateAccessToken(req: Request, userId: Int) async throws -> String {
        let payload = AccessTokenPayload(
            subject: .init(value: String(userId)),
            expiration: .init(value: .init(timeIntervalSinceNow: accessTTL))
        )

        return try await req.jwt.sign(payload)
    }

    /// 랜덤 리프레시 토큰 문자열 생성
    private func generateRefreshToken() -> String {
        UUID().uuidString + UUID().uuidString
    }

    /// (선택) 회원가입 로직 예시
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

    func createTokenPair(req: Request, userId: Int) async throws -> TokenPair {
        let access = try await generateAccessToken(req: req, userId: userId)
        let refresh = generateRefreshToken()
        let expires = Date().addingTimeInterval(refreshTTL)

        try await refreshTokens.create(userId: userId, token: refresh, expiresAt: expires)

        return TokenPair(access: access, refresh: refresh)
    }

    func createSocial(email: String?, provider: String, providerUid: String, nickname: String) async throws -> User {
        return try await users.createSocial(
            email: email,
            provider: provider,
            providerUid: providerUid,
            nickname: nickname
        )
    }

}

