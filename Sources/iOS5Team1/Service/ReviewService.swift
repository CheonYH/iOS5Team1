//  ReviewService.swift
//  iOS5Team1
//
//  리뷰 비즈니스 로직의 규격(프로토콜)을 정의합니다.
//  실제 구현은 DefaultReviewService에서 담당합니다.
//
//  초보자 가이드
//  - protocol: 메서드 시그니처만 정의하여, 구현을 강제하는 약속입니다.
//  - extension: 공통 기본 구현(디폴트 동작)을 추가할 수 있습니다.

import Vapor

protocol ReviewService: Sendable {

    /// 리뷰 생성
    func create(request: CreateReviewRequest, userId: Int) async throws -> ReviewResponse
    /// 리뷰 수정
    func update(id: Int, request: UpdateReviewRequest, userId: Int) async throws
    /// 리뷰 삭제
    func delete(id: Int, userId: Int) async throws
    /// 특정 게임의 리뷰 목록(정렬 지원)
    func fetchByGame(gameId: Int, sort: ReviewSort) async throws -> [ReviewResponse]
    /// 특정 사용자의 리뷰 목록
    func fetchByUser(userId: Int) async throws -> [ReviewResponse]
    /// 특정 게임의 리뷰 통계(평균/개수)
    func fetchStats(gameId: Int) async throws -> ReviewStatsResponse
}

extension ReviewService {
    /// 정렬 옵션이 없을 때 최신순으로 조회하는 기본 구현
    func fetchByGame(gameId: Int) async throws -> [ReviewResponse] {
        try await fetchByGame(gameId: gameId, sort: .latest)
    }
}
