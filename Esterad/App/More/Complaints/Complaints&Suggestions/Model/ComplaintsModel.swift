//
//  ComplaintsModel.swift
//  Esterad
//
//  Created by Haneen on 06/11/2025.
//

import Foundation
import UIKit

struct ComplaintsResponse : Codable {
    let tickets : [ComplaintsModel]
}

struct ComplaintsModel : Codable {
    let id : Int?
    let createdAt : String?
    let status : String?
    let statusText : String?
    let text : String?
    let order : OrderModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case status
        case statusText = "status_text"
        case text
        case order
    }
}

extension ComplaintsModel {
    var complaintsStatus : ComplaintStatus  {
        if status == "open" {
            return .open
        } else if status == "inprogress"{
            return .inProgress
        } else if status == "finished" {
            return .finished
        } else {
            return .open
        }
    }
}

struct OrderModel : Codable {
    let id : Int?
    let date : String?
    let orderNumber : Int?
    let totalPrice : String?
    let status : String?
    let category : String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case orderNumber = "order_number"
        case totalPrice = "total_price"
        case status
        case category
    }
}

enum ComplaintStatus: String {
    case open
    case inProgress = "inprogress"
    case finished
    
    var color: UIColor {
        switch self {
        case .open:
            return UIColor.black
        case .inProgress:
            return UIColor.warning
        case .finished:
            return UIColor.main
        }
    }
}

struct AddComplaintsModel : Codable {
    let subject : String?
    let text : String?
    let orderId : Int?
    let name : String?
    let phone : String?
    
    enum CodingKeys: String, CodingKey {
        case subject
        case text
        case orderId = "order_id"
        case name
        case phone
    }
}

struct AddComplaintsResponse : Codable {
    let ticketId : Int
    
    enum CodingKeys: String, CodingKey {
        case ticketId = "ticket_id"
    }
}

struct ComplaintsDetailsResponse: Codable {
    let ticket : ComplaintsDetails
}

struct ComplaintsDetails : Codable {
    let id : Int?
    let createdAt : String?
    let status : String?
    let statusText : String?
    let otherMemberName : String?
    let otherMemberAvatar : String?
    let subject : String?
    let text : String?
    let reply : String?
    let images : [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case status
        case statusText = "status_text"
        case otherMemberName = "other_member_name"
        case otherMemberAvatar = "other_member_avatar"
        case subject
        case text
        case reply
        case images
    }
}

