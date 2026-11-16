//
//  DoubleActionPopupModel.swift
//  Esterad
//
//  Created by Haneen on 05/11/2025.
//

import Foundation

enum DoubleActionPopupType {
    case deleteAccount
    case signout
    case deleteNotification
    

    
    var title: String {
        switch self {
        case .deleteAccount:
            return "confirm_delete_account".localized
        case .signout:
            return "logout_confirmation_message".localized
        case .deleteNotification:
            return "delete_notification_question".localized
        }
    }
    
    var lottieFileName: String {
        switch self {
        case .deleteAccount:
            return "delete-user"
        case .signout:
            return "logout"
        case .deleteNotification:
            return "notification"
        }
    }
    
    var secBtnTitle: String {
        switch self {
        case .deleteAccount:
            return "confirm_deletion".localized
        case .signout:
            return "confirm_logout".localized
        case .deleteNotification:
            return "confirm_delete".localized
        }
    }
}
