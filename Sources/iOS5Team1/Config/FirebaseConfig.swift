//
//  FirebaseConfig.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

/// Firebase 초기화를 위한 내부 설정 모델입니다.
///
/// - Composition:
///     - apiKey/appId/gcmSenderId/projectId/clientId: Firebase 기본 설정
///     - storageBucket: 스토리지 사용 시 필요한 옵션 값
/// - Important:
///     - 외부 응답으로는 `FirebaseConfigResponse`를 사용합니다.
struct FirebaseConfig: Content {
    let apiKey: String
    let appId: String
    let gcmSenderId: String
    let projectId: String
    let storageBucket: String?
    let clientId: String
}

/// Application.storage에 FirebaseConfig를 보관하기 위한 키입니다.
struct FirebaseConfigKey: StorageKey {
    typealias Value = FirebaseConfig
}
