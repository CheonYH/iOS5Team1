//  AuthService.swift
//  iOS5Team1
//
//  인증 관련 핵심 비즈니스 로직의 규격(프로토콜)을 정의합니다.
//  실제 동작은 구현체(MyAuthService 등)가 담당합니다.

import Foundation
import SQLKit
import Vapor

/// 인증 서비스가 제공해야 할 기능을 정의합니다.
protocol AuthService: Sendable {
    /// 이메일/비밀번호로 로그인하여 토큰 쌍을 발급합니다.
    func login(req: Request, email: String, password: String) async throws -> TokenPair

    /// 리프레시 토큰을 사용해 새로운 토큰 쌍을 발급합니다.
    func refresh(req: Request, refreshToken: String) async throws -> TokenPair

    /// 리프레시 토큰을 폐기(로그아웃)합니다.
    func logout(refreshToken: String) async throws

    /// 사용자 ID로 토큰 쌍을 생성합니다.
    func createTokenPair(req: Request, userId: Int) async throws -> TokenPair

    /// 소셜 로그인 사용자 정보를 생성합니다.
    func createSocial(email: String?, provider: String, providerUid: String, nickname: String) async throws -> User
}
