//
//  UpdateProfileRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/23/26.
//

import Vapor

/// 프로필 수정 요청 DTO입니다.
struct UpdateProfileRequest: Content {
    /// 변경할 닉네임(선택)
    let nickname: String?
    /// 변경할 프로필 이미지 URL(선택)
    let avatarUrl: String?
}
