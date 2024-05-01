import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

//MARK: - google sign in main logic

@MainActor
final class AuthViewModel: ObservableObject{
    
    private let authManager = AuthManager()
    
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await authManager.signInWithGoogle(tokens: tokens)
    }
}

//MARK: - main UI view

struct ContentView: View {
    @StateObject private var viewModel = AuthViewModel()

    @State private var registrationActive: Bool = false
    @State private var loginActive: Bool = false
    @State private var hideBackButtonForHome: Bool = false
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack{
            
            Image("LaunchImage")
                .resizable()
                .frame(width: 200, height: 200)
            
            Spacer()
            
            NavigationLink{
                RegisterWithEmail(showSignInView: $showSignInView)
            } label: {
                Text("Sign Up With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
            
            NavigationLink{
                LoginWithEmail(showSignInView: $showSignInView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
            
            Text("OR")
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.top, 20)
            
            Divider()
                .padding(.vertical, 0.5)
                .background(Color.gray.opacity(0.4))
            
            Text("Sign In With:")
                .foregroundColor(.primary)
                .font(.headline)
                .padding(.top, 20)
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark ,style: .icon,state: .normal )) {
                Task{
                    do{
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    }catch{
                        print(error)
                    }
                }
            }.padding()
            
            
            Spacer()
            
        }
        .padding()
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ContentView(showSignInView: .constant(false))
        }
    }
}
