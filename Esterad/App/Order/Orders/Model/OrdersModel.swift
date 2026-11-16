//
//  OrdersModel.swift
//  Esterad
//
//  Created by Haneen on 30/11/2025.
//

import Foundation

enum OrderStatus: String {
    case open
    case accepted = "pending_confirmation"
    case refused
    case rejectedCost
    case pendingConfirmation
    case inprogress
    case finished
    case closed
    
    var apiValue: String {
        switch self {
        case .open: return "open"
        case .pendingConfirmation: return "pending_confirmation"
        case .inprogress: return "inprogress"
        case .finished: return "finished"
        case .closed: return "closed"
        case .accepted: return "accepted"
        case .refused: return "refused"
        case .rejectedCost: return "rejected_cost"
        }
    }
    
    var stringValue: String {          
        switch self {
        case .open: return "status_new".localized
        case .pendingConfirmation: return "status_pending_confirmation".localized
        case .inprogress: return "status_in_progress".localized
        case .finished: return "status_completed".localized
        case .closed: return "status_canceled".localized
        case .accepted: return "accepted"
        case .refused: return "refused"
        case .rejectedCost: return "rejected_cost"
        }
    }
}

struct OrdersResponse : Codable {
    let orders : [Orders]
    let pagination : Pagination
}


struct Orders : Codable {
    let id : Int?
    let createdAt : String?
    let orderNum : String?
    let categoryName : String?
    let type : String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case orderNum = "order_num"
        case categoryName = "category_name"
        case type
       
    }
}
