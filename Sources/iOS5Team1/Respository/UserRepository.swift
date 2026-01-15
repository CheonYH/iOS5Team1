//
//  UserRepository..swift
//  iOS5Team1
//
//  Created by cheon on 1/10/26.
//

import Foundation
import SQLKit

protocol UserRepository: Sendable {
    func exists(email: String) async throws -> Bool
    func exists(nickname: String) async throws -> Bool
    func create(email: String, password: String, nickname: String) async throws -> User
    func findByEmail(_ email: String) async throws -> User?
}


