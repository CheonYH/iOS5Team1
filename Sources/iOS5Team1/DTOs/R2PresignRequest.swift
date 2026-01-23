//
//  R2PresignRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/23/26.
//

import Vapor

/// R2 presigned URL 발급 요청 DTO입니다.
struct R2PresignRequest: Content {
    /// 업로드 파일명(확장자 추출용)
    let filename: String?
    /// URL 만료 시간(초)
    let expiresIn: Int?
}
