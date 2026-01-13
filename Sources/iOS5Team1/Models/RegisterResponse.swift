//
//  RegisterResponse.swift
//  iOS5Team1
//
//  Created by cheon on 1/10/26.
//

import Foundation
import Vapor

struct RegisterResponse: Content {
    let success: Bool
    let message: String
}
