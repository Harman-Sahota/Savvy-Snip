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

//MARK: - snips struct
struct Snip: Hashable {
    let id = UUID()
    var title: String
    var code: String
    var timestamp: Timestamp // Add timestamp property
    
    init(title: String, code: String, timestamp: Timestamp) {
        self.title = title
        self.code = code
        self.timestamp = timestamp
    }
}

//MARK: - protocol for dependency injection

protocol AuthManagerProtocol {
    func createUser(email: String, password: String) async throws -> AuthDataResultModel
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel
    func getAuthenticatedUser() throws -> AuthDataResultModel?
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
    func updateCategoryOrder(_ categories: [Category]) async throws
    func updateCategoryName(categoryId: String, newName: String) async throws
}

//MARK: - Class that handles all firebase methods

final class AuthManager: AuthManagerProtocol,ObservableObject {
    
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
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noCurrentUser
        }
        
        let uid = user.uid
        
        do {
            try await user.delete()
        } catch {
            throw AuthError.deleteFailed(error.localizedDescription)
        }
        
        do {
            let userDocRef = db.collection("users").document(uid)
            let userCatRef = db.collection("users").document(uid).collection("categories")
            
            try await deleteAllDocumentsInSubcollection(userCatRef)
            try await userDocRef.delete()
            
            // Deletion succeeded
            print("Document and subcollection deleted successfully")
        } catch {
            // Print detailed error message
            print("Error deleting document and subcollection: \(error.localizedDescription)")
            
            // Throw FirestoreError with the specific error message
            throw FirestoreError.deleteFailed(error.localizedDescription)
        }
    }
    
    private func deleteAllDocumentsInSubcollection(_ collectionRef: CollectionReference) async throws {
        // Fetch all documents within the subcollection
        let querySnapshot = try await collectionRef.getDocuments()
        
        // Delete each document within the subcollection
        for document in querySnapshot.documents {
            let documentRef = collectionRef.document(document.documentID)
            try await documentRef.delete()
        }
    }
}

//MARK: - Category model to store retrieved data model

struct Category:Identifiable, Equatable{
    var id: String
    var name: String
    var order: Int
    
    static func == (lhs: Category, rhs: Category) -> Bool {
        return lhs.id == rhs.id
    }
}

//MARK: - Save category data - firestore db

extension AuthManager{
    
