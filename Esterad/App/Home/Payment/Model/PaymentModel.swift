//
//  PaymentModel.swift
//  Esterad
//
//  Created by Haneen on 27/11/2025.
//

import Foundation

enum PaymentTypes : CaseIterable{
    case wallet
    case online
    
    var apiValue : String {
        switch self {
        case .wallet:
            return "wallet"
        case .online:
            return "online"
        }
    }
    
    var stringValue : String {
        switch self {
        case .wallet:
            return "wallet".localized
        case .online:
            return "credit_card".localized
        }
    }
}

struct PaymentModel : Codable {
    let productId : Int
    let paymentType : String
    let type : String
    
    enum CodingKeys: String, CodingKey {
        case productId = "product_id"
        case paymentType = "payment_type"
        case type
    }
}
