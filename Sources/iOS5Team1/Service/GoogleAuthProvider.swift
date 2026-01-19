//
//  GoogleAuthProvider.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

/// Google ID Token 검증 제공자입니다.
///
/// - Composition:
///     - jwks: Google 공개키(JWKS) 검증 유틸
///     - expectedAud: 허용할 Client ID
/// - Important:
///     - aud 불일치 시 인증을 거부합니다.
actor GoogleAuthProvider: SocialAuthProvider {
    private let jwks: GoogleJWKSManager
    private let expectedAud: String

    init(jwks: GoogleJWKSManager, expectedAud: String) {
        self.jwks = jwks
        self.expectedAud = expectedAud
    }

    func verify(req: Request, idToken: String) async throws -> VerifiedSocialUser {
        let payload = try await jwks.verify(
            req: req,
            idToken: idToken,
            expectedAud: expectedAud
        )

        return VerifiedSocialUser(
            uid: payload.sub,
            email: payload.email,
            isEmailVerified: payload.email_verified ?? false,
            provider: .google
        )
    }
}



