//
//  NotificationsEndPoints.swift
//  Waraqa
//
//  Created by Haneen on 05/09/2025.
//

import Foundation


struct NotificationsEndPoints {
    private init() {}
}

extension NotificationsEndPoints {
    
    
    static func notificationCount() -> Endpoint<BaseResponse<NotificationCountResponse>>{
        return .init(
            method: .get,
            path: "unseen-notifications-count",
            headerType:.authorized(token: UserDefaults.accessToken ?? "")
        )
        print("🥳🥳🥳🥳🥳🥳🥳🥳🥳🥳🥳🥳\(UserDefaults.accessToken)")
    }
    
    static func getNotifications(page: Int) -> Endpoint<BaseResponse<NotificationResponse>>{
        return .init(
            method: .get,
            path: "notifications",
            queries: ["page": page],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func deleteNotification(notificationId:String) -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "delete-single-notification",
            body : [
                "notification_id" : notificationId
            ],
            headerType: .authorized(token: Session.token ?? "")
        )
    }
    
    static func deleteAllNotifications() -> Endpoint<BaseResponse<String>>{
        return .init(
            method: .post,
            path: "delete-all-notifications",
            headerType: .authorized(token: Session.token ?? "")
        )
    }
}

