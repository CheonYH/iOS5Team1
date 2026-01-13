//
//  RefreshTokenRepository.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Foundation
import SQLKit

protocol RefreshTokenRepository: Sendable {
    func create(userId: Int, token: String, expiresAt: Date) async throws
    func delete(_ token: String) async throws
    func deleteAll(for userId: Int) async throws
    func find(_ token: String) async throws -> RefreshToken?
}
