import SwiftUI

struct LoginWithEmail: View {
    
    // Create an instance of AuthManager to inject into LoginWithEmailModel
    private let authManager = AuthManager()
    
    // Initialize LoginWithEmailModel with the injected AuthManager instance
    @StateObject private var viewModel: LoginWithEmailModel
    
    init() {
        let loginModel = LoginWithEmailModel(authManager: authManager)
        self._viewModel = StateObject(wrappedValue: loginModel)
    }
    
    var body: some View {
        VStack(spacing: 20){
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemGray6)) // Background color for text field
                    .frame(height: 55)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1) // Border for text field
                    )
                
                TextField("Enter your email", text: $viewModel.email)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .foregroundColor(.primary) // Text color
                    .font(.body) // Text font
                    .cornerRadius(10) // Corner radius
                    .autocapitalization(.none) // Disable autocapitalization
                    .disableAutocorrection(true) // Disable autocorrection
                    .frame(maxWidth: .infinity)
            }
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor.systemGray6)) // Background color for text field
                    .frame(height: 55)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1) // Border for text field
                    )
                
                SecureField("Enter your Password", text: $viewModel.password)
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    .foregroundColor(.primary) // Text color
                    .font(.body) // Text font
                    .cornerRadius(10) // Corner radius
                    .autocapitalization(.none) // Disable autocapitalization
                    .disableAutocorrection(true) // Disable autocorrection
                    .frame(maxWidth: .infinity)
            }
            Button{
                viewModel.registerUser()
            } label: {
                
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
    }
}

#if DEBUG
struct LoginWithEmail_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            LoginWithEmail()
                .previewDevice("iPhone 15 Pro")
        }
    }
}
#endif
