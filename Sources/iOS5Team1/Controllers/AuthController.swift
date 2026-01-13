//
//  UserController.swift
//  iOS5Team1
//
//  Created by cheon on 1/10/26.
//

import Vapor

struct AuthController: RouteCollection, Sendable {

    let authService: any AuthService
    let users: any UserRepository

    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        auth.post("register", use: register)
        auth.post("login", use: login)
        auth.post("refresh", use: refresh)
        auth.post("logout", use: logout)
    }

    func register(req: Request) async throws -> RegisterResponse {
        let body = try req.content.decode(RegisterRequest.self)

        guard try await users.exists(email: body.email) == false else {
            return .init(success: false, message: "이미 존재하는 이메일입니다.")
        }

        let hashed = try Bcrypt.hash(body.password)
        _ = try await users.create(email: body.email, password: hashed, nickname: body.nickname)

        return .init(success: true, message: "회원가입 성공")
    }

    func login(req: Request) async throws -> TokenPair {
        let body = try req.content.decode(LoginRequest.self)
        return try await authService.login(req: req, email: body.email, password: body.password)
    }

    func refresh(req: Request) async throws -> TokenPair {
        let body = try req.content.decode(RefreshRequest.self)
        return try await authService.refresh(req: req, refreshToken: body.refreshToken)
    }

    func logout(req: Request) async throws -> HTTPStatus {
        let body = try req.content.decode(RefreshRequest.self)
        try await authService.logout(refreshToken: body.refreshToken)
        return .ok
    }
}


