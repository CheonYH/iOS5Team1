//
//  TokenPair.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Foundation
import Vapor

struct TokenPair: Content {
    let access: String
    let refresh: String
}
