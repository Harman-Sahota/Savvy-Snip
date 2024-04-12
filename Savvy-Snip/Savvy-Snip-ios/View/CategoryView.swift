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
    
    var body: some View {
        List {
            Button("Log Out") {
                viewModel.logOut()
                showSignInView = true
            }
        }
        .alert(isPresented: $viewModel.showErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}

//MARK: - Preview

#if DEBUG
struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryView(showSignInView: .constant(false))
        }
    }
}
#endif
