//
//  NotificationModel.swift
//  Esterad
//
//  Created by Haneen on 09/12/2025.
//

import Foundation

struct NotificationResponse : Codable {
    let notifications : [NotificationModel]
    let pagination : Pagination
}

struct NotificationModel : Codable {
    let id : String
    let icon : String
    let title : String
    let message : String
    let type : String
    let orderId : Int
    let ticketId : Int
    let notificationType : String
    let createdAt : String
    let productId : Int
    let downPaymentPrice : String
    let available : Bool
    
    enum CodingKeys: String, CodingKey {
        case id, icon, title, message, type , available
        case orderId = "order_id"
        case ticketId = "ticket_id"
        case notificationType = "notification_type"
        case createdAt = "created_at"
        case productId = "product_id"
        case downPaymentPrice = "down_payment_price"
    }
}

extension NotificationModel {
    var notificationEnum: NotificationType? {
        return NotificationType(rawValue: notificationType)
    }
}


struct NotificationCountResponse : Codable {
    let notificationCount : Int?
    let isNewNotification : Bool?
    
    enum CodingKeys: String, CodingKey {
        case notificationCount = "num_not_seen_notifications"
        case isNewNotification = "new_notifications"
    }
}
