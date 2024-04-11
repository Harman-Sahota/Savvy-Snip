//
//  Savvy_Snip_iosApp.swift
//  Savvy-Snip-ios
//
//  Created by Harman Sahota on 2024-04-08.
//

import SwiftUI


@main
struct Savvy_Snip_iosApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            NavigationStack{
               RootView()
            }
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseManager.configureFirebase()
        print("Congifured Firebase!")
        
        return true
    }
}
