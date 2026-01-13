//
//  LoginRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//
import Foundation
import Vapor

struct LoginRequest: Content {
    let email: String
    let password: String
}
