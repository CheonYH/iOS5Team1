//
//  StandardErrorMiddleware.swift
//  iOS5Team1
//
//  Standardizes error responses into a predictable JSON shape.
//

import Vapor
import JWT

private struct ErrorEnvelope: Content {
    let error: ErrorPayload
}

private struct ErrorPayload: Content {
    let code: String
    let message: String
    let details: [String: String]?
    let requestId: String?
}

/// Converts thrown errors into a standard JSON error response.
struct StandardErrorMiddleware: AsyncMiddleware {
    func respond(to req: Request, chainingTo next: any AsyncResponder) async throws -> Response {
        do {
            return try await next.respond(to: req)
        } catch {
            return Self.makeResponse(for: error, req: req)
        }
    }

    private static func makeResponse(for error: Error, req: Request) -> Response {
        let (status, code, message, details) = classify(error)
        let payload = ErrorEnvelope(
            error: ErrorPayload(
                code: code,
                message: message,
                details: details,
                requestId: req.id.uuidString
            )
        )

        var res = Response(status: status)
        res.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")

        do {
            res.body = try Response.Body(data: JSONEncoder().encode(payload))
        } catch {
            res.body = .init(string: "{\"error\":{\"code\":\"INTERNAL_ERROR\",\"message\":\"Internal server error\"}}")
        }

        return res
    }

    private static func classify(_ error: Error) -> (HTTPStatus, String, String, [String: String]?) {
        if let abort = error as? AbortError {
            let status = abort.status
            let reason = abort.reason.isEmpty ? status.reasonPhrase : abort.reason
            let (code, details) = mapCode(status: status, reason: reason)
            return (status, code, reason, details)
        }

        if error is JWTError {
            return (.unauthorized, "AUTH_TOKEN_INVALID", "Invalid token", nil)
        }

        return (.internalServerError, "INTERNAL_ERROR", "Internal server error", nil)
    }

    private static func mapCode(status: HTTPStatus, reason: String) -> (String, [String: String]?) {
        switch reason {
        case "email or password incorrect":
            return ("AUTH_INVALID_CREDENTIALS", ["field": "email"])
        case "this account uses social login":
            return ("AUTH_SOCIAL_ONLY", nil)
        case "invalid refresh token", "refresh revoked", "refresh expired":
            return ("AUTH_REFRESH_INVALID", nil)
        case "Invalid aud", "Invalid iss":
            return ("AUTH_SOCIAL_INVALID", nil)
        case "Invalid provider", "unsupported provider":
            return ("AUTH_UNSUPPORTED_PROVIDER", nil)
        case "이미 존재하는 이메일입니다.":
            return ("AUTH_EMAIL_EXISTS", ["field": "email"])
        case "이미 사용중인 닉네임 입니다.":
            return ("AUTH_NICKNAME_EXISTS", ["field": "nickName"])
        case "이미 해당 게임에 작성된 리뷰가 존재합니다.":
            return ("REVIEW_DUPLICATE", nil)
        case "이미 존재하는 프로필입니다.":
            return ("PROFILE_ALREADY_EXISTS", nil)
        case "존재하지 않은 프로필입니다.":
            return ("PROFILE_NOT_FOUND", nil)
        case "Missing required Firebase ENV variables":
            return ("FIREBASE_ENV_MISSING", nil)
        default:
            switch status {
            case .unauthorized:
                return ("AUTH_TOKEN_INVALID", nil)
            case .badRequest:
                return ("BAD_REQUEST", nil)
            case .notFound:
                return ("NOT_FOUND", nil)
            case .conflict:
                return ("CONFLICT", nil)
            default:
                return ("INTERNAL_ERROR", nil)
            }
        }
    }
}
