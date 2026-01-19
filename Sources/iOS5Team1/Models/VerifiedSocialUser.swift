//  VerifiedSocialUser.swift
//  iOS5Team1
//
//  소셜 로그인 토큰 검증 후 얻는 사용자 정보를 담습니다.
//
//  초보자 가이드
//  - uid는 소셜 제공자가 부여한 유니크 ID입니다.
//  - provider는 어떤 소셜 플랫폼인지 구분하는 값입니다.

import Foundation

struct VerifiedSocialUser {
    let uid: String          // provider unique ID
    let email: String?
    let isEmailVerified: Bool?
    let provider: SocialProvider
}
