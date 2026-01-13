//
//  CreateReviewRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor

struct CreateReviewRequest: Content {
    let gameId: Int
    let rating: Int
    let content: String
}
