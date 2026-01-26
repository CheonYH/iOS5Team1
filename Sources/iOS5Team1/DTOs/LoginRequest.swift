//
//  LoginRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//
import Foundation
import Vapor

/// 이메일/비밀번호 로그인 요청 DTO입니다.
///
/// - Composition:
///     - email: 로그인 ID로 사용할 이메일
///     - password: 평문 비밀번호(서버에서 해시 비교)
/// - Important:
///     - 전송 시 HTTPS 사용을 전제로 합니다.
struct LoginRequest: Content {
    let email: String
    let password: String
    let deviceId: String?
}
