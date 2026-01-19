//  AuthController.swift
//  iOS5Team1
//
//  인증(회원가입/로그인/토큰 관리/닉네임 중복 확인) 관련 라우트를 담당하는 컨트롤러입니다.
//
//  초보자 가이드
//  - RouteCollection: 여러 API 경로를 묶어 한 번에 등록할 수 있는 Vapor 프로토콜
//  - Request/Response: 클라이언트 ↔ 서버 간 주고받는 데이터 형식
//  - Bcrypt: 비밀번호를 안전하게 저장하기 위한 해시 함수 라이브러리

import Vapor

struct AuthController: RouteCollection, Sendable {

    /// 인증 관련 비즈니스 로직을 수행하는 서비스
    let authService: any AuthService
    /// 사용자 정보를 DB에서 관리하는 리포지토리
    let users: any UserRepository

    /// 이 컨트롤러에서 제공하는 라우트들을 등록합니다.
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth") // /auth
        auth.post("register", use: register)      // POST /auth/register
        auth.post("login", use: login)            // POST /auth/login
        auth.post("refresh", use: refresh)        // POST /auth/refresh
        auth.post("logout", use: logout)          // POST /auth/logout
        auth.post("nickname-check", use: checkNickname) // POST /auth/nickname-check
        auth.post("social", use: socialLogin)
        auth.post("social-register", use: socialRegister)
    }

    /// 회원가입 처리
    /// - 입력: 이메일, 비밀번호, 닉네임
    /// - 출력: 성공 여부와 메시지
    func register(req: Request) async throws -> RegisterResponse {
        let body = try req.content.decode(RegisterRequest.self)

        // 이메일 중복 체크
        guard try await users.exists(email: body.email) == false else {
            return .init(success: false, message: "이미 존재하는 이메일입니다.")
        }

        // 비밀번호 해시 후 저장
        let hashed = try Bcrypt.hash(body.password)
        _ = try await users.create(email: body.email, password: hashed, nickname: body.nickname)

        return .init(success: true, message: "회원가입 성공")
    }

    /// 로그인 처리
    /// - 입력: 이메일, 비밀번호
    /// - 출력: 액세스/리프레시 토큰 쌍(TokenPair)
    func login(req: Request) async throws -> TokenPair {
        let body = try req.content.decode(LoginRequest.self)
        return try await authService.login(req: req, email: body.email, password: body.password)
    }

    /// 리프레시 토큰으로 액세스 토큰 재발급
    func refresh(req: Request) async throws -> TokenPair {
        let body = try req.content.decode(RefreshRequest.self)
        return try await authService.refresh(req: req, refreshToken: body.refreshToken)
    }

    /// 로그아웃 처리: 리프레시 토큰 폐기
    func logout(req: Request) async throws -> HTTPStatus {
        let body = try req.content.decode(RefreshRequest.self)
        try await authService.logout(refreshToken: body.refreshToken)
        return .ok
    }

    /// 닉네임 중복 확인
    func checkNickname(req: Request) async throws -> NicknameAvailabilityResponse {
        let body = try req.content.decode(NicknameCheckRequest.self)

        let exists = try await users.exists(nickname: body.nickname)

        return .init(available: !exists)
    }

    func socialLogin(req: Request) async throws -> Response {
        let body = try req.content.decode(SocialLoginRequest.self)

        // 기존 유저 검색
        if let user = try await users.findByProvider(
            uid: body.providerUid,
            provider: body.provider
        ) {
            // 바로 로그인
            let tokens = try await authService.createTokenPair(req: req, userId: user.id)
            return try await tokens.encodeResponse(for: req)
        }

        // 신규 → 닉네임 입력 필요
        let response = RegistrationNeededResponse(email: body.email ?? "")
        return try await response.encodeResponse(status: .accepted, for: req)
    }


    func socialRegister(req: Request) async throws -> Response {
        let body = try req.content.decode(SocialRegisterRequest.self)

        if try await users.exists(email: body.email) {
            throw Abort(.conflict, reason: "email already exists")
        }

        let user = try await authService.createSocial(
            email: body.email,
            provider: body.provider,
            providerUid: body.providerUid,
            nickname: body.nickname
        )

        let tokens = try await authService.createTokenPair(req: req, userId: user.id)
        return try await tokens.encodeResponse(for: req)
    }

}

