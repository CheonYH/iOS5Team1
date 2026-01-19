//
//  IGDBToken.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

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
        if let cache = cachedToken, cache.expiresAt > Date() {
            return cache.token
        }

        let url = URI(string:
            "https://id.twitch.tv/oauth2/token?client_id=\(clientId)&client_secret=\(clientSecret)&grant_type=client_credentials"
        )

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
