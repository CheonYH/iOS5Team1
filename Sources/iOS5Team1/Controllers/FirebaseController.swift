//  FirebaseController.swift
//  iOS5Team1
//
//  Firebase 클라이언트 초기화에 필요한 설정 값을 내려주는 컨트롤러입니다.
//
//  초보자 가이드
//  - 서버에 저장된 Firebase 설정을 앱이 가져가 초기화에 사용합니다.
//  - 민감한 키는 환경 변수에서 읽어 `configure.swift`에서 주입합니다.

import Vapor

struct FirebaseController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("firebase", "config") { req async throws -> FirebaseConfigResponse in
            guard let cfg = req.application.storage[FirebaseConfigKey.self] else {
                throw Abort(.internalServerError)
            }

            // 필요한 필드만 내려 주도록 응답 DTO로 변환합니다.
            return FirebaseConfigResponse(
                apiKey: cfg.apiKey,
                appId: cfg.appId,
                gcmSenderId: cfg.gcmSenderId,
                projectId: cfg.projectId,
                storageBucket: cfg.storageBucket,
                clientId: cfg.clientId
            )
        }
    }
}
