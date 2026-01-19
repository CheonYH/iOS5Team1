//
//  File.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Foundation

struct User: Decodable {
    let id: Int
    let email: String?
    let password: String?        // 소셜은 null
    let nickname: String
    let provider: String?        // local/google/apple 등
    let providerUid: String?     // UID
    let createdAt: Date?
    let updatedAt: Date?
}

