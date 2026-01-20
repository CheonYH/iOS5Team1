//
//  RegisterResponse.swift
//  iOS5Team1
//
//  Created by cheon on 1/10/26.
//

import Foundation
import Vapor

/// 회원가입 결과 응답 모델입니다.
///
/// - Composition:
///     - success: 처리 성공 여부
///     - message: 사용자 안내 메시지
/// - Important:
///     - 실패 시 message로 사유를 전달합니다.
struct RegisterResponse: Content {
    let success: Bool
    let message: String
}
