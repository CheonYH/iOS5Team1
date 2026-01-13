//
//  ReviewService.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor



protocol ReviewService: Sendable {

    func create(request: CreateReviewRequest, userId: Int) async throws -> ReviewResponse
    func update(id: Int, request: UpdateReviewRequest, userId: Int) async throws
    func delete(id: Int, userId: Int) async throws
    func fetchByGame(gameId: Int, sort: ReviewSort) async throws -> [ReviewResponse]
    func fetchByUser(userId: Int) async throws -> [ReviewResponse]
    func fetchStats(gameId: Int) async throws -> ReviewStatsResponse
}

extension ReviewService {
    func fetchByGame(gameId: Int) async throws -> [ReviewResponse] {
        try await fetchByGame(gameId: gameId, sort: .latest)
    }
}
