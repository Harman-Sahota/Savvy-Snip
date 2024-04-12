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
    
    func registerUser() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Fields Cannot Be Empty"
            throw AuthError.FieldEmpty
        }
        
        do {
            // Perform user registration
            let authDataResult = try await authManager.createUser(email: email, password: password)
                        
            // Reset error message on successful registration
            errorMessage = ""
            
        } catch AuthError.emailAlreadyInUse {
            errorMessage = "Email is already associated with an existing account."
            throw AuthError.emailAlreadyInUse // rethrow the error to indicate the specific issue
            
        } catch {
            // Handle other errors
            errorMessage = "Failed to register user: \(error.localizedDescription)"
            print(error.localizedDescription)
            throw AuthError.registrationFailed
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
    
    // MARK: - Get authenticated user
    func getAuthenticatedUser() throws -> AuthDataResultModel? {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    
    // MARK: - Register to firebase using email
    func createUser(email: String, password: String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // MARK: - Sign in to firebase with email
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    
    //MARK: - Sign Out
    func signOut() async throws{
        try Auth.auth().signOut()
    }
}


enum AuthError: Error {
    case emailAlreadyInUse
    case FieldEmpty
    case registrationFailed
    // Add more cases as needed for other authentication errors
}
