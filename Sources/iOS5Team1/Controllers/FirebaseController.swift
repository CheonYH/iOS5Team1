//
//  File.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

struct FirebaseController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("firebase", "config") { req async throws -> Response in
            guard let apiKey = req.application.storage[FirebaseAPIKey.self] else {
                throw Abort(.internalServerError)
            }

            struct FirebaseConfig: Content {
                let apiKey: String
            }

            return Response(status: .ok, body: .init(data: try JSONEncoder().encode(FirebaseConfig(apiKey: apiKey))))
        }
    }
}
