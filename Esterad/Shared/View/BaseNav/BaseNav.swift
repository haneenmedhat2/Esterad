//
//  BaseNav.swift
//  Waraqa
//
//  Created by Haneen on 07/08/2025.
//

import Foundation
import UIKit

class BaseNav: UINavigationController {
    
    //MARK: - Properties -
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //MARK: - Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGesture()
        self.handleAppearance()
    }
    
    //MARK: - Design -
    
    func handleAppearance() {
        let backButtonImage = Language.isRTL() ? UIImage(named: "arrow-right") : UIImage(named: "arrow-right")

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.backgroundEffect = nil
        
        appearance.shadowColor = UIColor(white: 1.0, alpha: 0.4)

        if let backImage = backButtonImage {
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        }

        let titleFont = UIFont(name: "YourCustomFontName-Medium", size: 18) ?? UIFont.systemFont(ofSize: 18, weight: .medium)
        appearance.titleTextAttributes = [
            .font: titleFont,
            .foregroundColor: UIColor.black
        ]

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = .black
        navigationBar.isTranslucent = false
        navigationBar.backgroundColor = .clear
    }

//    func handleAppearance() {
//        
//        let appearance = UINavigationBarAppearance()
//        var backButtonImage: UIImage?
//        
//        backButtonImage =  Language.isRTL() ? UIImage(named: "enBackBtn") : UIImage(named: "arBackBtn")
//        
//        guard let backImage = backButtonImage else {
//            print("Back button image not found")
//            return
//        }
//        
//        backImage.withTintColor(.white)
//        appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
//        
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.label,
//                                          .font: UIFont.boldSystemFont(ofSize: 16)]
//        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label,
//                                               .font: UIFont.boldSystemFont(ofSize: 26)]
//        
//        appearance.shadowColor = .clear
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        UINavigationBar.appearance().compactAppearance = appearance
//        UINavigationBar.appearance().semanticContentAttribute = Language.isRTL() ? .forceRightToLeft : .forceLeftToRight
//        
//        self.navigationBar.tintColor = .label
//        appearance.backgroundColor = UIColor(resource: .mainBackGround)
//    }
    private func setupGesture() {
        interactivePopGestureRecognizer?.delegate = self
        self.view.semanticContentAttribute = Language.isRTL() ? .forceRightToLeft : .forceLeftToRight
    }
    
    
}
extension BaseNav: UIGestureRecognizerDelegate {}
