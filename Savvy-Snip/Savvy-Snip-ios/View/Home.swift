//
//  Home.swift
//  Savvy-Snip-ios
//
//  Created by Harman Sahota on 2024-04-09.
//

import SwiftUI

struct Home: View {
    let username: String?
    
    var body: some View {
        VStack {
            if let username = username {
                Text("Welcome, \(username)")
                    .font(.title)
                    .fontWeight(.bold)
            } else {
                Text("Welcome")
                    .font(.title)
                    .fontWeight(.bold)
            }
            Spacer()
        }
    }
}

#Preview {
    Home(username: nil)
}
