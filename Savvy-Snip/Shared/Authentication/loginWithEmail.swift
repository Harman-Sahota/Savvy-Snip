import Foundation
import FirebaseCore
import FirebaseAuth

// MARK: - Struct to hold user credentials

struct UserCredentials {
    var email: String
    var password: String
    var username: String?
}

// MARK: - Register to firebase using email

class loginWithEmail {
    static let shared = loginWithEmail() // Singleton instance
    
    func registerUserWithEmail(email: String, password: String, username: String?, completion: @escaping (UserCredentials?, AuthDataResult?, Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle the error and send an error message
                let errorMessage = "Registration failed: \(error.localizedDescription)"
                completion(nil, nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                return
            }
            
            // Update the username in the UserCredentials struct
            let userCredentials = UserCredentials(email: email, password: password, username: username ?? authResult?.user.displayName)
            
            // Set the username in Firebase Authentication (if provided)
            if let username = username {
                let changeRequest = authResult?.user.createProfileChangeRequest()
                changeRequest?.displayName = username
                changeRequest?.commitChanges(completion: nil)
            }
            
            completion(userCredentials, authResult, nil)
        }
    }

//MARK: - Login with firebase using email
    
    func loginUserWithEmail(email: String, password: String, completion: @escaping (UserCredentials?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                // Handle the error and send an error message
                let errorMessage = "Login failed: \(error.localizedDescription)"
                completion(nil, NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
                return
            }
            
            // Extract the username from authResult
            let username = authResult?.user.displayName
            
            // Create UserCredentials object with email, password, and username
            let userCredentials = UserCredentials(email: email, password: password, username: username)
            
            completion(userCredentials, nil)
        }
    }

}
