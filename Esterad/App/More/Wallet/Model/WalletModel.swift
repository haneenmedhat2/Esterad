//
//  WalletModel.swift
//  Esterad
//
//  Created by Haneen on 05/11/2025.
//

import Foundation

struct WalletResponse : Codable {
    let wallet : String
}

struct ChargeWalletResponse : Codable {
    let paytabs : PayTabsModel
}

struct PayTabsModel : Codable {
    let redirectUrl : String?
    let tranRef : String?
    let message : String?
    
    enum CodingKeys: String, CodingKey {
        case redirectUrl = "redirect_url"
        case tranRef = "tran_ref"
        case message
    }
}
