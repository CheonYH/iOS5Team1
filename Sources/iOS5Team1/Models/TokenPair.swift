//  TokenPair.swift
//  iOS5Team1
//
//  로그인/재발급 후 클라이언트로 전달되는 토큰 쌍 모델입니다.
//
//  초보자 가이드
//  - access: API 호출에 사용(짧은 수명)
//  - refresh: access 재발급에 사용(긴 수명)

import Foundation
import Vapor

struct TokenPair: Content {
    /// 짧은 수명의 액세스 토큰(JWT)
    let access: String
    /// 액세스 토큰 갱신용 리프레시 토큰
    let refresh: String
}
