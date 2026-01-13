//
//  UpdateReviewRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor

struct UpdateReviewRequest: Content {
    let rating: Int
    let content: String
}
