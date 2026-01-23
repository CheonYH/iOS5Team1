//
//  Profile.swift
//  iOS5Team1
//
//  Created by cheon on 1/23/26.
//

import Foundation

/// 프로필 정보를 담는 모델입니다.
///
/// 데이터베이스 `profiles` 테이블의 레코드를
/// 서버 내부에서 표현할 때 사용합니다.
struct Profile: Codable {
    /// 프로필 고유 식별자
    let id: Int
    /// 연결된 사용자 ID
    let userId: Int
    /// 표시용 닉네임
    let nickname: String
    /// 프로필 이미지 URL
    let avatarUrl: String?
    /// 생성 시각
    let createdAt: Date?
    /// 수정 시각
    let updatedAt: Date?
}
