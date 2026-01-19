//
//  FirebaseConfig.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

struct FirebaseConfig: Content {
    let apiKey: String
    let appId: String
    let gcmSenderId: String
    let projectId: String
    let storageBucket: String?
    let clientId: String
}

struct FirebaseConfigKey: StorageKey {
    typealias Value = FirebaseConfig
}
