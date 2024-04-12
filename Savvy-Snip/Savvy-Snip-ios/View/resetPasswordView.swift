import SwiftUI

struct resetPasswordView: View {
    @State private var email = ""
    @State private var isEmailEmpty = false
    @State private var errorMessage: String? // State to hold error message
    @State private var resetSuccess = false // State to track password reset success
    private let authManager = AuthManager() // AuthManager instance
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Text field for entering email
            TextField("Enter your email", text: $email)
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .foregroundColor(.primary)
                .font(.body)
                .cornerRadius(10)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isEmailEmpty ? Color.red : Color.gray, lineWidth: 1) // Red border if empty
                )
                .onChange(of: email) { newValue in
                    isEmailEmpty = newValue.isEmpty
                }
            
            // Display error message if present
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            
            // Display success message upon password reset
            if resetSuccess {
                Text("Check your email!")
                    .foregroundColor(.green)
                    .padding(.top, 5)
            }
            
            // Button to trigger password reset (enabled only if email is not empty)
            Button(action: {
                if !isEmailEmpty {
                    Task {
                        do {
                            try await resetPassword(email: email)
                            // Password reset successful, update UI
                            resetSuccess = true
                            errorMessage = nil // Clear any existing error message
                        } catch {
                            // Handle reset password error
                            errorMessage = "Error resetting password: \(error.localizedDescription)"
                            resetSuccess = false // Reset success state
                            print("Error resetting password: \(error)")
                        }
                    }
                } else {
                    // Email field is empty, display error message
                    errorMessage = "Email field cannot be empty."
                    print("Email field cannot be empty.")
                }
            }) {
                Text("Reset Password")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.blue)
                    .cornerRadius(10.0)
                    .disabled(isEmailEmpty) // Disable button if email is empty
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Reset Password")
    }
    
    // Reset Password Function
    func resetPassword(email: String) async throws {
        guard !email.isEmpty else {
            throw AuthError.FieldEmpty
        }
        
        do {
            try await authManager.resetPassword(email: email)
            // Password reset successful, handle UI updates or navigation here
        } catch {
            // Handle reset password error
            print("Error resetting password: \(error)")
            throw error
        }
    }
}

struct resetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            resetPasswordView()
        }
    }
}
