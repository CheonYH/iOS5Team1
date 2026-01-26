//  AuthController.swift
//  iOS5Team1
//
//  인증(회원가입/로그인/토큰 관리/닉네임 중복 확인) API를 담당하는 컨트롤러입니다.

import Vapor

/// 소셜 인증 과정에서 발생하는 오류 타입입니다.
enum SocialAuthError: Error {
    case registrationNeeded(email: String)
    case invalidToken
    case unsupportedProvider
}

/// 인증 관련 라우트를 등록하고 처리합니다.
struct AuthController: RouteCollection, Sendable {

    /// 인증 관련 비즈니스 로직 서비스
    let authService: any AuthService
    /// 사용자 데이터 리포지토리
    let users: any UserRepository
    /// 프로필 데이터 리포지토리
    let profiles: any ProfileRepository

    /// 소셜 로그인 처리 서비스
    let socialAuthService: SocialAuthService

    /// 라우트를 등록합니다.
    func boot(routes: any RoutesBuilder) throws {
        let auth = routes.grouped("auth") // /auth
        auth.post("register", use: register)      // POST /auth/register
        auth.post("login", use: login)            // POST /auth/login
        auth.post("refresh", use: refresh)        // POST /auth/refresh
        auth.post("logout", use: logout)          // POST /auth/logout
        auth.post("nickname-check", use: checkNickname) // POST /auth/nickname-check
        auth.post("social", use: socialLogin)
        auth.post("social-register", use: socialRegister)


        let protected = auth.grouped(JWTMiddleware())
        protected.post("nickname-update", use: updateNickname)

    }

    /// 회원가입을 처리합니다.
    func register(req: Request) async throws -> RegisterResponse {
        let body = try req.content.decode(RegisterRequest.self)

        // 이메일 중복 체크
        guard try await users.exists(email: body.email) == false else {
            return .init(success: false, message: "이미 존재하는 이메일입니다.")
        }

        // 비밀번호 해시 후 저장
        let hashed = try Bcrypt.hash(body.password)
        let user = try await users.create(email: body.email, password: hashed, nickname: body.nickname)
        _ = try await profiles.create(userId: user.id, nickname: body.nickname, avatarUrl: nil)

        return .init(success: true, message: "회원가입 성공")
    }

    /// 로그인 후 액세스/리프레시 토큰을 반환합니다.
    func login(req: Request) async throws -> TokenPair {
        let body = try req.content.decode(LoginRequest.self)
        storeDeviceIDIfNeeded(req: req, deviceId: body.deviceId)
        return try await authService.login(req: req, email: body.email, password: body.password)
    }

    /// 리프레시 토큰으로 액세스 토큰을 재발급합니다.
    func refresh(req: Request) async throws -> TokenPair {
        let body = try req.content.decode(RefreshRequest.self)
        storeDeviceIDIfNeeded(req: req, deviceId: body.deviceId)
        return try await authService.refresh(req: req, refreshToken: body.refreshToken)
    }

    /// 로그아웃 처리(리프레시 토큰 폐기)입니다.
    func logout(req: Request) async throws -> HTTPStatus {
        let body = try req.content.decode(RefreshRequest.self)
        try await authService.logout(refreshToken: body.refreshToken)
        return .ok
    }

    /// 닉네임 중복 여부를 확인합니다.
    func checkNickname(req: Request) async throws -> NicknameAvailabilityResponse {
        let body = try req.content.decode(NicknameCheckRequest.self)

        let exists = try await users.exists(nickname: body.nickname)

        return .init(available: !exists)
    }

    /// 소셜 로그인 진입점입니다.
    func socialLogin(req: Request) async throws -> Response {
        let body = try req.content.decode(SocialIdTokenLoginRequest.self)
        storeDeviceIDIfNeeded(req: req, deviceId: body.deviceId)
        let provider = body.provider

        let verified = try await socialAuthService.verifySocial(
            req: req,
            provider: provider,
            idToken: body.idToken
        )

        if let user = try await users.findByProvider(uid: verified.uid, provider: provider.rawValue) {
            let tokens = try await authService.createTokenPair(req: req, userId: user.id)
            return Response(status: .ok, body: .init(data: try JSONEncoder().encode(tokens)))
        }

        if let email = verified.email, try await users.exists(email: email) {
            throw Abort(.conflict, reason: "이미 존재하는 이메일입니다.")
        }

        let json = [
            "status": "registration_needed",
            "provider": provider.rawValue,
            "providerUid": verified.uid,
            "email": verified.email ?? NSNull()
        ] as [String: Any]

        return Response(
            status: .accepted,
            body: .init(data: try JSONSerialization.data(withJSONObject: json))
        )
    }

    /// 소셜 회원가입을 처리합니다.
    func socialRegister(req: Request) async throws -> TokenPair {
        let body = try req.content.decode(SocialRegisterRequest.self)
        storeDeviceIDIfNeeded(req: req, deviceId: body.deviceId)

        guard let provider = SocialProvider(rawValue: body.provider) else {
            throw Abort(.badRequest, reason: "Invalid provider")
        }

        if let email = body.email, try await users.exists(email: email) {
            throw Abort(.conflict, reason: "이미 존재하는 이메일입니다.")
        }

        let user = try await users.createSocial(
            email: body.email,
            provider: provider.rawValue,
            providerUid: body.providerUid,
            nickname: body.nickname
        )
        _ = try await profiles.create(userId: user.id, nickname: body.nickname, avatarUrl: nil)

        return try await authService.createTokenPair(req: req, userId: user.id)
    }

    /// 사용자 닉네임을 변경합니다.
    func updateNickname(req: Request) async throws -> HTTPStatus {
        let paylooad = try await req.jwt.verify(as: AccessTokenPayload.self)
        guard let userId = Int(paylooad.sub.value) else {
            throw Abort(.unauthorized)
        }

        let body = try req.content.decode(UpdateNickNameRequest.self)
        let exists = try await users.exists(nickname: body.nickName)

        guard !exists else {
            throw Abort(.conflict, reason: "이미 사용중인 닉네임 입니다.")
        }

        try await users.updateNickname(userId: userId, nickname: body.nickName)
        return .ok
    }

    private func storeDeviceIDIfNeeded(req: Request, deviceId: String?) {
        guard req.headers["X-Device-ID"].first == nil, let deviceId, !deviceId.isEmpty else {
            return
        }
        req.storage[RequestDeviceIDKey.self] = deviceId
    }

}
