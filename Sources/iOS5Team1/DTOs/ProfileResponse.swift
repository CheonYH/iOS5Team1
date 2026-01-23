//
//  ProfileResponse.swift
//  iOS5Team1
//
//  Created by cheon on 1/23/26.
//

import Vapor

/// 프로필 응답 DTO입니다.
struct ProfileResponse: Content {
    /// 프로필 고유 식별자
    let id: Int
    /// 연결된 사용자 ID
    let userId: Int
    /// 표시용 닉네임
    let nickname: String
    /// 프로필 이미지 URL
    let avatarUrl: String?
}
