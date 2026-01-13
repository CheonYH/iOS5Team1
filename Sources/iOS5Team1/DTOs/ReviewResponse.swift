//
//  File.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor

struct ReviewResponse: Content {
    let id: Int
    let userId: Int
    let gameId: Int
    let rating: Int
    let content: String
    let createdAt: Date
    let updatedAt: Date?
}
