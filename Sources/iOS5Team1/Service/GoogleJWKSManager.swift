//
//  GoogleJWKSManager.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor
import JWT
import JWTKit

/// Google ID Token의 서명/클레임 검증을 담당하는 헬퍼입니다.
///
/// - Composition:
///     - client: JWKS 조회에 사용하는 HTTP 클라이언트
/// - Important:
///     - iss/aud 검증이 실패하면 인증이 거부됩니다.
actor GoogleJWKSManager {
    private let client: any Client

    init(client: any Client) {
        self.client = client
    }

    func verify(
        req: Request,
        idToken: String,
        expectedAud: String,
        expectedIss: String = "https://accounts.google.com"
    ) async throws -> GoogleIDPayload {

        let payload = try await req.jwt.verify(idToken, as: GoogleIDPayload.self)

        guard payload.aud == expectedAud else {
            throw Abort(.unauthorized, reason: "Invalid aud")
        }

        guard payload.iss == expectedIss else {
            throw Abort(.unauthorized, reason: "Invalid iss")
        }

        return payload
    }
}





