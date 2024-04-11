import Foundation
import FirebaseCore
import FirebaseAuth

// MARK: - Struct that takes in email and password for passing credentials to functions

@MainActor
final class LoginWithEmailModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    private let authManager: AuthManagerProtocol
    
    init(authManager: AuthManagerProtocol) {
        self.authManager = authManager
    }
    
    func registerUser() {
        Task {
            do {
                guard !email.isEmpty, !password.isEmpty else {
                    // Handle empty email or password error
                    if email.isEmpty {
                        errorMessage = "Please enter your email."
                    } else {
                        errorMessage = "Please enter your password."
                    }
                    return
                }
                
                let authDataResult = try await authManager.createUser(email: email, password: password)
                
                // Handle successful registration (e.g., navigate to next screen)
                print("Success")
                
                // Reset error message on successful registration
                errorMessage = ""
                
            } catch {
                // Handle error from createUser function
                errorMessage = "Failed to register user: \(error.localizedDescription)"
                print(error.localizedDescription)
            }
        }
    }
}


//MARK: - auth result model

struct AuthDataResultModel {
    
    let uid: String?
    let email: String?
    let photoUrl: String?
    
    init(user: User){
        
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        
    }
    
}

//MARK: - protocol for dependency injection

protocol AuthManagerProtocol {
    func createUser(email: String, password: String) async throws -> AuthDataResultModel
}

//MARK: - Class that handles all firebase methods

final class AuthManager: AuthManagerProtocol{
    
    //MARK: - Get logged in user
    func getAuthenticatedUser() throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else{
            fatalError("No logged in user")
        }
        return AuthDataResultModel(user: user)
    }
    
    
    // MARK: - Register to firebase using email
    func createUser(email: String, password: String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
