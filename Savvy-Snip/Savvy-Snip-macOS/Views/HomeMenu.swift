//
//  HomeMenu.swift
//  Savvy-Snip-macOS
//
//  Created by Harman Sahota on 2024-04-09.
//

import SwiftUI

struct HomeMenu: View {
    let username: String?
       
       var body: some View {
           Menu {
               if let username = username {
                   Text("Welcome, \(username)")
               } else {
                   Text("Welcome")
               }
           } label: {
               Image(systemName: "person.crop.circle")
           }
       }
}

#Preview {
    HomeMenu(username: nil)
}
