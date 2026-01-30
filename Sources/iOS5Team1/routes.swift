//  routes.swift
//  iOS5Team1
//
//  전역 라우트를 등록하는 파일입니다.
//  각 컨트롤러에서 제공하는 API 엔드포인트를 서버에 연결합니다.
//
//  초보자 가이드
//  - 라우트(Route): URL + HTTP 메서드(GET/POST 등)와 실행 코드를 연결하는 규칙
//  - /health: 서버가 살아있는지 확인하는 간단한 엔드포인트
//  - app.storage: 서버 부팅 시 등록한 의존성(서비스/리포지토리)을 꺼내 쓰는 저장소

import Fluent
import FluentMySQLDriver
import MySQLKit
import SQLKit
import Vapor

/// 앱의 모든 라우트를 등록합니다.
/// 컨트롤러를 생성하고 `app.register(collection:)`으로 묶어 주입합니다.
func routes(_ app: Application) throws {

    // Health Check
    app.get("health") { _ async -> String in
        return "OK"
    }

    // MARK: - Auth 관련 의존성 꺼내기
    guard let authService = app.storage[AuthServiceKey.self] else {
        fatalError("AuthService not registered")
    }
    guard let users = app.storage[UserRepositoryKey.self] else {
        fatalError("UserRepository not registered")
    }
    guard let socialAuthService = app.storage[SocialAuthServiceKey.self] else {
        fatalError("SocialAuthService not registered")
    }
    guard let refreshTokens = app.storage[RefreshTokenRepositoryKey.self] else {
        fatalError("RefreshTokenRepository not registered")
    }

    // Auth 컨트롤러 등록
    guard let profiles = app.storage[ProfileRepositoryKey.self] else {
        fatalError("ProfileRepository not registered")
    }

    let authController = AuthController(
        authService: authService,
        users: users,
        profiles: profiles,
        refreshTokens: refreshTokens,
        socialAuthService: socialAuthService
    )
    try app.register(collection: authController)

    // MARK: - Review 관련 의존성 꺼내기
    guard let reviewService = app.storage[ReviewServiceKey.self] else {
        fatalError("ReviewService not registered")
    }

    let reviewController = ReviewController(service: reviewService)
    try app.register(collection: reviewController)

    // 추가 컨트롤러
    try app.register(collection: IGDBController())
    try app.register(collection: FirebaseController())


    if let r2Service = app.storage[R2ServiceKey.self] {
        try app.register(collection: R2Controller(service: r2Service))
    }

    let r2Service = app.storage[R2ServiceKey.self]
    try app.register(collection: ProfileController(
        profiles: profiles,
        users: users,
        r2Service: r2Service
    ))
}
