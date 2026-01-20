//  UpdateReviewRequest.swift
//  iOS5Team1
//
//  리뷰 수정 요청 본문을 표현하는 모델입니다.
//
//  초보자 가이드
//  - PATCH /reviews/:id 요청에 바디로 함께 전송됩니다.

import Vapor

/// 리뷰 수정 시 클라이언트가 보내는 데이터 형식
/// 리뷰 수정 요청 DTO입니다.
///
/// - Composition:
///     - rating/content
/// - Important:
///     - 요청 대상 리뷰 ID는 URL 경로에서 전달됩니다.
struct UpdateReviewRequest: Content {
    /// 수정할 평점 값
    let rating: Int
    /// 수정할 리뷰 내용
    let content: String
}
