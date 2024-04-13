import SwiftUI

//MARK: - View model to handle logging out

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
                // Handle logout error
                print("Error logging out: \(error.localizedDescription)")
                self.errorMessage = "Error logging out: \(error.localizedDescription)"
                self.showErrorAlert = true
            }
        }
    }
}

//MARK: - UI

struct CategoryView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @Binding var showSignInView: Bool
    @State private var searchText = ""
    @State private var categories: [Category] = []
    
    var body: some View {
        VStack{
            // Search Bar and Plus Button Row
            HStack {
                TextField("Search", text: $searchText)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .padding(.trailing, 8) // Add trailing padding to the TextField
                
                Button(action: {
                    // Action for adding new category
                }) {
                    Image(systemName: "plus")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding(10) // Add padding around the plus icon
                        .background(Color.blue)
                        .clipShape(Rectangle())
                        .cornerRadius(10)
                }
                .padding(.leading, 6)
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Spacer()
            
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
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use stack navigation style
        
    }
}

//MARK: - Preview

#if DEBUG
struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CategoryView(showSignInView: .constant(false))
        }
    }
}
#endif
