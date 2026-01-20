//  LoginResponse.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//
//  로그인 API의 응답 형식을 정의하는 파일입니다.
//  서버에서 로그인 요청을 처리한 뒤, 성공 여부와 메시지를
//  클라이언트(앱)로 전달할 때 이 구조체를 사용합니다.
//
//  초보자 가이드
//  - "응답(Response)"이란? 서버가 요청을 처리한 결과를 말합니다.
//  - 이 파일의 구조체는 그 결과를 담는 상자라고 생각하면 됩니다.
//  - success: 요청이 성공했는지(true/false)
//  - message: 사람이 읽을 수 있는 설명(예: "로그인 성공" 또는 오류 메시지)

import Vapor

/// 로그인 결과 응답 DTO입니다.
///
/// - Composition:
///     - success: 로그인 성공 여부
///     - message: 사용자 안내 메시지
/// - Important:
///     - 상세 오류 사유는 message에 포함됩니다.
struct LoginResponse: Content {
    /// 로그인 성공 여부
    /// - true: 로그인 성공
    /// - false: 로그인 실패(아이디/비밀번호 오류 등)
    let success: Bool

    /// 사용자에게 보여줄 안내 메시지
    /// 예: "로그인에 성공했습니다." 또는 "비밀번호가 올바르지 않습니다."
    let message: String
}
