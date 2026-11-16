//
//  LottiePopupModel.swift
//  Esterad
//
//  Created by Haneen on 04/11/2025.
//

import Foundation

enum LottiePopupType {
    case changePhone
    case changePassword
    case chargeWallet
    case createComplaint
    case createOrder
    case deleteNotification
    case payment
    case checkAvailability

    
    var title: String {
        switch self {

        case .changePhone:
            return "phone_number_changed_successfully".localized
        case .changePassword:
            return "password_changed_successfully".localized
        case .chargeWallet:
            return "wallet_recharged_successfully".localized
        case .createComplaint ,.createOrder:
            return "request_sent_successfully".localized
        case .deleteNotification:
            return "notification_deleted_success".localized
        case .payment:
            return "deposit_paid_success".localized
        case .checkAvailability:
            return "order_sent_waiting_provider".localized
        }
    }
    
    var lottieFileName: String {
        switch self {

        case .changePhone, .changePassword, .chargeWallet ,.createComplaint, .createOrder, .deleteNotification, .payment ,.checkAvailability:
            return "sending-completed"
        }
    }
}
