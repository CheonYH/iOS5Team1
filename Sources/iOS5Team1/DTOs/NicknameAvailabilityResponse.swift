//  NicknameAvailabilityResponse.swift
//  iOS5Team1
//
//  닉네임 사용 가능 여부를 응답으로 전달하는 모델입니다.
//
//  초보자 가이드
//  - available: true면 사용 가능, false면 이미 사용 중입니다.

import Vapor

struct NicknameAvailabilityResponse: Content {
    /// 닉네임 사용 가능 여부
    let available: Bool
}
