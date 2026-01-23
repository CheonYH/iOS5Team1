//
//  UpdateNickNameRequest.swift
//  iOS5Team1
//
//  Created by cheon on 1/22/26.
//

import Vapor

struct UpdateNickNameRequest: Content {
    let nickName: String
}
