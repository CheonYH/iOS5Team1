//  AccessTokenPayload.swift
//  iOS5Team1
//
//  JWT 액세스 토큰에 담기는 정보(페이로드)를 정의합니다.
//
//  초보자 가이드
//  - subject(SubjectClaim): 사용자 식별자(예: 사용자 ID)
//  - expiration(ExpirationClaim): 토큰 만료 시간. 만료되면 더 이상 사용할 수 없습니다.

import Foundation
import JWT

struct AccessTokenPayload: JWTPayload {
    let sub: SubjectClaim
    let exp: ExpirationClaim
    var iat: IssuedAtClaim

    func verify(using algorithm: some JWTAlgorithm) throws {
        try exp.verifyNotExpired()
    }
}
