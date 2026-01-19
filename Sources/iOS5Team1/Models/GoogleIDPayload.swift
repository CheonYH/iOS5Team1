//
//  GoogleIDPayload.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor
import JWT

struct GoogleIDPayload: JWTPayload {
    let iss: String
    let aud: String
    let sub: String
    let email: String?
    let email_verified: Bool?
    let exp: ExpirationClaim

    func verify(using algorithm: some JWTAlgorithm) throws {
        try exp.verifyNotExpired()
    }
}
