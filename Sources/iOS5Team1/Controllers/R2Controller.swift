//
//  R2Controller.swift
//  iOS5Team1
//
//  R2(S3 호환) presigned URL 발급 API를 제공하는 컨트롤러입니다.

import Vapor

/// R2 업로드용 presigned URL을 발급합니다.
///
/// 클라이언트는 이 URL로 직접 PUT 업로드를 수행합니다.
struct R2Controller: RouteCollection, Sendable {

    /// presigned URL 생성 서비스
    let service: R2Service

    /// 라우트를 등록합니다.
    func boot(routes: any RoutesBuilder) throws {
        let r2 = routes.grouped("r2")
        let protected = r2.grouped(JWTMiddleware())
        protected.post("presign", use: presign)
    }

    /// presigned PUT URL을 발급합니다.
    func presign(req: Request) async throws -> R2PresignResponse {
        let payload = try await req.jwt.verify(as: AccessTokenPayload.self)

        guard let userId = Int(payload.sub.value) else {
            throw Abort(.unauthorized)
        }

        let body = try req.content.decode(R2PresignRequest.self)
        let fileExt = body.filename?.split(separator: ".").last.map(String.init) ?? "bin"
        let key = "profiles/\(userId)/\(UUID().uuidString.lowercased()).\(fileExt)"

        let expires = body.expiresIn ?? 900
        let uploadUrl = try await service.presignPutURL(key: key, expiresInSeconds: expires)

        return R2PresignResponse(
            uploadUrl: uploadUrl,
            key: key,
            publicUrl: service.config.publicBaseUrl.map { "\($0)/\(key)" },
            expiresIn: expires
        )

    }
}
