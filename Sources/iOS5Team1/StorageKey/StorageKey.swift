//  StorageKey.swift
//  iOS5Team1
//
//  Vapor의 Application.storage에 의존성(리포지토리/서비스)을 저장하기 위한 키 타입들입니다.
//
//  초보자 가이드
//  - StorageKey: 타입 안전하게 전역 저장소에 값을 넣고/꺼내기 위한 키 프로토콜입니다.
//  - app.storage[Key.self] = value 형태로 등록하고, 어디서든 같은 키로 꺼냅니다.

import Vapor
import Foundation

/// UserRepository 저장 키입니다.
///
/// - Composition:
///     - Value = any UserRepository
/// - Important:
///     - app.storage에서 동일 키로 접근합니다.
enum UserRepositoryKey: StorageKey {
    typealias Value = any UserRepository
}

/// RefreshTokenRepository 저장 키입니다.
///
/// - Composition:
///     - Value = any RefreshTokenRepository
/// - Important:
///     - 토큰 저장소는 전역에서 공유됩니다.
enum RefreshTokenRepositoryKey: StorageKey {
    typealias Value = any RefreshTokenRepository
}

/// AuthService 저장 키입니다.
///
/// - Composition:
///     - Value = MyAuthService
/// - Important:
///     - 인증 로직은 싱글 인스턴스로 관리됩니다.
enum AuthServiceKey: StorageKey {
    typealias Value = MyAuthService
}

/// ReviewRepository 저장 키입니다.
///
/// - Composition:
///     - Value = any ReviewRepository
/// - Important:
///     - 리뷰 데이터 접근을 전역에서 공유합니다.
enum ReviewRepositoryKey: StorageKey {
    typealias Value = any ReviewRepository
}

/// ReviewService 저장 키입니다.
///
/// - Composition:
///     - Value = any ReviewService
/// - Important:
///     - 서비스 구현체를 교체할 때 사용됩니다.
enum ReviewServiceKey: StorageKey {
    typealias Value = any ReviewService
}

/// Firebase API 키 저장용 키입니다.
///
/// - Composition:
///     - Value = String
/// - Important:
///     - 보안상 로깅/노출을 주의합니다.
enum FirebaseAPIKey: StorageKey {
    typealias Value = String
}

/// IGDBService 저장 키입니다.
///
/// - Composition:
///     - Value = IGDBService
/// - Important:
///     - IGDB 토큰 캐시를 공유합니다.
enum IGDBServiceKey: StorageKey {
    typealias Value = IGDBService
}

/// SocialAuthService 저장 키입니다.
///
/// - Composition:
///     - Value = SocialAuthService
/// - Important:
///     - 소셜 로그인 검증에 사용됩니다.
struct SocialAuthServiceKey: StorageKey {
    typealias Value = SocialAuthService
}
