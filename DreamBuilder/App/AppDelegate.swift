//
//  AppDelegate.swift
//  DreamBuilder
//
//  Created by iMac on 03/10/24.
//

import UIKit
import FSPopoverView

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupPopover()
        return true
    }
    
    // MARK: - Setup pop over menu appearance
    private func setupPopover() {
        let appearance = FSPopoverView.fs_appearance()
        appearance.showsArrow = true
        appearance.showsDimBackground = true
        appearance.backgroundColor = .white
        appearance.separatorColor = .gray
        appearance.textColor = .black
        appearance.textFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        appearance.separatorInset = .zero
        appearance.borderColor = .clear
        appearance.borderWidth = 0
        appearance.shadowColor = .black.withAlphaComponent(0.15)
        appearance.highlightedColor = .clear
        appearance.cornerRadius = 8
        appearance.spacing = 40
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
