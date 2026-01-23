//
//  CreateProfileRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/23/26.
//

import Vapor

/// 프로필 생성 요청 DTO입니다.
struct CreateProfileRequest: Content {
    /// 프로필 닉네임
    let nickname: String
    /// 프로필 이미지 URL
    let avatarUrl: String?
}
