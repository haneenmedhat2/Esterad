//
//  FCMKeys.swift
//  Esterad
//
//  Created by Haneen on 27/10/2025.
//

import Foundation

enum FCMValueKeys: String {
    case id
    case type
    case orderId = "order_id"
    case ticketId = "ticket_id"
    case titleEn = "title_en"
    case titleAr = "title_ar"
    case meesageEn = "message_en"
    case messageAr = "message_ar"
    case roomId = "room_id"
    case senderName = "sender_name"
    case productId = "product_id"
    case downPaymentPrice = "down_payment_price"
}

enum NotificationType: String, Codable {
    case delegateFinishedOrder = "delegate_finished_order"
    case delegateMadeOffer = "delegate_made_offer"
    case delegateRefusedOrder = "delegate_refused_order"
    case delegateRefusedOffer = "delegate_refused_offer"
    case delegateUpdateOffer = "delegate_update_offer"
    case deleteNotify = "delete_notify"
    case blockNotify = "block_notify"
    case adminNotify = "admin_notify"
    case userWarningNoResponse = "user_warning_no_response"
    case ticketReply = "ticket_reply"
    case ticketInprogress = "ticket_inprogress"
    case newMessage = "new_message"
    case userCancelOrder = "user_cancel_order"
    case adminUpdateProfile  = "admin_update_profile"
    case refundAmount = "refund_amount"
    case productAvailabilityReply = "product_availability_reply"
    case productAvailableAgain = "product_available_again"
    case unblockSpecialOrders = "unblock_special_orders"
    case specialOrdersUnblocked = "special_orders_unblocked"
    case specialOrdersBlocked = "special_orders_blocked"
}
