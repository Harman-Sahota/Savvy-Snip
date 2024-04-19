//
//  AddCategoryView.swift
//  Savvy-Snip-ios
//
//  Created by Harman Sahota on 2024-04-19.
//

import SwiftUI

struct AddCategoryView: View {
    @State private var categoryName = ""
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShowingSheet: Bool
    @State private var error: Error?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Add A Category")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top,20)
            
            Spacer()
            
            TextField("Category Name", text: $categoryName)
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .padding(.horizontal)
                .padding(.vertical, 2)
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
            
            Button(action: {
                self.dismissKeyboard()
                saveCategory()
                isShowingSheet = false
                
            }) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            .disabled(categoryName.isEmpty)
            
            Spacer()
        }
        .padding()
        .onDisappear {
            // Reset the category name and dismiss the sheet when disappearing
            categoryName = ""
            isShowingSheet = false
        }
    }
    private func saveCategory() {
        AuthManager().saveCategory(categoryName: categoryName) { error in
            if let error = error {
                print("Error saving category: \(error.localizedDescription)")
                self.error = error
            } else {
                isShowingSheet = false
            }
        }
    }
}

struct AddCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddCategoryView(isShowingSheet: .constant(true))
        }
    }
}
