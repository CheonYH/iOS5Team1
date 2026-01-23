//  FirebaseController.swift
//  iOS5Team1
//
//  Firebase 초기화에 필요한 설정을 제공하는 컨트롤러입니다.
//  앱이 서버에서 설정 값을 내려받아 초기화에 사용합니다.

import Vapor

/// Firebase 설정을 내려주는 라우트 모음입니다.
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
