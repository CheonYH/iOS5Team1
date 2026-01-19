//
//  SocialAuthService.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//
import Vapor


actor SocialAuthService {
    private let users: any UserRepository
    private let refreshTokens: any RefreshTokenRepository
    private let authService: MyAuthService
    private let providers: [SocialProvider: any SocialAuthProvider]

    init(
        users: any UserRepository,
        refreshTokens: any RefreshTokenRepository,
        authService: MyAuthService,
        providers: [SocialProvider: any SocialAuthProvider]
    ) {
        self.users = users
        self.refreshTokens = refreshTokens
        self.authService = authService
        self.providers = providers
    }

    /// 소셜 로그인 시도 (없는 경우 가입 필요)
    func loginWithSocial(
        req: Request,
        provider: SocialProvider,
        idToken: String
    ) async throws -> TokenPair? {
        guard let verifier = providers[provider] else {
            throw Abort(.badRequest, reason: "unsupported provider")
        }

        let verified = try await verifier.verify(req: req, idToken: idToken)

        /// 기존 유저 조회
        if let user = try await users.findByProvider(uid: verified.uid, provider: provider.rawValue) {
            return try await authService.createTokenPair(req: req, userId: user.id)
        }

        /// 신규 → 가입 필요
        return nil
    }

    /// 신규 가입 처리
    func registerSocialUser(
        req: Request,
        provider: SocialProvider,
        uid: String,
        nickname: String,
        email: String
    ) async throws -> TokenPair {
        let users = try await users.createSocial(
            email: email, provider: provider.rawValue,
            providerUid: uid,
            nickname: nickname
        )

        return try await authService.createTokenPair(req: req, userId: users.id)
    }

    func verifySocial(req: Request, provider: SocialProvider, idToken: String) async throws -> VerifiedSocialUser {
        guard let verifier = providers[provider] else {
            throw Abort(.badRequest, reason: "unsupported provider")
        }

        return try await verifier.verify(req: req, idToken: idToken)
    }
}



