//  GoogleOAuthConfig.swift
//  iOS5Team1
//
//  Google OAuth 설정 값을 묶어 전달하는 모델입니다.
//
//  초보자 가이드
//  - clientId/clientSecret은 Google Cloud 콘솔에서 발급받습니다.
//  - redirectURI는 OAuth 인증 후 되돌아올 주소입니다.

import Vapor

/// Google OAuth 설정 모델입니다.
///
/// - Composition:
///     - clientId/clientSecret: OAuth 클라이언트 인증 정보
///     - redirectURI: 인증 후 리다이렉트 주소
/// - Important:
///     - 값은 환경 변수에서 주입됩니다.
struct GoogleOAuthConfig {
    let clientId: String
    let clientSecret: String
    let redirectURI: String
}
