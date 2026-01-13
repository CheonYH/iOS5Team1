//
//  RefreshToken.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//


import Foundation

struct RefreshToken: Sendable {
    let id: Int
    let userId: Int
    let token: String
    let expiresAt: Date
    let createdAt: Date?
    let updatedAt: Date?
}
