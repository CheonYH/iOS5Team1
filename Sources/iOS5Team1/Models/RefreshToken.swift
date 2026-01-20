//  RefreshToken.swift
//  iOS5Team1
//
//  리프레시 토큰 레코드를 표현하는 모델입니다(내부 사용).
//
//  초보자 가이드
//  - expiresAt: 만료 시각이 지나면 토큰은 더 이상 유효하지 않습니다.

import Foundation

/// DB의 refresh_tokens 테이블과 1:1로 매핑되는 모델입니다.
///
/// - Composition:
///     - expiresAt/usedAt/revokedAt: 토큰 상태 시각
/// - Important:
///     - 만료 또는 폐기된 토큰은 인증에 사용할 수 없습니다.
struct RefreshToken: Sendable {
    let id: Int
    let userId: Int
    let token: String

    let deviceID: String?
    let userAgent: String?
    let ip: String?
    let platform: String?

    let usedAt: Date?
    let revokedAt: Date?
    let expiresAt: Date
    let createdAt: Date
    let updatedAt: Date?
}
