//  CreateReviewRequest.swift
//  iOS5Team1
//
//  리뷰 생성 요청 본문을 표현하는 모델입니다.
//
//  초보자 가이드
//  - rating: 보통 1~5 범위의 정수 평점(프로젝트 정책에 따라 다를 수 있습니다.)

import Vapor

/// 클라이언트가 서버에 새 리뷰를 생성할 때 보내는 데이터 형식
struct CreateReviewRequest: Content {
    /// 대상 게임 식별자
    let gameId: Int
    /// 평점 값(예: 1~5)
    let rating: Int
    /// 리뷰 내용(자유 텍스트)
    let content: String
}
