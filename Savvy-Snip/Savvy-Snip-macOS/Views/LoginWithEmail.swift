//
//  LoginWithEmail.swift
//  Savvy-Snip-macOS
//
//  Created by Harman Sahota on 2024-04-09.
//

import SwiftUI

struct LoginWithEmail: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("LaunchColor"))
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                Spacer()
                
                Text("Login With Email")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
                Spacer()
                
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 50)
                            .controlSize(.extraLarge)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 50)
                            .controlSize(.extraLarge)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        // Call the login function
                        loginWithEmail.shared.loginUserWithEmail(email: email, password: password) { userCredentials, error in
                            if let error = error {
                                // Handle login error
                                errorMessage = "Login failed: \(error.localizedDescription)"
                            } else if let userCredentials = userCredentials {
                                // Login successful, navigate to the next screen passing the user credentials
                                HomeMenu(username: userCredentials.username)
                                
                            }
                        }
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(width: 200,height: 40)
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(10)
                            .textCase(.uppercase)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

#Preview {
    LoginWithEmail()
}
