import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

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
            _ = try await authManager.createUser(email: email, password: password)
            
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
    
    func signInUser() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Fields Cannot Be Empty"
            throw AuthError.FieldEmpty
        }
        
        do {
            // Perform user sign-in
            _ = try await authManager.signInUser(email: email, password: password)
            
            // Reset error message on successful sign-in
            errorMessage = ""
            
        }catch AuthError.wrongPassword{
            errorMessage = "Incorrect password. Please try again."
            throw AuthError.wrongPassword
        }
        catch AuthError.userNotFound{
            errorMessage = "User not found. Please check your credentials."
            throw AuthError.userNotFound
        }
        catch AuthError.networkError{
            errorMessage = "Network error. Please check your internet connection."
            throw AuthError.networkError
        }
        catch{
            errorMessage = "Sign-in failed: \(error.localizedDescription)"
            throw AuthError.signInFailed
        }
    }
    
    // MARK: - Reset Password Function
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
    
    func deleteAccount() async throws {
        do {
            try await authManager.deleteAccount() // Call the delete method from AuthManager
            // Handle successful account deletion
        } catch {
            print("Error deleting account: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    
}


//MARK: - auth result model

struct AuthDataResultModel {
    
    let uid: String?
    let email: String?
    
    init(user: User){
        
        self.uid = user.uid
        self.email = user.email
        
    }
    
}

//MARK: - user profile for firestore db
struct UserProfile {
    let uid: String
    let email: String
    
}

//MARK: - protocol for dependency injection

protocol AuthManagerProtocol {
    func createUser(email: String, password: String) async throws -> AuthDataResultModel
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel
    func getAuthenticatedUser() throws -> AuthDataResultModel?
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
}

//MARK: - Class that handles all firebase methods

final class AuthManager: AuthManagerProtocol{
    
    private var currentUser: User? {
           return Auth.auth().currentUser
       }
    private let db = Firestore.firestore()
    
    // MARK: - Get authenticated user
    func getAuthenticatedUser() throws -> AuthDataResultModel? {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    //MARK: - Sign Out
    func signOut() async throws{
        try Auth.auth().signOut()
    }
    
    //MARK: - user profile creation method
    func userProfileToData(_ userProfile: UserProfile) -> [String: Any] {
        let data: [String: Any] = [
            "uid": userProfile.uid,
            "email": userProfile.email
        ]
        
        return data
    }
}

//MARK: SIGN IN EMAIL

extension AuthManager{
    
    // MARK: - Register to firebase using email
    func createUser(email: String, password: String) async throws -> AuthDataResultModel{
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let userProfile = UserProfile(uid: authDataResult.user.uid, email: authDataResult.user.email ?? "")
        try await Firestore.firestore().collection("users").document(authDataResult.user.uid).setData(userProfileToData(userProfile))
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    // MARK: - Sign in to firebase with email
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    //MARK: - Rest Password
    func resetPassword(email: String) async throws{
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
}

//MARK: - SIGN IN SSO

extension AuthManager{
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        let authDataResult = try await Auth.auth().signIn(with: credential)
        let userProfile = UserProfile(uid: authDataResult.user.uid, email: authDataResult.user.email ?? "")
        try await Firestore.firestore().collection("users").document(authDataResult.user.uid).setData(userProfileToData(userProfile))
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func deleteAccount() async throws{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
    
}

//MARK: - Category model to store retrieved data model

struct Category{
    var id: String
    var name: String
}

//MARK: - Save category data - firestore db

extension AuthManager{
    
    func saveCategory(categoryName: String, completion: @escaping (Error?) -> Void) {
        guard let userID = currentUser?.uid else {
            completion(AuthError.userNotLoggedIn)
            return
        }
        
        let userRef = db.collection("users").document(userID)
        let categoryData: [String: Any] = [
            "categoryName": categoryName
        ]
        
        // Add a new document to the "categories" subcollection
        userRef.collection("categories").addDocument(data: categoryData) { error in
            if let error = error {
                print("Error adding category: \(error.localizedDescription)")
                completion(error)
            } else {
                print("Category added successfully!")
                completion(nil)
            }
        }
    }
}

//MARK: - retrieve and delete category data - firestore db

extension AuthManager {
    func getCategories() async throws -> [Category] {
        guard let userID = currentUser?.uid else {
            throw AuthError.userNotLoggedIn
        }
        
        let userRef = db.collection("users").document(userID)
        
        do {
            let querySnapshot = try await userRef.collection("categories").getDocuments()
            
            var categories: [Category] = []
            for document in querySnapshot.documents {
                let data = document.data()
                if let categoryName = data["categoryName"] as? String {
                    let category = Category(id: document.documentID, name: categoryName)
                    categories.append(category)
                }
            }
            
            return categories
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            if let authError = error as? AuthError {
                throw authError
            } else {
                throw FirestoreError.firestoreError(description: error.localizedDescription)
            }
        }
    }
    
    func deleteCategory(_ category: Category) async throws {
           guard let userID = currentUser?.uid else {
               throw AuthError.userNotLoggedIn
           }
           
           let userRef = db.collection("users").document(userID)
           let categoryRef = userRef.collection("categories").document(category.id)
           
           do {
               try await categoryRef.delete()
               print("Category deleted successfully!")
           } catch {
               throw error
           }
       }
}



//MARK: - errors dictionary

enum AuthError: Error {
    case emailAlreadyInUse
    case FieldEmpty
    case registrationFailed
    case wrongPassword
    case userNotFound
    case networkError
    case signInFailed
    case NoEmailError
    case userNotLoggedIn
    // Add more cases as needed for other authentication errors
}

enum FirestoreError: Error {
    case firestoreError(description: String)
}
