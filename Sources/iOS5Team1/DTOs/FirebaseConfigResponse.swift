//
//  FirebaseConfigResponse.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Vapor

struct FirebaseConfigResponse: Content {
    let apiKey: String
    let appId: String
    let gcmSenderId: String
    let projectId: String
    let storageBucket: String?
}
