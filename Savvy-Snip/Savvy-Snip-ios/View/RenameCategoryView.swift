import SwiftUI

struct RenameCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var isShowingSheet: Bool
    let categoryId: String
    @State private var newName = ""
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Rename Category")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 20)
            
            Spacer()
            
            TextField("New Category Name", text: $newName)
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                .foregroundColor(.primary)
                .font(.body)
                .cornerRadius(10)
                .background(Color(UIColor.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.horizontal)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
            
            Button(action: {
                saveCategory()
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
            .disabled(newName.isEmpty)
            Spacer()
        }
        .padding()
        .onDisappear {
            // Reset state when the view disappears
            newName = ""
            errorMessage = nil
        }
    }
    
    private func saveCategory() {
        Task {
            do {
                // Perform category name update
                try await AuthManager().updateCategoryName(categoryId: categoryId, newName: newName)
                // Dismiss the sheet on successful update
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                // Handle error and update error message
                errorMessage = "Error renaming category: \(error.localizedDescription)"
            }
        }
    }
}

struct RenameCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        RenameCategoryView(
            isShowingSheet: .constant(true),
            categoryId: "categoryId123"
        )
    }
}
