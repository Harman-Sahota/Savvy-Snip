//
//  Savvy_Snip_macOSApp.swift
//  Savvy-Snip-macOS
//
//  Created by Harman Sahota on 2024-04-08.
//

import SwiftUI

@main
struct Savvy_Snip_macOSApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseManager.configureFirebase()
        print("configured firebase!")
    }
}
