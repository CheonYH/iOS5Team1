//
//  SocialRegisterRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

/// 소셜 회원가입 요청 DTO입니다.
///
/// - Composition:
///     - provider: 소셜 제공자 문자열(예: \"google\")
///     - providerUid: 제공자가 부여한 고유 사용자 ID
///     - nickname: 서비스 내 표시 이름
///     - email: 사용자 이메일(선택)
/// - Important:
///     - provider 값은 서버의 SocialProvider와 일치해야 합니다.
struct SocialRegisterRequest: Content {
    let provider: String
    let providerUid: String
    let nickname: String
    let email: String?
}
