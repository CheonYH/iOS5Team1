//
//  SocialIdTokenLoginRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

/// 소셜 로그인 요청 DTO입니다.
///
/// - Composition:
///     - idToken: 소셜 제공자가 발급한 ID 토큰
///     - provider: 소셜 제공자 타입(google/apple 등)
/// - Important:
///     - idToken은 서버에서 서명 검증됩니다.
struct SocialIdTokenLoginRequest: Content {
    let idToken: String
    let provider: SocialProvider
    let deviceId: String?
}
