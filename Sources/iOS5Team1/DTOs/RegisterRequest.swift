//  RegisterRequest.swift
//  iOS5Team1
//
//  회원가입 요청 본문을 표현하는 모델입니다.
//
//  초보자 가이드
//  - Content 프로토콜을 채택하면 JSON을 자동으로 인코딩/디코딩할 수 있습니다.

import Foundation
import Vapor

/// 회원가입 시 클라이언트가 보내는 데이터 형식
/// 회원가입 요청 DTO입니다.
///
/// - Composition:
///     - email/password/nickname
/// - Important:
///     - 비밀번호는 서버에서 해시 처리됩니다.
struct RegisterRequest: Content {
    /// 사용자 이메일(로그인 ID)
    let email: String
    /// 사용자 비밀번호(서버에서 해시 처리)
    let password: String
    /// 사용자 닉네임(표시 이름)
    let nickname: String
}
