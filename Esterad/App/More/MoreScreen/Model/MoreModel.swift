//
//  MoreModel.swift
//  Esterad
//
//  Created by Haneen on 30/10/2025.
//

import Foundation

enum UserMode {
    case guest
    case authenticated
    
    static var current: UserMode {
        UserDefaults.guest == true ? .guest : .authenticated
    }
}

enum MoreMenuItem : CaseIterable {
    case profile
    case settings
    case wallet
    case complaints
    case contactUs
    case FAQ
    case termsAndConditions
    case aboutUs
    case logout
    case changeLanguage
    case guestComplaint
    case changephone
    case changePassword
    case notifications
    case deleteAccount
    
    var icon : String {
        switch self {
        case .profile:
            return "profile"
        case .settings:
            return "settings"
        case .aboutUs:
            return "aboutUs"
        case .termsAndConditions:
            return "termsAndConditions"
        case .complaints:
            return "complaints"
        case .contactUs:
            return "contactus"
        case .logout:
            return "logout"
        case .changeLanguage:
            return "changeLanguage"
        case .wallet:
            return "wallet"
        case .FAQ:
            return "FAQ"
        case .guestComplaint:
            return "complaints"
        case .changephone:
            return "changePhoneNum"
        case .changePassword:
            return "changePassword"
        case .notifications:
            return "controlNotification"
        case .deleteAccount:
            return "logout"
        }
    }
    
    var title : String {
        switch self {
        case .profile:
            return "profile".localized
        case .settings:
            return "settings".localized
        case .aboutUs:
            return "about_app".localized
        case .termsAndConditions:
            return "terms_and_conditions".localized
        case .complaints:
            return "complaints_and_suggestions".localized
        case .contactUs:
            return "contact_us".localized
        case .logout:
            return "logout".localized
        case .changeLanguage:
            return "change_app_language".localized
        case .wallet:
            return "wallet".localized
        case .FAQ:
            return "faq".localized
        case .guestComplaint:
            return "complaints_and_suggestions".localized
        case .changephone:
            return "change_phone_number".localized
        case .changePassword:
            return "change_password".localized
        case .notifications:
            return "notification_control".localized
        case .deleteAccount:
            return "delete_account".localized
        }
    }
    
    var isArrowHidden : Bool {
        switch self {
        case .profile ,.settings, .aboutUs,.termsAndConditions, .complaints, .contactUs, .changeLanguage, .wallet, .FAQ, .guestComplaint, .changephone, .changePassword:
            return false
        case .notifications:
            return true
        case .deleteAccount:
            return true
        case .logout:
            return true
        }
    }
    
    var isSwitchHidden : Bool {
        switch self {
        case .profile ,.settings, .aboutUs,.termsAndConditions, .complaints, .contactUs, .changeLanguage, .wallet, .FAQ, .guestComplaint, .changephone, .changePassword , .deleteAccount , .logout:
            return true
        case .notifications:
            return false
        }
    }
    
    static func moreItems(for userType: UserMode) -> [MoreMenuItem] {
        switch userType {
        case .guest:
            return [.changeLanguage, .guestComplaint, .contactUs,.FAQ , .termsAndConditions, .aboutUs]
        case .authenticated:
            return [.profile, .settings, .wallet, .complaints, .contactUs, .FAQ, .termsAndConditions,.aboutUs ,.logout]
        }
    }
    
    static func settingsItems(for userType: UserMode) -> [MoreMenuItem] {
        switch userType {
        case .guest:
            return [.changeLanguage]
        case .authenticated:
            return [.changeLanguage, .changephone , .changePassword,.notifications  , .deleteAccount]
        }
    }

}

