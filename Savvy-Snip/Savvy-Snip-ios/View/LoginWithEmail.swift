import SwiftUI

struct LoginWithEmail: View {
    
    // Create an instance of AuthManager to inject into LoginWithEmailModel
    private let authManager = AuthManager()
    @State private var showAlert = false
    // Initialize LoginWithEmailModel with the injected AuthManager instance
    @StateObject private var viewModel: LoginWithEmailModel
    
    init() {
        let authManager = AuthManager()
        let loginModel = LoginWithEmailModel(authManager: authManager)
        self._viewModel = StateObject(wrappedValue: loginModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Text field for email
            TextField("Enter your email", text: $viewModel.email)
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
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            // Secure text field for password
            SecureField("Enter your Password", text: $viewModel.password)
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
                        .stroke(Color.gray, lineWidth: 1)
                )
            
            // Button for signing in
            Button(action: {
                Task {
                    do{
                        let authResult = try await viewModel.registerUser()
                        showAlert = false
                    }catch{
                        DispatchQueue.main.async {
                            showAlert = true
                        }
                    }
                }
            }) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
        }
        .padding()
        .navigationTitle("Sign In With Email")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK")) {
                    // Optionally reset the error message after dismissing the alert
                    viewModel.errorMessage = ""
                }
            )
        }
    }
}

struct LoginWithEmail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            LoginWithEmail()
        }
    }
}
