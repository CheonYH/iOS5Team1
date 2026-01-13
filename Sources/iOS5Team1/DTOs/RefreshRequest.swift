//
//  RefreshRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor

struct RefreshRequest: Content {
    let refreshToken: String
}
