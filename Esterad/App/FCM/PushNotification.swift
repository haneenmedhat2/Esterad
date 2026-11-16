//
//  PushNotification.swift
//  Esterad
//
//  Created by Haneen on 27/10/2025.
//

import Foundation
import UIKit
import Firebase
import FirebaseMessaging

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(fcmToken ?? "No Device token found")")
        UserDefaults.pushNotificationToken = fcmToken ?? "No Token Found"
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
    }
    
    //MARK: - Handel the arrived Notifications
    
    //Use this method to process incoming remote notifications for your app
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        NotificationCountManager.shared.refresh()

        print(userInfo)
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    //when the notification arrives and the app is in foreground
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        NotificationCountManager.shared.refresh()
        let userInfo = notification.request.content.userInfo
                
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        print("Notification info is: \n\(userInfo)")

        let targetValue = userInfo[AnyHashable(FCMValueKeys.type.rawValue)] as? String
        
        switch targetValue {
            case NotificationType.delegateMadeOffer.rawValue,
            NotificationType.delegateRefusedOrder.rawValue,
            NotificationType.delegateUpdateOffer.rawValue,
            NotificationType.userCancelOrder.rawValue,
            NotificationType.userWarningNoResponse.rawValue,
            NotificationType.delegateFinishedOrder.rawValue:
            
            let orderId = userInfo[AnyHashable(FCMValueKeys.orderId.rawValue)] as? String
            let dic = [FCMValueKeys.id.rawValue: orderId]
            
            NotificationCenter.default.post(name: .isOrderChanged, object: nil, userInfo: dic as [AnyHashable: Any])
            
        case NotificationType.ticketReply.rawValue:
            let ticketId = userInfo[AnyHashable(FCMValueKeys.ticketId.rawValue)] as? String
            let dic = [FCMValueKeys.id.rawValue: ticketId]
            NotificationCenter.default.post(name: .isComplaintsChanged, object: nil, userInfo: dic as [AnyHashable: Any])
            
        case NotificationType.delegateFinishedOrder.rawValue:
            NotificationCenter.default.post(name: .shouldExitChatAndGoToOrderDetails, object: nil)
            
        case NotificationType.blockNotify.rawValue:
            blockUser()
        default:
            break
        }
        completionHandler([.banner,.sound,.badge])

    }
    
    // when the user tap on the notification banar
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        let userInfo = response.notification.request.content.userInfo
        NotificationCountManager.shared.refresh()

        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        guard let targetValue = userInfo[AnyHashable(FCMValueKeys.type.rawValue)] as? String else {
            print("No target type found in notification ❌")
            return }
        
        guard let tabBar = UIApplication.shared.connectedScenes
                  .compactMap({ $0 as? UIWindowScene })
                  .flatMap({ $0.windows })
                  .first(where: { $0.isKeyWindow })?
                  .rootViewController as? AppTabBarController else { return }

        let notificationType = NotificationType(rawValue: targetValue)
        let orderId = userInfo[AnyHashable(FCMValueKeys.orderId.rawValue)] as? String
        let ticketId = userInfo[AnyHashable(FCMValueKeys.ticketId.rawValue)] as? String
        let roomId = userInfo[AnyHashable(FCMValueKeys.roomId.rawValue)] as? String
        let senderName = userInfo[AnyHashable(FCMValueKeys.senderName.rawValue)] as? String
        let productId = userInfo[AnyHashable(FCMValueKeys.productId.rawValue)] as? String
        let downPaymentPrice = userInfo[AnyHashable(FCMValueKeys.downPaymentPrice.rawValue)] as? String

        
        switch notificationType {
        case  .delegateFinishedOrder, .delegateMadeOffer, .delegateRefusedOrder, .delegateRefusedOffer,.delegateUpdateOffer, .userWarningNoResponse :
            tabBar.routeToOrder(orderId?.toInt() ?? 0)

        case .ticketReply:
            tabBar.routeToTicket(ticketId?.toInt() ?? 0)

        case .newMessage:
            tabBar.routeToChat(roomId?.toInt() ?? 0, senderName ?? "Sender name")

        case .productAvailableAgain:
            if let id = (userInfo[FCMValueKeys.productId.rawValue] as? Int) ?? productId?.toInt(), id > 0 {
                tabBar.routeToProduct(id)
            } else if UserDefaults.isLogin {
                tabBar.routeToNotifications()
            }
         
//        case .productAvailabilityReply:
//            tabBar.routeToPayment(id: productId?.toInt() ?? 0, price: downPaymentPrice ?? "")
//            

        default:
            guard UserDefaults.isLogin else {return}
            tabBar.routeToNotifications()
        }
        
    }
}

