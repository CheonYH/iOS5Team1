//
//  IGDBToken.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

struct IGDBToken: Decodable {
    let access_token: String
    let expires_in: Int
    let token_type: String
}
