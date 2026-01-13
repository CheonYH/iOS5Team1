//
//  AccessTokenPayload.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Foundation
import JWT

struct AccessTokenPayload: JWTPayload {
    var subject: SubjectClaim
    var expiration: ExpirationClaim

    func verify(using algorithm: some JWTAlgorithm) async throws {
            try self.expiration.verifyNotExpired()
    }
}
