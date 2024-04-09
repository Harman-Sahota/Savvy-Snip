import SwiftUI

struct CreateAccountScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Create Account")
                .font(.title)
                .fontWeight(.bold)
            
            Spacer()
            
            VStack(spacing: 20) {
                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Register") {
                    // Call the registration function
                    loginWithEmail.shared.registerUserWithEmail(email: email, password: password, username: username) { userCredentials, authResult, error in
                        if let error = error {
                            // Handle registration error
                            let errorMessage = "Error registering user: \(error.localizedDescription)"
                            print(errorMessage)
                        } else {
                            // Registration successful
                            if let username = authResult?.user.displayName {
                                // Navigate to another screen passing the user credentials
                                HomeMenu(username: username)
                            } else {
                                // Handle case where username is nil
                                print("Registration successful but username is nil.")
                            }
                        }
                    }
                }
                .padding()
                .buttonStyle(DefaultButtonStyle())
            }
            
            Spacer()
        }
        .padding()
    }
}

struct CreateAccountScreen_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountScreen()
    }
}