// MARK: - Helper Functions -

extension AppDelegate {
    
    private func getCurrentTabBar() -> AppTabBarController? {
        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
        guard let tabBar = window?.rootViewController as? AppTabBarController else { return nil}
        return tabBar
    }
    
    private func currentNavigationRootVC() -> BaseNav? {
        guard let tabBar = getCurrentTabBar() else { return nil }
        return tabBar.viewControllers?.first as? BaseNav
    }
    
    private func goTo(vc: UIViewController) {
        let window = SceneDelegate.current?.window
        var rootVC = window?.rootViewController as? UITabBarController
        
        if rootVC == nil {
            AppHelper.changeWindowRoot(vc: AppTabBarController())
            rootVC = (SceneDelegate.current?.window?.rootViewController as? UITabBarController)
        }
        
        if let selectedIndex = rootVC?.selectedIndex {
            rootVC?.viewControllers?[selectedIndex].show(vc, sender: self)
        }
    }
    
    
    private func blockUser() {
        UserDefaults.isLogin = false
        UserDefaults.guest = true
        Session.token = nil
        Session.user = nil
        UserDefaults.notificationCount = 0
        let vc = SplashVC()
        AppHelper.changeWindowRoot(vc: vc, options: .transitionCurlDown)
    }
}

//MARK: - Routes -

extension AppDelegate {
    
    private func goToOrderDetails(orderId:Int) {
        guard UserDefaults.isLogin,
              let _ = getCurrentTabBar(),
              let root = currentNavigationRootVC() else { return }
        if root.visibleViewController?.isKind(of: OrderDetailsVC.self) == false {
            let vc = OrderDetailsVC(viewModel :OrderDetailsVM(orderId: orderId))
            vc.hidesBottomBarWhenPushed = true
            root.pushViewController(vc, animated: true)
        }
    }
    
    private func goToComplaintDetails(ticketId:Int) {
        guard UserDefaults.isLogin,
              let _ = getCurrentTabBar(),
              let root = currentNavigationRootVC() else { return }
        if root.visibleViewController?.isKind(of: ComplaintDetailsVC.self) == false {
            let vc = ComplaintDetailsVC(viewModel :ComplaintDetailsVM(complaintId: ticketId))
            vc.hidesBottomBarWhenPushed = true
            root.pushViewController(vc, animated: true)
        }
    }
    
    private func goToChat(roomId:Int,senderName: String) {
        guard UserDefaults.isLogin,
              let _ = getCurrentTabBar(),
              let root = currentNavigationRootVC() else { return }
        if root.visibleViewController?.isKind(of: ChatVC.self) == false {
            let vc = ChatVC(viewModel :ChatVM(roomId: roomId, senderName: senderName))
            vc.hidesBottomBarWhenPushed = true
            root.pushViewController(vc, animated: true)
        }
    }
    
    private func setNotificationTab() {
        guard let root = currentNavigationRootVC() else { return }
        if root.visibleViewController?.isKind(of: NotificationVC.self) == false {
            let vc = NotificationVC(viewModel: NotificationVM())
            root.pushViewController(vc, animated: true)
        }
    }
}
