//
//  ReviewController.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//
import Vapor

struct ReviewController: RouteCollection, Sendable {
    let service: any ReviewService

    func boot(routes: any RoutesBuilder) throws {
        let reviews = routes.grouped("reviews")

        let protected = reviews.grouped(JWTMiddleware())

        protected.post(use: create)
        protected.patch(":id", use: update)
        protected.delete(":id", use: delete)

        reviews.get("game", ":gameId", use: fetchByGame)
        reviews.get("game", ":gameId", "stats", use: fetchStats)
        protected.get("me", use: fetchByUser)
    }

    func create(req: Request) async throws -> ReviewResponse {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)
        guard let userId = Int(payload.subject.value) else {
            throw Abort(.unauthorized, reason: "Invalid token payload")
        }

        let body = try req.content.decode(CreateReviewRequest.self)
        let review = try await service.create(request: body, userId: userId)
        return review // 필요하면 Response(status: .created, ...) 패턴 적용
    }

    func update(req: Request) async throws -> HTTPStatus {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)
        guard let userId = Int(payload.subject.value) else {
            throw Abort(.unauthorized)
        }

        let id = try req.parameters.require("id", as: Int.self)
        let body = try req.content.decode(UpdateReviewRequest.self)

        try await service.update(id: id, request: body, userId: userId)
        return .ok
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)
        guard let userId = Int(payload.subject.value) else {
            throw Abort(.unauthorized)
        }

        let id = try req.parameters.require("id", as: Int.self)
        try await service.delete(id: id, userId: userId)
        return .noContent
    }

    func fetchByUser(req: Request) async throws -> [ReviewResponse] {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)
        guard let userId = Int(payload.subject.value) else {
            throw Abort(.unauthorized)
        }
        return try await service.fetchByUser(userId: userId)
    }


    func fetchByGame(req: Request) async throws -> [ReviewResponse] {
        let gameId = try req.parameters.require("gameId", as: Int.self)
        let sort = ReviewSort(rawValue: req.query["sort"] ?? "") ?? .latest
        return try await service.fetchByGame(gameId: gameId, sort: sort)
    }


    func fetchStats(req: Request) async throws -> ReviewStatsResponse {
        let gameId = try req.parameters.require("gameId", as: Int.self)
        return try await service.fetchStats(gameId: gameId)
    }

}

