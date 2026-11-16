//
//  VerificationModel.swift
//  Esterad
//
//  Created by Haneen on 27/10/2025.
//

import Foundation

enum VerificationFlow {
    case signup
    case changePassword
    case activateCurrentPhone
    case activateNewPhone
}

struct VerificationModel: Codable {
    let code : String
    let phone : String
    
    enum CodingKeys: String, CodingKey {
        case code = "code"
        case phone = "phone"
    }
}
