//  ReviewResponse.swift
//  iOS5Team1
//
//  리뷰 정보를 클라이언트로 전달할 때 사용하는 응답 모델입니다.
//
//  초보자 가이드
//  - createdAt/updatedAt: 생성/수정 시각으로, UI에서 정렬/표시에 활용할 수 있습니다.

import Vapor

/// 리뷰 상세 응답 DTO입니다.
///
/// - Composition:
///     - id/userId/gameId: 식별자
///     - rating/content: 리뷰 내용
///     - createdAt/updatedAt: 타임스탬프
/// - Important:
///     - updatedAt은 수정 전에는 nil일 수 있습니다.
struct ReviewResponse: Content {
    /// 리뷰 고유 식별자
    let id: Int
    /// 작성자(사용자) 식별자
    let userId: Int
    /// 대상 게임 식별자
    let gameId: Int
    /// 평점 값(예: 1~5)
    let rating: Int
    /// 리뷰 내용(자유 텍스트)
    let content: String
    /// 생성 시각
    let createdAt: Date
    /// 수정 시각(수정 전이면 nil)
    let updatedAt: Date?
}

