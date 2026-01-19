//
//  RegistrationNeededResponse.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

/// 소셜 로그인 결과, 추가 가입이 필요한 경우의 응답 DTO입니다.
///
/// - Composition:
///     - email: 소셜 제공자가 전달한 이메일(없을 수 있음)
/// - Important:
///     - 클라이언트는 이 응답을 받으면 가입 화면으로 유도합니다.
struct RegistrationNeededResponse: Content {
    let email: String?
}
