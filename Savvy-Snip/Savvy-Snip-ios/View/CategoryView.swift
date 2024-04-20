import SwiftUI
import Combine

//MARK: - View model to handle logging out
@MainActor
final class CategoryViewModel: ObservableObject {
    private let authManager = AuthManager()
    @Published var categories: [Category] = []
    @Published var showErrorAlert = false
    @Published var errorMessage = "An error occurred during logout. Please try again."
    
    func logOut() {
        Task {
            do {
                try await authManager.signOut()
                self.reset()
            } catch {
                print("Error logging out: \(error.localizedDescription)")
                self.errorMessage = "Error logging out: \(error.localizedDescription)"
                self.showErrorAlert = true
            }
        }
    }
    
    // Function to reset state
    func reset() {
        categories = []
        showErrorAlert = false
        errorMessage = "An error occurred. Please try again."
    }
    
    func deleteAccount() async{
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
    
    func fetchCategories() async {
        do {
            self.categories = try await authManager.getCategories()
        } catch {
            print("Error fetching categories: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.errorMessage = "Error fetching categories: \(error.localizedDescription)"
                self.showErrorAlert = true
            }
        }
    }
    
    func deleteCategory(at offsets: IndexSet) {
        guard let index = offsets.first, index < categories.count else { return }
        let categoryToDelete = categories[index]
        
        Task {
            do {
                try await authManager.deleteCategory(categoryToDelete)
                await fetchCategories()
            } catch {
                print("Error deleting category: \(error.localizedDescription)")
                self.errorMessage = "Error deleting category: \(error.localizedDescription)"
                self.showErrorAlert = true
            }
        }
    }
    
    func filteredCategories(for searchText: String) -> [Category] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

//MARK: - UI
struct CategoryView: View {
    @Binding var showSignInView: Bool
    @StateObject private var viewModel = CategoryViewModel()
    @State private var searchText = ""
    @State private var isShowingAddCategorySheet = false
    @State private var loginState = UUID()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    isShowingAddCategorySheet = true
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
                .sheet(isPresented: $isShowingAddCategorySheet) {
                    AddCategoryView(isShowingSheet: $isShowingAddCategorySheet)
                        .onDisappear {
                            Task {
                                await viewModel.fetchCategories()
                            }
                        }
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            List {
                ForEach(viewModel.filteredCategories(for: searchText), id: \.id) { category in
                    NavigationLink(destination: SnipsView(categoryName: category.name)) {
                        Text(category.name)
                            .padding(.vertical, 8)
                    }
                }
                .onDelete(perform: viewModel.deleteCategory)
            }
            .searchable(text: $searchText)
            
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
            Button(action: {
                Task{
                    await viewModel.deleteAccount()
                    showSignInView = true
                }
            }) {
                Text("Delete Account")
                    .foregroundColor(.red)
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Color.clear)
                    .padding()
            }
        }
        .contentShape(Rectangle()) // Ensure the VStack is tappable
        .id(loginState)
        .onAppear {
            Task {
                await viewModel.fetchCategories()
            }
        }
        .onChange(of: showSignInView) { newValue in
            if !newValue {
                Task {
                    await viewModel.fetchCategories()
                }
            }
        }
    }
}

//MARK: -  Preview
struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CategoryView(showSignInView: .constant(false))
        }
    }
}

