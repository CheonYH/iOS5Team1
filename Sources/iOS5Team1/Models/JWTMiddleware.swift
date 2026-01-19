//  JWTMiddleware.swift
//  iOS5Team1
//
//  보호가 필요한 라우트에서 JWT 토큰을 검증하는 미들웨어입니다.
//
//  초보자 가이드
//  - Middleware: 요청이 실제 핸들러에 도달하기 전/후에 실행되는 필터 같은 존재입니다.
//  - JWT 검증에 실패하면 401 Unauthorized 에러가 발생합니다.

import Vapor

struct JWTMiddleware: AsyncMiddleware {
    /// 요청을 가로채 JWT 토큰의 유효성을 검사합니다.
    /// 유효하면 다음 핸들러로 넘기고, 아니면 오류를 던집니다.
    func respond(to req: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        _ = try await req.jwt.verify(as: AccessTokenPayload.self)
        return try await next.respond(to: req)
    }
}