    func saveCategory(categoryName: String, completion: @escaping (Error?) -> Void) {
        guard let userID = currentUser?.uid else {
            completion(AuthError.userNotLoggedIn)
            return
        }
        
        let userRef = db.collection("users").document(userID)
        
        // Fetch existing categories to determine the next order value
        userRef.collection("categories").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            // Determine the next order value
            let maxOrder = snapshot?.documents.compactMap { $0.data()["order"] as? Int }.max() ?? -1
            let newOrder = maxOrder + 1
            
            let categoryData: [String: Any] = [
                "categoryName": categoryName,
                "order": newOrder
            ]
            
            // Add a new document to the "categories" subcollection with calculated order
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
    
}

//MARK: - retrieve and delete category data - firestore db

extension AuthManager {
    func getCategories() async throws -> [Category] {
        guard let userID = currentUser?.uid else {
            throw AuthError.userNotLoggedIn
        }
        
        let userRef = db.collection("users").document(userID)
        
        do {
            let querySnapshot = try await userRef.collection("categories")
                .order(by: "order")
                .getDocuments()
            
            var categories: [Category] = []
            for document in querySnapshot.documents {
                let data = document.data()
                if let categoryName = data["categoryName"] as? String,
                   let order = data["order"] as? Int {
                    let category = Category(id: document.documentID, name: categoryName, order: order)
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
    
    func updateCategoryOrder(_ categories: [Category]) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw AuthError.userNotLoggedIn
        }
        
        let userRef = db.collection("users").document(userID)
        
        for (index, category) in categories.enumerated() {
            let categoryRef = userRef.collection("categories").document(category.id)
            
            try await categoryRef.updateData(["order": index])
        }
        
        print("Category order updated successfully!")
    }
    
    func updateCategoryName(categoryId: String, newName: String) async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.userNotLoggedIn
        }
        
        let userRef = db.collection("users").document(currentUser.uid)
        let categoryRef = userRef.collection("categories").document(categoryId)
        
        do {
            try await categoryRef.updateData(["categoryName": newName])
        } catch {
            throw FirestoreError.firestoreError(description: error.localizedDescription)
        }
    }
}


//MARK: - Save Snips

extension AuthManager {
    func saveSnip(categoryName: String, title: String, code: String, completion: @escaping (Error?) -> Void) {
        guard let userID = currentUser?.uid else {
            print("Error: User is not logged in.")
            completion(AuthError.userNotLoggedIn)
            return
        }
        
        let userRef = db.collection("users").document(userID)
        
        // First, query for the category with the given name
        userRef.collection("categories").whereField("categoryName", isEqualTo: categoryName).getDocuments { snapshot, error in
            if let error = error {
                print("Error retrieving category: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let categoryDocument = snapshot?.documents.first else {
                print("Error: Category with name '\(categoryName)' not found.")
                completion(FirestoreError.categoryNotFound)
                return
            }
            
            let categoryID = categoryDocument.documentID
            
            // Once you have the category ID, you can add the snip to the category's collection
            let categoryRef = userRef.collection("categories").document(categoryID)
            
            // Get current timestamp
            let timestamp = Timestamp(date: Date())
            
            let snipData: [String: Any] = [
                "title": title,
                "code": code,
                "timestamp": timestamp // Add timestamp to snip data
            ]
            
            categoryRef.collection("snips").addDocument(data: snipData) { error in
                if let error = error {
                    print("Error adding snip: \(error.localizedDescription)")
                    completion(error)
                } else {
                    print("Snip added successfully!")
                    completion(nil)
                }
            }
        }
    }
    
}

//MARK: - Delete Snip

extension AuthManager {
    func deleteSnip(categoryName: String, title: String, code: String, timestamp: Timestamp, completion: @escaping (Error?) -> Void) {
        guard let userID = currentUser?.uid else {
            print("Error: User is not logged in.")
            completion(AuthError.userNotLoggedIn)
            return
        }
        
        let userRef = db.collection("users").document(userID)
        
        // First, query for the category with the given name
        userRef.collection("categories").whereField("categoryName", isEqualTo: categoryName).getDocuments { snapshot, error in
            if let error = error {
                print("Error retrieving category: \(error.localizedDescription)")
                completion(error)
                return
            }
            
            guard let categoryDocument = snapshot?.documents.first else {
                print("Error: Category with name '\(categoryName)' not found.")
                completion(FirestoreError.categoryNotFound)
                return
            }
            
            let categoryID = categoryDocument.documentID
            
            // Once you have the category ID, you can delete the snip from the category's collection
            let categoryRef = userRef.collection("categories").document(categoryID).collection("snips")
            
            // Query for the snip with the given title, code, and timestamp
            categoryRef.whereField("title", isEqualTo: title)
                .whereField("code", isEqualTo: code)
                .whereField("timestamp", isEqualTo: timestamp)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Error retrieving snip: \(error.localizedDescription)")
                        completion(error)
                        return
                    }
                    
                    guard let snipDocument = snapshot?.documents.first else {
                        print("Error: Snip not found.")
                        completion(FirestoreError.snipNotFound)
                        return
                    }
                    
                    // Once you have the snip document, you can delete it
                    snipDocument.reference.delete { error in
                        if let error = error {
                            print("Error deleting snip: \(error.localizedDescription)")
                            completion(error)
                        } else {
                            print("Snip deleted successfully!")
                            completion(nil)
                        }
                    }
                }
        }
    }
}


//MARK: - Retrieve Snips

extension AuthManager {
    func getSnips(forCategoryName categoryName: String, completion: @escaping ([Snip]?, Error?) -> Void) {
        guard let userID = currentUser?.uid else {
            print("Error: User is not logged in.")
            completion(nil, AuthError.userNotLoggedIn)
            return
        }
        
        let userRef = db.collection("users").document(userID)
        
        // First, query for the category with the given name
        userRef.collection("categories").whereField("categoryName", isEqualTo: categoryName).getDocuments { snapshot, error in
            if let error = error {
                print("Error retrieving category: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let categoryDocument = snapshot?.documents.first else {
                print("Error: Category with name '\(categoryName)' not found.")
                completion(nil, FirestoreError.categoryNotFound)
                return
            }
            
            let categoryID = categoryDocument.documentID
            
            // Once you have the category ID, you can fetch the snips from the category's collection
            let categoryRef = userRef.collection("categories").document(categoryID).collection("snips")
            
            categoryRef.getDocuments { snapshot, error in
                if let error = error {
                    print("Error retrieving snips: \(error.localizedDescription)")
                    completion(nil, error)
                    return
                }
                
                var snips: [Snip] = []
                for document in snapshot?.documents ?? [] {
                    if let title = document.data()["title"] as? String,
                       let code = document.data()["code"] as? String,
                       let timestamp = document.data()["timestamp"] as? Timestamp {
                        let snip = Snip(title: title, code: code, timestamp: timestamp)
                        snips.append(snip)
                    }
                }
                
                completion(snips, nil)
            }
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
    case noCurrentUser
    case deleteFailed(String)
    // Add more cases as needed for other authentication errors
}

enum FirestoreError: Error {
    case firestoreError(description: String)
    case deleteFailed(String)
    case categoryNotFound
    case snipNotFound
}
