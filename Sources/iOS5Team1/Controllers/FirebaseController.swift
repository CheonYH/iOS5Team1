//
//  File.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

struct FirebaseController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("firebase", "config") { req async throws -> FirebaseConfigResponse in
            guard let cfg = req.application.storage[FirebaseConfigKey.self] else {
                throw Abort(.internalServerError)
            }

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
