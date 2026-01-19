//
//  VerifiedSocialUser.swift
//  iOS5Team1
//
//  Created by cheon on 1/19/26.
//

import Foundation

struct VerifiedSocialUser {
    let uid: String          // provider unique ID
    let email: String?
    let isEmailVerified: Bool?
    let provider: SocialProvider
}
