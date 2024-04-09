import SwiftUI

struct LoginWithEmail: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var loginSuccessful: Bool = false // Track login success
    
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
                                // Login successful
                                self.loginSuccessful = true // Set flag to true
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
            // Use a NavigationLink to navigate to the Home view upon successful login
            .background(
                NavigationLink(destination: Home(username: nil), isActive: $loginSuccessful) {
                    EmptyView()
                }
            )
            .onAppear {
                // Hide the navigation bar when this view appears
                UINavigationBar.appearance().isHidden = true
            }
            .onDisappear {
                // Show the navigation bar when this view disappears
                UINavigationBar.appearance().isHidden = false
            }
        }
    }
}

#if DEBUG
struct LoginWithEmail_Previews: PreviewProvider {
    static var previews: some View {
        LoginWithEmail()
    }
}
#endif
