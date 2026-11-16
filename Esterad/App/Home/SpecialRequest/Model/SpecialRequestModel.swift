//
//  SpecialRequestModel.swift
//  Esterad
//
//  Created by Haneen on 25/11/2025.
//

import Foundation

struct SpecialRequestModel : Codable {
    let delegateId : Int
    let categoryId : Int
    let type : String
    let productType : String
    let productDesc : String
    let productQty : Int
    let expectedBudget : Double?
    let notes : String?
    
    enum CodingKeys: String, CodingKey {
        case delegateId = "delegate_id"
        case categoryId = "category_id"
        case type
        case productType = "product_type"
        case productDesc = "product_desc"
        case productQty = "product_qty"
        case expectedBudget = "expected_budget"
        case notes
    }
}

struct SpecialRequestResponse : Codable {
    let orderId : Int?
    let paytabs : PayTabsModel?
    
    enum CodingKeys: String, CodingKey {
        case orderId = "order_id"
        case paytabs
    }
}

enum OrderType : CaseIterable{
    case normal
    case special
    
    var apiValue : String {
        switch self {
        case .normal:
            return "normal"
        case .special:
            return "special"
        }
    }
    
    var stringValue : String {
        switch self {
        case .normal:
            return "normal_requests".localized
        case .special:
            return "special_requests".localized
        }
    }
}


struct SpecialOrderPlaceholderRes : Codable {
    let placeholder : String?
}
