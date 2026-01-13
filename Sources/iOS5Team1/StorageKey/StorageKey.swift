//
//  UserRepositoryKey.swift
//  iOS5Team1
//
//  Created by cheon on 1/11/26.
//
import Vapor
import Foundation

enum UserRepositoryKey: StorageKey {
    typealias Value = any UserRepository
}

enum RefreshTokenRepositoryKey: StorageKey {
    typealias Value = any RefreshTokenRepository
}

enum AuthServiceKey: StorageKey {
    typealias Value = MyAuthService
}

enum ReviewRepositoryKey: StorageKey {
    typealias Value = any ReviewRepository
}

enum ReviewServiceKey: StorageKey {
    typealias Value = any ReviewService
}

