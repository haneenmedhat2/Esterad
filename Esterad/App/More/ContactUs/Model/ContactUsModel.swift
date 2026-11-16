//
//  ContactUsModel.swift
//  Esterad
//
//  Created by Haneen on 09/11/2025.
//

import Foundation

struct ContactUsModel : Codable {
    let name : String?
    let phone : String?
    let message : String?
    let title : String?
}

struct SocialResponse : Codable {
    let socials : [Social]
}

struct Social : Codable {
    let id : Int
    let link : String?
    let name : String?
    let image : String?
}

