//  User.swift
//  iOS5Team1
//
//  사용자 정보를 담는 모델입니다.
//
//  초보자 가이드
//  - password는 로컬 로그인일 때만 사용되며 소셜 로그인 계정은 nil입니다.
//  - provider/providerUid는 소셜 로그인 사용자를 구분하기 위한 값입니다.

import Foundation

struct User: Decodable {
    let id: Int
    let email: String?
    let password: String?        // 소셜은 null
    let nickname: String
    let provider: String?        // local/google/apple 등
    let providerUid: String?     // UID
    let onboardingCompleted: Bool
    let deletedAt: Date?
    let createdAt: Date?
    let updatedAt: Date?
}
