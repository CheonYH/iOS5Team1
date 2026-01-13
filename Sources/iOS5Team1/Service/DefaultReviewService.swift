//
//  DefaultReviewService.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor

struct DefaultReviewService: ReviewService {

    let repo: any ReviewRepository

    func create(request: CreateReviewRequest, userId: Int) async throws -> ReviewResponse {
        let id = try await repo.create(
            userId: userId,
            gameId: request.gameId,
            rating: request.rating,
            content: request.content
        )

        let reviews = try await fetchByUser(userId: userId)
        guard let review = reviews.first(where: { $0.id == id }) else {
            throw Abort(.internalServerError, reason: "리뷰 조회 실패")
        }
        return review
    }

    func update(id: Int, request: UpdateReviewRequest, userId: Int) async throws {
        try await repo.update(id: id, userId: userId, rating: request.rating, content: request.content)
    }

    func delete(id: Int, userId: Int) async throws {
        try await repo.delete(id: id, userId: userId)
    }

    func fetchByGame(gameId: Int, sort: ReviewSort) async throws -> [ReviewResponse] {
        try await repo.fetchByGame(gameId: gameId, sort: sort)
    }

    func fetchByUser(userId: Int) async throws -> [ReviewResponse] {
        try await repo.fetchByUser(userId: userId)
    }

    func fetchStats(gameId: Int) async throws -> ReviewStatsResponse {
        try await repo.fetchStats(gameId: gameId)
    }
}


extension ReviewRepository {
    func fetchByGame(gameId: Int) async throws -> [ReviewResponse] {
        try await fetchByGame(gameId: gameId, sort: .latest)
    }
}
