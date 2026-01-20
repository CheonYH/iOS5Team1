//  VerifiedSocialUser.swift
//  iOS5Team1
//
//  소셜 로그인 토큰 검증 후 얻는 사용자 정보를 담습니다.
//
//  초보자 가이드
//  - uid는 소셜 제공자가 부여한 유니크 ID입니다.
//  - provider는 어떤 소셜 플랫폼인지 구분하는 값입니다.

import Foundation

/// 소셜 로그인 검증 결과를 담는 모델입니다.
///
/// - Composition:
///     - uid: 제공자 고유 사용자 ID
///     - email/isEmailVerified: 이메일 정보(있을 수 있음)
///     - provider: 소셜 제공자 타입
/// - Important:
///     - uid와 provider 조합으로 사용자를 식별합니다.
struct VerifiedSocialUser {
    let uid: String          // provider unique ID
    let email: String?
    let isEmailVerified: Bool?
    let provider: SocialProvider
}
