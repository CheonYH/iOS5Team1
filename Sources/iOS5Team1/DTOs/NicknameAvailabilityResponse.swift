//  NicknameAvailabilityResponse.swift
//  iOS5Team1
//
//  닉네임 사용 가능 여부를 응답으로 전달하는 모델입니다.
//
//  초보자 가이드
//  - available: true면 사용 가능, false면 이미 사용 중입니다.

import Vapor

/// 닉네임 중복 확인 응답 DTO입니다.
///
/// - Composition:
///     - available: 사용 가능 여부
/// - Important:
///     - false면 이미 사용 중입니다.
struct NicknameAvailabilityResponse: Content {
    /// 닉네임 사용 가능 여부
    let available: Bool
}
