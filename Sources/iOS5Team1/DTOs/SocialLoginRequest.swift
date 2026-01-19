//
//  SocialLoginRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

struct SocialLoginRequest: Content {
    let provider: String       // "google"
    let providerUid: String    // firebase uid
    let email: String?         // optional
}
