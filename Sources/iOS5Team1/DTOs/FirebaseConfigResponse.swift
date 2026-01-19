//
//  FirebaseConfigResponse.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

/// Firebase 설정 응답 DTO입니다.
///
/// - Composition:
///     - apiKey/appId/gcmSenderId/projectId/clientId: Firebase 초기화 필드
///     - storageBucket: 스토리지 옵션(없을 수 있음)
/// - Important:
///     - 민감한 값은 환경 변수에서 주입됩니다.
struct FirebaseConfigResponse: Content {
    let apiKey: String
    let appId: String
    let gcmSenderId: String
    let projectId: String
    let storageBucket: String?
    let clientId: String
}
