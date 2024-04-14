//
//  FireBaseManager.swift
//  Savvy-Snip
//
//  Created by Harman Sahota on 2024-04-09.
//

// FirebaseManager.swift
//shared firebase methods
import FirebaseCore
import FirebaseFirestore

class FirebaseManager {
    static func configureFirebase() {
        FirebaseApp.configure()
        
        let db = Firestore.firestore()
    }
}

