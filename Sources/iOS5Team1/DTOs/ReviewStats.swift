//  ReviewStats.swift
//  iOS5Team1
//
//  리뷰 정렬 옵션과 간단한 통계 모델을 정의합니다.
//
//  초보자 가이드
//  - enum: 정해진 선택지 중 하나를 고를 때 사용합니다.
//  - Content: Vapor에서 JSON으로 쉽게 주고받기 위한 프로토콜입니다.

import Vapor

/// 리뷰 정렬 방법을 나타내는 열거형
enum ReviewSort: String {
    case latest   // 최신순
    case highest  // 평점 높은 순
    case lowest   // 평점 낮은 순
}

/// 간단한 리뷰 통계 모델(내부 용도)
struct ReviewStats: Content {
    let gameId: Int
    let avgRating: Double
    let reviewCount: Int
}
