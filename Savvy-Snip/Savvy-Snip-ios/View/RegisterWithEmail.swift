import SwiftUI

struct RegisterWithEmail: View {
    
    // Create an instance of AuthManager to inject into LoginWithEmailModel
    private let authManager = AuthManager()
    @State private var errorMessage = ""
    @State private var isEmailEmpty = false
    @State private var isPasswordEmpty = false
    @Binding var showSignInView: Bool
    
    // Initialize LoginWithEmailModel with the injected AuthManager instance
    @StateObject private var viewModel: LoginWithEmailModel
    
    init(showSignInView: Binding<Bool>) {
        self._showSignInView = showSignInView
        let authManager = AuthManager()
        let loginModel = LoginWithEmailModel(authManager: authManager)
        self._viewModel = StateObject(wrappedValue: loginModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Text field for email
            TextField("Enter your email", text: $viewModel.email)
                .onChange(of: viewModel.email) { newValue in
                    isEmailEmpty = newValue.isEmpty
                }
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
            
            // Text field for password
            SecureField("Enter your Password", text: $viewModel.password)
                .onChange(of: viewModel.password) { newValue in
                    isPasswordEmpty = newValue.isEmpty
                }
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
                        .stroke(isPasswordEmpty ? Color.red : Color.gray, lineWidth: 1) // Red border if empty
                )
            
            // Error message text
            Text(errorMessage)
                .foregroundColor(.red)
                .padding(.bottom, 10) // Space below the error message
            
            // Button for signing up
            Button(action: {
                errorMessage = ""
                Task {
                    do {
                        try await viewModel.registerUser()
                        // Clear error message and reset empty states on success
                        errorMessage = ""
                        isEmailEmpty = false
                        isPasswordEmpty = false
                        showSignInView = false
                        
                    } catch {
                        // Handle registration error
                        DispatchQueue.main.async {
                            if let authError = error as? AuthError {
                                switch authError {
                                case .FieldEmpty:
                                    // Determine which field is empty and set the corresponding state
                                    isEmailEmpty = viewModel.email.isEmpty
                                    isPasswordEmpty = viewModel.password.isEmpty
                                default:
                                    errorMessage = viewModel.errorMessage
                                }
                            } else {
                                errorMessage = viewModel.errorMessage
                            }
                        }
                    }
                }
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
        }
        .padding()
        .navigationTitle("Sign Up With Email")
    }
}

struct RegisterWithEmail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            RegisterWithEmail(showSignInView: .constant(false))
        }
    }
}
