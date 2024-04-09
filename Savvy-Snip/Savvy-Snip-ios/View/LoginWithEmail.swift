//
//  LoginWithEmail.swift
//  Savvy-Snip-ios
//
//  Created by Harman Sahota on 2024-04-09.
//

import SwiftUI

struct LoginWithEmail: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
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
                        // Call the login function
                        loginWithEmail.shared.loginUserWithEmail(email: email, password: password) { userCredentials, error in
                            if let error = error {
                                // Handle login error
                                errorMessage = "Login failed: \(error.localizedDescription)"
                            } else if let userCredentials = userCredentials {
                                // Login successful, navigate to the next screen passing the user credentials
                                let homeView = Home(username: userCredentials.username ?? nil)
                                
                            }
                        }
                    }
                    .frame(width: 300, height: 20)
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .textCase(.uppercase)
                    
                }
                
                Spacer()
                
            }
            .padding()
            .navigationBarTitle("Login With Email", displayMode: .large)
            .navigationBarBackButtonHidden(false)
        }
    }
}

#Preview {
    LoginWithEmail()
}
