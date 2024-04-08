//
//  ContentView.swift
//  Savvy-Snip-ios
//
//  Created by Harman Sahota on 2024-04-08.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack {
            Image("LaunchImage")
                .resizable()
                .frame(width: 300, height: 300)
            
            Spacer()
            
            VStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1) // Border for the email text field
                        .frame(width: 300, height: 50)
                    
                    TextField("Email", text: $email)
                        .padding(.horizontal)
                        .frame(width: 280) // Adjust width to fit within the rectangle
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray, lineWidth: 1) // Border for the password secure text field
                        .frame(width: 300, height: 50)
                    
                    SecureField("Password", text: $password)
                        .padding(.horizontal)
                        .frame(width: 280) // Adjust width to fit within the rectangle
                }
                
                Button("Login") {
                    /* Action code */
                }
                .frame(width: 300, height: 20)
                .font(.headline)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .textCase(.uppercase)
                
                NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                    Text("Forgot your password ?")
                        .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                }
                
            }
            
            Spacer()
            
            Text("OR")
                .font(.subheadline)
            
            Spacer()
            
            NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                Text("Create An Account")
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

#Preview {
    ContentView()
}
