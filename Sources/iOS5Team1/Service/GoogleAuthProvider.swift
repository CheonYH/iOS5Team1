//
//  GoogleAuthProvider.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

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




