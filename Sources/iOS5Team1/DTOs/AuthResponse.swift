//
//  AuthResponse.swift
//  iOS5Team1
//
//  로그인/소셜 로그인 성공 시 내려주는 응답 모델입니다.
//

import Vapor

/// 인증 성공 응답 모델
struct AuthResponse: Content {
    let access: String
    let refresh: String
    let onboardingCompleted: Bool
}
