//
//  SocialAuthProvider.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

/// 지원하는 소셜 로그인 제공자 목록입니다.
///
/// - Composition:
///     - google/apple/kakao/naver: 제공자 식별 문자열
/// - Important:
///     - 클라이언트 요청의 provider 값과 일치해야 합니다.
enum SocialProvider: String, Codable {
    case google
    case apple
    case kakao
    case naver
}


/// 소셜 로그인 제공자 검증 인터페이스입니다.
///
/// - Composition:
///     - verify: ID Token을 검증하고 사용자 정보를 반환
/// - Important:
///     - 서명/issuer/aud 검증을 포함해야 합니다.
protocol SocialAuthProvider: Sendable {
    func verify(req: Request, idToken: String) async throws -> VerifiedSocialUser
}

