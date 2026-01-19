//
//  NicknameCheckRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/15/26.
//

import Vapor

/// 닉네임 중복 확인 요청 DTO입니다.
///
/// - Composition:
///     - nickname: 중복 검사 대상 닉네임
/// - Important:
///     - 공백/길이 제한은 서버 정책에 따라 별도 검증됩니다.
struct NicknameCheckRequest: Content {
    let nickname: String
}
