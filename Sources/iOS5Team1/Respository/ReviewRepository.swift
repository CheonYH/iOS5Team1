//  ReviewRepository.swift
//  iOS5Team1
//
//  리뷰 데이터를 DB에서 다루기 위한 리포지토리 규격(프로토콜)입니다.
//  실제 SQL 실행은 MySQLReviewRepository에서 담당합니다.
//
//  초보자 가이드
//  - Repository: 데이터 접근을 캡슐화하여 상위 계층(Service/Controller)이 쉽게 사용하도록 합니다.

import Vapor

/// 리뷰 데이터 접근 인터페이스입니다.
///
/// - Composition:
///     - create/update/delete/fetch 메서드
/// - Important:
///     - 정렬/통계 로직은 구현체에서 수행됩니다.
protocol ReviewRepository: Sendable {
    /// 리뷰 생성 후 생성된 ID 반환
    func create(userId: Int, gameId: Int, rating: Int, content: String) async throws -> Int
    /// 리뷰 수정
    func update(id: Int, userId: Int, rating: Int, content: String) async throws
    /// 리뷰 삭제
    func delete(id: Int, userId: Int) async throws
    /// 특정 게임의 리뷰 목록(정렬 지원)
    func fetchByGame(gameId: Int, sort: ReviewSort) async throws -> [ReviewResponse]
    /// 특정 사용자의 리뷰 목록
    func fetchByUser(userId: Int) async throws -> [ReviewResponse]
    /// 특정 게임의 리뷰 통계(평균/개수)
    func fetchStats(gameId: Int) async throws -> ReviewStatsResponse
}
