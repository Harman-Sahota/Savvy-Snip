//
//  RootView.swift
//  Savvy-Snip-ios
//
//  Created by Harman Sahota on 2024-04-11.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    
    // Create an instance of AuthManager to inject into LoginWithEmailModel
    private let authManager = AuthManager()
    
    var body: some View {
        ZStack{
            NavigationStack{
                Text("Settings")
            }
        }
        
        .onAppear{
            do {
                let authUser = try authManager.getAuthenticatedUser()
                if authUser == nil {
                    showSignInView = true
                }
            } catch {
                print("Error checking authenticated user: \(error.localizedDescription)")
            }
        }
        
        .fullScreenCover(isPresented: $showSignInView, content: {
            NavigationStack{
                ContentView()
            }
        })
    }
}

#Preview {
    RootView()
}
