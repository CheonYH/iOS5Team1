//
//  OnboardingCompleteResponse.swift
//  iOS5Team1
//
//  온보딩 완료 처리 응답 모델입니다.
//

import Vapor

struct OnboardingCompleteResponse: Content {
    let success: Bool
    let onboardingCompleted: Bool
}
