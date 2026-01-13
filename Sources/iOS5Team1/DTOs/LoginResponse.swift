//
//  LoginResponse.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor

struct LoginResponse: Content {
    let success: Bool
    let message: String
}
