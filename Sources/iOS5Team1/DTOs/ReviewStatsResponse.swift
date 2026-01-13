//
//  ReviewStatsResponse.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//

import Vapor

struct ReviewStatsResponse: Content {
    let gameId: Int
    let averageRating: Double
    let reviewCount: Int
}
