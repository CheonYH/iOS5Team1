//
//  GoogleJWKSManager.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor
import JWT
import JWTKit

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






