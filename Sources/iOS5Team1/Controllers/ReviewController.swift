//  ReviewController.swift
//  iOS5Team1
//
//  리뷰(생성/수정/삭제/조회/통계) 관련 API를 담당하는 컨트롤러입니다.
//
//  초보자 가이드
//  - JWTMiddleware: 요청에 포함된 JWT 토큰을 검증하여 보호된 라우트를 지킵니다.
//  - grouped("reviews"): 모든 경로 앞에 /reviews가 붙습니다.
//  - req.parameters / req.query: URL 경로/쿼리에서 값을 읽는 방법입니다.

import Vapor

struct ReviewController: RouteCollection, Sendable {
    /// 리뷰 관련 비즈니스 로직을 수행하는 서비스
    let service: any ReviewService

    /// 이 컨트롤러에서 제공하는 라우트들을 등록합니다.
    func boot(routes: any RoutesBuilder) throws {
        let reviews = routes.grouped("reviews")    // /reviews

        // 보호된 라우트: JWT 토큰이 필요한 엔드포인트
        let protected = reviews.grouped(JWTMiddleware())

        protected.post(use: create)                // POST   /reviews
        protected.patch(":id", use: update)       // PATCH  /reviews/:id
        protected.delete(":id", use: delete)     // DELETE /reviews/:id

        reviews.get("game", ":gameId", use: fetchByGame)           // GET /reviews/game/:gameId
        reviews.get("game", ":gameId", "stats", use: fetchStats)  // GET /reviews/game/:gameId/stats
        protected.get("me", use: fetchByUser)                       // GET /reviews/me
    }

    /// 리뷰 생성
    /// - 요구: 유효한 JWT 토큰(사용자 인증)
    func create(req: Request) async throws -> ReviewResponse {
        // 토큰에서 사용자 ID 추출
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)
        guard let userId = Int(payload.sub.value) else {
            throw Abort(.unauthorized, reason: "Invalid token payload")
        }

        // 요청 본문 파싱
        let body = try req.content.decode(CreateReviewRequest.self)
        let review = try await service.create(request: body, userId: userId)
        return review // 필요하면 Response(status: .created, ...) 패턴 적용 가능
    }

    /// 리뷰 수정
    func update(req: Request) async throws -> HTTPStatus {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)
        guard let userId = Int(payload.sub.value) else {
            throw Abort(.unauthorized)
        }

        let id = try req.parameters.require("id", as: Int.self) // URL 경로에서 리뷰 ID 읽기
        let body = try req.content.decode(UpdateReviewRequest.self)

        try await service.update(id: id, request: body, userId: userId)
        return .ok
    }

    /// 리뷰 삭제
    func delete(req: Request) async throws -> HTTPStatus {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)
        guard let userId = Int(payload.sub.value) else {
            throw Abort(.unauthorized)
        }

        let id = try req.parameters.require("id", as: Int.self)
        try await service.delete(id: id, userId: userId)
        return .noContent
    }

    /// 내 리뷰 목록 조회
    func fetchByUser(req: Request) async throws -> [ReviewResponse] {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)
        guard let userId = Int(payload.sub.value) else {
            throw Abort(.unauthorized)
        }
        return try await service.fetchByUser(userId: userId)
    }

    /// 특정 게임의 리뷰 목록 조회 (정렬 옵션 지원)
    func fetchByGame(req: Request) async throws -> [ReviewResponse] {
        let gameId = try req.parameters.require("gameId", as: Int.self)
        let sort = ReviewSort(rawValue: req.query["sort"] ?? "") ?? .latest
        return try await service.fetchByGame(gameId: gameId, sort: sort)
    }

    /// 특정 게임의 리뷰 통계 조회(평균/개수)
    func fetchStats(req: Request) async throws -> ReviewStatsResponse {
        let gameId = try req.parameters.require("gameId", as: Int.self)
        return try await service.fetchStats(gameId: gameId)
    }
}

