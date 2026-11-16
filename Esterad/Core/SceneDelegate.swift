//
//  SceneDelegate.swift
//  Esterad
//
//  Created by Haneen on 13/10/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    static private(set) var current: SceneDelegate?
    var window: UIWindow?
    private var pendingUserActivity: NSUserActivity?
    
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        
        SceneDelegate.current = self
        
        guard let windowScene = scene as? UIWindowScene else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light
        
        if let userActivity = connectionOptions.userActivities.first,
           UserDefaults.isLogin {
            pendingUserActivity = userActivity
            
            let tabBar = AppTabBarController.create()
            window?.rootViewController = tabBar
            window?.makeKeyAndVisible()
            
            //            if let organizationDetailsVC = handle(userActivity),
            //               let nav = tabBar.selectedViewController as? BaseNav {
            //                nav.pushViewController(organizationDetailsVC, animated: false)
            //            }
            
        } else {
            let splashVC = SplashVC(nibName: "SplashVC", bundle: nil)
            window?.rootViewController = splashVC
            window?.makeKeyAndVisible()
        }
    }
    
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        NotificationCenter.default.post(name: .appDidBecomeActive, object: nil)
        
        guard let activity = pendingUserActivity else { return }
        pendingUserActivity = nil
        
        guard UserDefaults.isLogin,
              let productVC = handle(activity),
              let root = window?.rootViewController as? AppTabBarController,
              let nav = root.selectedViewController as? BaseNav else { return }
        
        productVC.hidesBottomBarWhenPushed = true
        nav.pushViewController(productVC, animated: true)
    }
}
    
extension SceneDelegate {
    
    private func getId(pathString: String) -> Int? {
        let pattern = "/product/(\\d+)"
        if let data = getIdFromExpression(pattern: pattern, pathString: pathString) {
            return data
        } else {
            print("Invalid regex pattern")
            return nil
        }
    }
    
    private func getIdFromExpression(pattern: String, pathString: String) -> Int? {
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let nsString = pathString as NSString
            let results = regex.matches(in: pathString, range: NSRange(location: 0, length: nsString.length))
            
            if let match = results.first {
                if let numberRange = Range(match.range(at: 1), in: pathString) {
                    let number = String(pathString[numberRange])
                    print("product_id: \(number)")
                    return Int(number)
                } else {
                    return nil
                }
            } else {
                print("No match found")
                return nil
            }
        } else {
            print("Invalid regex pattern")
            return nil
        }
    }
    
    private func handle(_ userActivity: NSUserActivity) -> ProductDetailsVC? {
        // Get URL components from the incoming user activity.
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let incomingURL = userActivity.webpageURL,
              let components = NSURLComponents(url: incomingURL, resolvingAgainstBaseURL: true) else { return nil }
        // Check for specific URL components that you need.
        guard let path = components.path else { return nil }
        guard let id = getId(pathString: path) else { return nil }
        return ProductDetailsVC(viewModel: ProductDetailsVM(productId: id))
        
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard UserDefaults.isLogin else { return }
        
        if let productVC = handle(userActivity) {
            guard let windowScene = scene as? UIWindowScene?,
                  let window = windowScene?.keyWindow,
                  let root = window.rootViewController else { return }
            if let tabBar = root as? AppTabBarController {
                guard let nav = tabBar.selectedViewController as? BaseNav else { return }
                productVC.hidesBottomBarWhenPushed = true
                nav.pushViewController(productVC, animated: true)
            } else if let baseNav = root as? BaseNav {
                baseNav.pushViewController(productVC, animated: true)
            }
        }
    }
}
