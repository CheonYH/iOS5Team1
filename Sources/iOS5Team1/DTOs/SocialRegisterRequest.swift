//
//  SocialRegisterRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

struct SocialRegisterRequest: Content {
    let provider: String
    let providerUid: String
    let nickname: String
    let email: String
}
