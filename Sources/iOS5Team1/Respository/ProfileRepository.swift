//
//  ProfileRepository.swift
//  iOS5Team1
//
//  Created by cheon on 1/23/26.
//

import Foundation

/// 프로필 데이터 접근 규약입니다.
protocol ProfileRepository: Sendable {
    /// 사용자 ID로 프로필을 조회합니다.
    func findByUserId(_ userId: Int) async throws -> Profile?
    /// 프로필을 생성합니다.
    func create(userId: Int, nickname: String, avatarUrl: String?) async throws -> Profile
    /// 프로필을 수정합니다.
    func update(userId: Int, nickname: String?, avatarUrl: String?) async throws -> Profile
}
