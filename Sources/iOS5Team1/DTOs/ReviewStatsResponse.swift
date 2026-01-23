//  ReviewStatsResponse.swift
//  iOS5Team1
//
//  특정 게임의 리뷰 통계를 응답으로 전달하기 위한 모델입니다.
//
//  초보자 가이드
//  - averageRating: 평균 평점(0.0 ~ 5.0 등)
//  - reviewCount: 리뷰의 총 개수

import Vapor

/// 리뷰 통계를 클라이언트로 전달할 때 사용하는 응답 모델
struct ReviewStatsResponse: Content {
    /// 게임 식별자
    let gameId: Int
    /// 평균 평점
    let averageRating: Double
    /// 리뷰 개수
    let reviewCount: Int
    
}
