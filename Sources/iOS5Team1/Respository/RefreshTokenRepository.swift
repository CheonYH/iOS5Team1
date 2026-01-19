//  RefreshTokenRepository.swift
//  iOS5Team1
//
//  리프레시 토큰을 저장/조회/삭제하기 위한 리포지토리 규격(프로토콜)입니다.
//  실제 구현은 MySQLRefreshTokenRepository에서 담당합니다.
//
//  초보자 가이드
//  - Refresh Token: 액세스 토큰 갱신용 장기 토큰으로, 안전한 저장이 중요합니다.

import Foundation
import SQLKit

protocol RefreshTokenRepository: Sendable {
    /// 새 리프레시 토큰 저장
    func create(userId: Int, token: String, expiresAt: Date) async throws
    /// 특정 토큰 삭제
    func delete(_ token: String) async throws
    /// 특정 사용자의 모든 토큰 삭제
    func deleteAll(for userId: Int) async throws
    /// 토큰 문자열로 조회
    func find(_ token: String) async throws -> RefreshToken?
}
