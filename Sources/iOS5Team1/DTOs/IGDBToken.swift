//
//  IGDBToken.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

/// IGDB OAuth 토큰 응답 DTO입니다.
///
/// - Composition:
///     - access_token: API 호출에 쓰는 Bearer 토큰
///     - expires_in: 만료까지 남은 초
///     - token_type: 토큰 타입(보통 \"bearer\")
/// - Important:
///     - 만료 전에 갱신해야 안정적으로 호출됩니다.
struct IGDBToken: Decodable {
    let access_token: String
    let expires_in: Int
    let token_type: String
}
