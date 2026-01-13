//
//  ReviewStats.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor

enum ReviewSort: String {
    case latest
    case highest
    case lowest
}

struct ReviewStats: Content {
    let gameId: Int
    let avgRating: Double
    let reviewCount: Int
}
