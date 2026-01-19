//
//  IGDBController.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

struct IGDBController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let v4 = routes.grouped("v4")
        v4.post("multiquery", use: multiquery)
        v4.post("games", use: gameDetail)
    }

    // Multiquery
    func multiquery(req: Request) async throws -> Response {
        let token = try await req.igdb.getAccessToken(client: req.client)

        var igdbReq = ClientRequest()
        igdbReq.method = .POST
        igdbReq.url = URI(string: "https://api.igdb.com/v4/multiquery")
        igdbReq.headers.replaceOrAdd(name: .authorization, value: "Bearer \(token)")
        igdbReq.headers.replaceOrAdd(name: "Client-ID", value: req.igdb.clientId)
        igdbReq.headers.replaceOrAdd(name: "Content-Type", value: "text/plain")
        igdbReq.body = req.body.data

        let clientRes = try await req.client.send(igdbReq)

        // Server Response 생성
        var res = Response(status: clientRes.status)
        res.headers = clientRes.headers

        if let buffer = clientRes.body {
            res.body = .init(buffer: buffer)
        }

        return res
    }

    // Detail query
    func gameDetail(req: Request) async throws -> Response {
        let token = try await req.igdb.getAccessToken(client: req.client)

        var igdbReq = ClientRequest()
        igdbReq.method = .POST
        igdbReq.url = URI(string: "https://api.igdb.com/v4/games")
        igdbReq.headers.replaceOrAdd(name: .authorization, value: "Bearer \(token)")
        igdbReq.headers.replaceOrAdd(name: "Client-ID", value: req.igdb.clientId)
        igdbReq.headers.replaceOrAdd(name: "Content-Type", value: "text/plain")
        igdbReq.body = req.body.data

        let clientRes = try await req.client.send(igdbReq)

        // Server Response 생성
        var res = Response(status: clientRes.status)
        res.headers = clientRes.headers

        if let buffer = clientRes.body {
            res.body = .init(buffer: buffer)
        }

        return res
    }
}


