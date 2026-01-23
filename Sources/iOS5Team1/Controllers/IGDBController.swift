//  IGDBController.swift
//  iOS5Team1
//
//  IGDB API를 프록시로 호출하는 컨트롤러입니다.
//  클라이언트가 직접 호출하기 어려운 IGDB 엔드포인트를 서버가 대행합니다.

import Vapor

/// IGDB 프록시 라우트를 등록합니다.
struct IGDBController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let v4 = routes.grouped("v4")
        v4.post("multiquery", use: multiquery)
        v4.post("games", use: gameDetail)
    }

    /// IGDB multiquery를 프록시합니다.
    func multiquery(req: Request) async throws -> Response {
        // IGDB 액세스 토큰을 캐시에서 가져오거나 새로 발급합니다.
        let token = try await req.igdb.getAccessToken(client: req.client)

        var igdbReq = ClientRequest()
        igdbReq.method = .POST
        igdbReq.url = URI(string: "https://api.igdb.com/v4/multiquery")
        igdbReq.headers.replaceOrAdd(name: .authorization, value: "Bearer \(token)")
        igdbReq.headers.replaceOrAdd(name: "Client-ID", value: req.igdb.clientId)
        igdbReq.headers.replaceOrAdd(name: "Content-Type", value: "text/plain")
        igdbReq.body = req.body.data

        // 외부 IGDB API 호출 결과를 그대로 전달합니다.
        let clientRes = try await req.client.send(igdbReq)

        // Server Response 생성
        let res = Response(status: clientRes.status)
        res.headers = clientRes.headers

        if let buffer = clientRes.body {
            res.body = .init(buffer: buffer)
        }

        return res
    }

    /// IGDB games 조회를 프록시합니다.
    func gameDetail(req: Request) async throws -> Response {
        // IGDB 액세스 토큰을 캐시에서 가져오거나 새로 발급합니다.
        let token = try await req.igdb.getAccessToken(client: req.client)

        var igdbReq = ClientRequest()
        igdbReq.method = .POST
        igdbReq.url = URI(string: "https://api.igdb.com/v4/games")
        igdbReq.headers.replaceOrAdd(name: .authorization, value: "Bearer \(token)")
        igdbReq.headers.replaceOrAdd(name: "Client-ID", value: req.igdb.clientId)
        igdbReq.headers.replaceOrAdd(name: "Content-Type", value: "text/plain")
        igdbReq.body = req.body.data

        // 외부 IGDB API 호출 결과를 그대로 전달합니다.
        let clientRes = try await req.client.send(igdbReq)

        // Server Response 생성
        let res = Response(status: clientRes.status)
        res.headers = clientRes.headers

        if let buffer = clientRes.body {
            res.body = .init(buffer: buffer)
        }

        return res
    }
}
