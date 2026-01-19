//
//  GoogleIDPayload.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor
import JWT

/// Google ID Token의 페이로드 모델입니다.
///
/// - Composition:
///     - iss/aud: 발급자/대상 확인용 클레임
///     - sub: 사용자 고유 식별자
///     - email/email_verified: 이메일 정보(있을 수 있음)
/// - Important:
///     - exp 검증으로 만료된 토큰을 차단합니다.
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
