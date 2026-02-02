//
//  AuthMeResponse.swift
//  iOS5Team1
//
//  자동 로그인 시점에 사용자 상태를 조회하는 응답 모델입니다.
//

import Vapor

struct AuthMeResponse: Content {
    let userId: Int
    let onboardingCompleted: Bool
}
