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

/// UserRepository를 저장/조회하기 위한 키
enum UserRepositoryKey: StorageKey {
    typealias Value = any UserRepository
}

/// RefreshTokenRepository를 저장/조회하기 위한 키
enum RefreshTokenRepositoryKey: StorageKey {
    typealias Value = any RefreshTokenRepository
}

/// AuthService를 저장/조회하기 위한 키
enum AuthServiceKey: StorageKey {
    typealias Value = MyAuthService
}

/// ReviewRepository를 저장/조회하기 위한 키
enum ReviewRepositoryKey: StorageKey {
    typealias Value = any ReviewRepository
}

/// ReviewService를 저장/조회하기 위한 키
enum ReviewServiceKey: StorageKey {
    typealias Value = any ReviewService
}

enum FirebaseAPIKey: StorageKey {
    typealias Value = String
}

enum IGDBServiceKey: StorageKey {
    typealias Value = IGDBService
}

struct SocialAuthServiceKey: StorageKey {
    typealias Value = SocialAuthService
}
