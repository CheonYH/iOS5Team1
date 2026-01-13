//
//  JWTMiddleware.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor

struct JWTMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        _ = try await req.jwt.verify(as: AccessTokenPayload.self)
        return try await next.respond(to: req)
    }
}
