//  RefreshRequest.swift
//  iOS5Team1
//
//  액세스 토큰 재발급(Refresh) 요청 본문을 표현하는 모델입니다.
//
//  초보자 가이드
//  - refreshToken: 장기 보관 토큰으로, 만료된 액세스 토큰을 새로 발급받을 때 사용합니다.

import Vapor

/// 토큰 재발급 요청에서 사용하는 데이터 형식
struct RefreshRequest: Content {
    /// 클라이언트가 보유한 리프레시 토큰 문자열
    let refreshToken: String
}
