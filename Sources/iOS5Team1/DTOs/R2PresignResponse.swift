//
//  R2PresignResponse.swift
//  iOS5Team1
//
//  Created by cheon on 1/23/26.
//

import Vapor

/// R2 presigned URL 응답 DTO입니다.
struct R2PresignResponse: Content {
    /// PUT 업로드용 URL
    let uploadUrl: String
    /// 업로드된 객체 키
    let key: String
    /// 공개 접근 URL(선택)
    let publicUrl: String?
    /// URL 만료 시간(초)
    let expiresIn: Int
}
