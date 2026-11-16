//
//  Session.swift
//  Esterad
//
//  Created by Haneen on 13/01/2026.
//
import Foundation

struct Session {
    static var token: String? {
        get {
            return UserDefaults.accessToken
        }
        set {
            UserDefaults.accessToken = newValue
        }
    }
    
    static var user: User? {
        get {
            return UserDefaults.user
        }
        set {
            UserDefaults.user = newValue
        }
    }
}
