//
//  SocialAuthProvider.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

enum SocialProvider: String, Codable {
    case google
    case apple
    case kakao
    case naver
}


protocol SocialAuthProvider: Sendable {
    func verify(req: Request, idToken: String) async throws -> VerifiedSocialUser
}


