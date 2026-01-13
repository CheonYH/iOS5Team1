//
//  AuthService.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Foundation
import SQLKit
import Vapor

protocol AuthService: Sendable {
    func login(req: Request, email: String, password: String) async throws -> TokenPair
    func refresh(req: Request, refreshToken: String) async throws -> TokenPair
    func logout(refreshToken: String) async throws
}
