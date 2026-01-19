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
    /// 토큰 소유자(사용자)의 고유 식별자
    var subject: SubjectClaim
    /// 토큰 만료 시각
    var expiration: ExpirationClaim

    /// 토큰이 아직 유효한지 검사합니다.
    func verify(using algorithm: some JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}
