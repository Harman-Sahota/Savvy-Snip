import SwiftUI

// Extension to dismiss keyboard
extension View {
    func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// View model to handle logging out
@MainActor
final class CategoryViewModel: ObservableObject {
    private let authManager = AuthManager()
    
    @Published var showErrorAlert = false
    @Published var errorMessage = "An error occurred during logout. Please try again."
    
    func logOut() {
        Task {
            do {
                try await authManager.signOut()
            } catch {
                print("Error logging out: \(error.localizedDescription)")
                self.errorMessage = "Error logging out: \(error.localizedDescription)"
                self.showErrorAlert = true
            }
        }
    }
    
    func deleteAccount() {
        Task {
            do {
                try await authManager.deleteAccount()
            } catch {
                print("Error deleting account: \(error.localizedDescription)")
                self.errorMessage = "Error Deleting Account: \(error.localizedDescription)"
                self.showErrorAlert = true
            }
        }
    }
}

// UI
struct CategoryView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @Binding var showSignInView: Bool
    @State private var searchText = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("")
                    .searchable(text: $searchText)
                
                Button(action: {
                    // Action for adding new category
                    self.dismissKeyboard()
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Add A New Category")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.vertical, 2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            
            Spacer()
            
            Button(role: .destructive, action: {
                self.dismissKeyboard()
                viewModel.deleteAccount()
                showSignInView = true
            }) {
                Text("Delete Account")
                    .foregroundColor(.red)
                    .font(.headline)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.clear)
            .cornerRadius(8)
            .padding(.horizontal)
            .padding(.vertical, 2)
            
        }
        .contentShape(Rectangle()) // Ensure the VStack is tappable
        .onTapGesture {
            self.dismissKeyboard() // Dismiss keyboard on tap
        }
        .navigationBarTitle("Your Categories", displayMode: .large)
        .navigationBarItems(trailing:
                                Button(action: {
            viewModel.logOut()
            showSignInView = true
        }) {
            Text("Log Out")
                .foregroundColor(.blue)
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
        }
        )
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

// Preview
struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CategoryView(showSignInView: .constant(false))
        }
    }
}
