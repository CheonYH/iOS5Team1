//  IGDBController.swift
//  iOS5Team1
//
//  IGDB API를 프록시로 호출하는 컨트롤러입니다.
//
//  초보자 가이드
//  - 프록시(proxy): 클라이언트가 직접 호출하지 못하는 외부 API를 서버가 대신 호출해 주는 패턴
//  - Client-ID/Bearer 토큰: IGDB 인증에 필요한 헤더 값입니다.

import Vapor

/// IGDB 프록시 API 라우트를 제공하는 컨트롤러입니다.
///
/// - Composition:
///     - /v4/multiquery, /v4/games 엔드포인트
/// - Important:
///     - 요청 본문은 IGDB 쿼리 문자열을 그대로 전달합니다.
struct IGDBController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let v4 = routes.grouped("v4")
        v4.post("multiquery", use: multiquery)
        v4.post("games", use: gameDetail)
    }

    // Multiquery
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

    // Detail query
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
