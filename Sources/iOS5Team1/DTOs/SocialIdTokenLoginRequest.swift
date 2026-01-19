//
//  SocialIdTokenLoginRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

struct SocialIdTokenLoginRequest: Content {
    let idToken: String
    let provider: SocialProvider
}
