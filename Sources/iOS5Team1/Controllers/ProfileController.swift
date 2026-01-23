//
//  ProfileController.swift
//  iOS5Team1
//
//  프로필 생성/조회/수정 API를 제공하는 컨트롤러입니다.
//  JWT 인증이 필요한 보호된 라우트만 노출합니다.

import Vapor

/// 프로필 관련 라우트를 등록하고 요청을 처리합니다.
///
/// - Important:
/// 이 컨트롤러의 모든 엔드포인트는 JWT 인증을 요구합니다.
struct ProfileController: RouteCollection, Sendable {

    /// 프로필 데이터 접근용 리포지토리
    let profiles: any ProfileRepository
    /// 사용자 데이터 접근용 리포지토리
    let users: any UserRepository
    /// R2 삭제 처리용 서비스(선택)
    let r2Service: R2Service?

    /// 라우트를 등록합니다.
    func boot(routes: any RoutesBuilder) throws {
        let profile = routes.grouped("profile")
        let protected = profile.grouped(JWTMiddleware())
        protected.post(use: create)
        protected.get(use: fetch)
        protected.patch(use: update)
    }

    /// 내 프로필을 생성합니다.
    func create(req: Request) async throws -> ProfileResponse {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)

        guard let userId = Int(payload.sub.value) else {
            throw Abort(.unauthorized)
        }

        let body = try req.content.decode(CreateProfileRequest.self)
        if let _ = try await profiles.findByUserId(userId) {
            throw Abort(.conflict, reason: "이미 존재하는 프로필입니다.")
        }

        let profile = try await profiles.create(
            userId: userId,
            nickname: body.nickname,
            avatarUrl: body.avatarUrl
        )

        return ProfileResponse(
            id: profile.id,
            userId: profile.userId,
            nickname: profile.nickname,
            avatarUrl: profile.avatarUrl
        )
    }

    /// 내 프로필을 조회합니다.
    func fetch(req: Request) async throws -> ProfileResponse {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)

        guard let userId = Int(payload.sub.value) else {
            throw Abort(.unauthorized)
        }

        guard let profile = try await profiles.findByUserId(userId) else {
            throw Abort(.notFound, reason: "존재하지 않은 프로필입니다.")
        }

        return ProfileResponse(
            id: profile.id,
            userId: profile.userId,
            nickname: profile.nickname,
            avatarUrl: profile.avatarUrl
        )
    }

    /// 내 프로필을 수정합니다.
    func update(req: Request) async throws -> ProfileResponse {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)

        guard let userId = Int(payload.sub.value) else {
            throw Abort(.unauthorized)
        }

        let body = try req.content.decode(UpdateProfileRequest.self)
        let current = try await profiles.findByUserId(userId)

        let updated = try await profiles.update(
            userId: userId,
            nickname: body.nickname,
            avatarUrl: body.avatarUrl
        )

        if let newNickname = body.nickname {
            // users.nickname과 동기화를 유지합니다.
            try await users.updateNickname(userId: userId, nickname: newNickname)
        }

        if let newAvatar = body.avatarUrl,
           let oldAvatar = current?.avatarUrl,
           newAvatar != oldAvatar,
           let r2Key = r2Service?.extractKey(from: oldAvatar) {
            try await r2Service?.deleteObject(key: r2Key)
        }

        return ProfileResponse(
            id: updated.id,
            userId: updated.userId,
            nickname: updated.nickname,
            avatarUrl: updated.avatarUrl
        )
    }

}
