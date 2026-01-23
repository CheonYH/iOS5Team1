//  UserRepository.swift
//  iOS5Team1
//
//  사용자(User) 데이터를 DB에서 다루기 위한 리포지토리 규격(프로토콜)입니다.
//  실제 구현은 MySQLUserRepository에서 담당합니다.
//
//  초보자 가이드
//  - exists: 중복 여부를 확인할 때 사용합니다.

import Foundation
import SQLKit

protocol UserRepository: Sendable {
    /// 이메일 중복 여부 확인
    func exists(email: String) async throws -> Bool
    /// 닉네임 중복 여부 확인
    func exists(nickname: String) async throws -> Bool
    /// 사용자 생성
    func create(email: String, password: String, nickname: String) async throws -> User
    /// 이메일로 사용자 조회
    func findByEmail(_ email: String) async throws -> User?

    func findByProvider(uid: String, provider: String) async throws -> User?

    func createSocial(email: String?, provider: String, providerUid: String, nickname: String) async throws -> User

    func updateNickname(userId: Int, nickname: String) async throws 

}

