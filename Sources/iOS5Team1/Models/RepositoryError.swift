//
//  RepositoryError.swift
//  iOS5Team1
//
//  Created by cheon on 1/13/26.
//

import Vapor

enum RepositoryError: Error {
    case queryFailed
    case insertFailed
    case notFound
    case conflict
    case invalidData
}
