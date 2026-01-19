//  IGDBService.swift
//  iOS5Team1
//
//  IGDB OAuth 토큰을 발급하고 캐시하는 서비스입니다.
//
//  초보자 가이드
//  - 액세스 토큰은 일정 시간 동안 재사용 가능합니다.
//  - 캐시를 두어 매 요청마다 토큰을 새로 발급하지 않도록 합니다.

import Vapor

actor IGDBService {
    let clientId: String
    let clientSecret: String
    var cachedToken: (token: String, expiresAt: Date)?

    init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }

    func getAccessToken(client: any Client) async throws -> String {
        // 만료 전이면 캐시된 토큰 재사용
        if let cache = cachedToken, cache.expiresAt > Date() {
            return cache.token
        }

        let url = URI(string:
            "https://id.twitch.tv/oauth2/token?client_id=\(clientId)&client_secret=\(clientSecret)&grant_type=client_credentials"
        )

        // IGDB(Twitch) OAuth 토큰 발급 요청
        let res = try await client.post(url)
        let token = try res.content.decode(IGDBToken.self)
        let expiry = Date().addingTimeInterval(TimeInterval(token.expires_in - 60))

        cachedToken = (token: token.access_token, expiresAt: expiry)
        return token.access_token
    }
}

extension Application {
    var igdb: IGDBService {
        get { storage[IGDBServiceKey.self]! }
        set { storage[IGDBServiceKey.self] = newValue }
    }
}

extension Request {
    var igdb: IGDBService {
        application.igdb
    }
}
