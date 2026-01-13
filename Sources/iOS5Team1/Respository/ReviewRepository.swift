//
//  ReviewRepository.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor

protocol ReviewRepository: Sendable {
    func create(userId: Int, gameId: Int, rating: Int, content: String) async throws -> Int
    func update(id: Int, userId: Int, rating: Int, content: String) async throws
    func delete(id: Int, userId: Int) async throws
    func fetchByGame(gameId: Int, sort: ReviewSort) async throws -> [ReviewResponse]
    func fetchByUser(userId: Int) async throws -> [ReviewResponse]
    func fetchStats(gameId: Int) async throws -> ReviewStatsResponse
}
