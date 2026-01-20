//  DefaultReviewService.swift
//  iOS5Team1
//
//  리뷰 관련 비즈니스 로직을 구현한 기본 서비스입니다.
//  컨트롤러는 이 서비스를 호출해 리뷰 생성/수정/삭제/조회/통계를 수행합니다.
//
//  초보자 가이드
//  - Service: 비즈니스 규칙을 담는 계층입니다. DB 쿼리는 Repository에 위임합니다.
//  - ReviewRepository: 실제 SQL을 실행하는 계층으로, 이 서비스는 그 결과를 조합해 반환합니다.

import Vapor

/// 리뷰 비즈니스 로직의 기본 구현체입니다.
///
/// - Composition:
///     - repo: 리뷰 저장소
/// - Important:
///     - 생성 후 조회를 통해 응답 모델을 구성합니다.
struct DefaultReviewService: ReviewService {

    /// 리뷰 데이터 접근을 담당하는 리포지토리
    let repo: any ReviewRepository

    /// 리뷰 생성 후, 생성된 리뷰를 다시 조회하여 응답 모델로 반환합니다.
    func create(request: CreateReviewRequest, userId: Int) async throws -> ReviewResponse {
        let id = try await repo.create(
            userId: userId,
            gameId: request.gameId,
            rating: request.rating,
            content: request.content
        )

        // 방금 생성한 리뷰를 조회하여 클라이언트에 상세 정보를 전달
        let reviews = try await fetchByUser(userId: userId)
        guard let review = reviews.first(where: { $0.id == id }) else {
            throw Abort(.internalServerError, reason: "리뷰 조회 실패")
        }
        return review
    }

    /// 리뷰 수정
    func update(id: Int, request: UpdateReviewRequest, userId: Int) async throws {
        try await repo.update(id: id, userId: userId, rating: request.rating, content: request.content)
    }

    /// 리뷰 삭제
    func delete(id: Int, userId: Int) async throws {
        try await repo.delete(id: id, userId: userId)
    }

    /// 특정 게임의 리뷰 목록 조회(정렬 옵션 지원)
    func fetchByGame(gameId: Int, sort: ReviewSort) async throws -> [ReviewResponse] {
        try await repo.fetchByGame(gameId: gameId, sort: sort)
    }

    /// 특정 사용자의 리뷰 목록 조회
    func fetchByUser(userId: Int) async throws -> [ReviewResponse] {
        try await repo.fetchByUser(userId: userId)
    }

    /// 특정 게임의 리뷰 통계(평균 평점/리뷰 개수) 조회
    func fetchStats(gameId: Int) async throws -> ReviewStatsResponse {
        try await repo.fetchStats(gameId: gameId)
    }
}

// MARK: - 편의 메서드(기본 정렬: 최신순)
extension ReviewRepository {
    /// 정렬 옵션을 주지 않으면 최신순으로 조회합니다.
    func fetchByGame(gameId: Int) async throws -> [ReviewResponse] {
        try await fetchByGame(gameId: gameId, sort: .latest)
    }
}
