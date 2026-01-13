//
//  File.swift
//  iOS5Team1
//
//  Created by cheon on 1/10/26.
//

import Foundation
import Vapor

struct RegisterRequest: Content {
    let email: String
    let password: String
    let nickname: String
}
