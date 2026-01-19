//
//  IGDBController.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

struct IGDBController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.post("igdb", ":endpoint") { req async throws -> Response in
            guard let endpoint = req.parameters.get("endpoint") else {
                throw Abort(.badRequest)
            }

            let token = try await req.igdb.getAccessToken(client: req.client)

            let body = req.body.data ?? ByteBuffer()
            let url = URI(string: "https://api.igdb.com/v4/\(endpoint)")

            let igdbResponse = try await req.client.post(url) { igdbReq in
                igdbReq.headers.add(name: "Client-ID", value: req.igdb.clientId)
                igdbReq.headers.add(name: "Authorization", value: "Bearer \(token)")
                igdbReq.headers.add(name: "Content-Type", value: "text/plain")
                igdbReq.body = body
            }

            var res = Response(status: igdbResponse.status)

            res.headers = igdbResponse.headers
            if let buffer = igdbResponse.body {
                res.body = .init(buffer: buffer)
            }

            return res
        }
    }
}

