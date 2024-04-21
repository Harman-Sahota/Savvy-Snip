import SwiftUI
import Combine

//MARK: - Category View Model
@MainActor
final class CategoryViewModel: ObservableObject {
    private let authManager = AuthManager()
    
    @Published var categories: [Category] = []
    @Published var showErrorAlert = false
    @Published var errorMessage = "An error occurred. Please try again."
    
    func logOut() {
        Task {
            do {
                try await authManager.signOut()
                reset()
            } catch {
                errorMessage = "Error logging out: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
    
    func deleteAccount() async {
        Task {
            do {
                try await authManager.deleteAccount()
            } catch {
                errorMessage = "Error deleting account: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
    
    func fetchCategories() async {
        Task {
            do {
                categories = try await authManager.getCategories()
            } catch {
                errorMessage = "Error fetching categories: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
    
    func reorderCategories(from sourceIndexSet: IndexSet, to destinationIndex: Int) {
        guard sourceIndexSet.count == 1 else { return }
        categories.move(fromOffsets: sourceIndexSet, toOffset: destinationIndex)
        
        Task {
            do {
                try await authManager.updateCategoryOrder(categories)
            } catch {
                errorMessage = "Error updating category order: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
    
    func deleteCategory(at offsets: IndexSet) {
        guard let index = offsets.first, index < categories.count else { return }
        let categoryToDelete = categories[index]
        
        Task {
            do {
                try await authManager.deleteCategory(categoryToDelete)
                await fetchCategories() // Reload categories after deletion
            } catch {
                errorMessage = "Error deleting category: \(error.localizedDescription)"
                showErrorAlert = true
            }
        }
    }
    
    private func reset() {
        categories = []
        showErrorAlert = false
        errorMessage = "An error occurred. Please try again."
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
    @State private var selectedCategory: Category?
    @State private var isShowingRenameSheet = false
    
    var body: some View {
        VStack {
            HStack {
                //MARK: - Add Category Button
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
            
            //MARK: - Main List view of categories w/ renaming and dragging capability
            
            List {
                ForEach(viewModel.filteredCategories(for: searchText), id: \.id) { category in
                    NavigationLink(destination: SnipsView(categoryName: category.name)) {
                        Text(category.name)
                            .padding(.vertical, 8)
                    }
                    .contextMenu {
                        Button(action: {
                            // Handle rename action
                            selectedCategory = category
                            isShowingRenameSheet = true
                        }) {
                            Label("Rename", systemImage: "pencil")
                        }
                    }
                    .onTapGesture {
                        // Handle normal tap for navigation
                        selectedCategory = category
                    }
                }
                .onDelete(perform: viewModel.deleteCategory)
                .onMove(perform: viewModel.reorderCategories)
            }
            .searchable(text: $searchText)
            .sheet(isPresented: $isShowingRenameSheet) {
                if let selectedCategory = selectedCategory {
                    RenameCategoryView(
                        isShowingSheet: $isShowingRenameSheet,
                        categoryId: selectedCategory.id
                    )
                    .onDisappear {
                        Task {
                            await viewModel.fetchCategories()
                        }
                    }
                }
            }

            
            //MARK: - Nav title and items
            
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


//MARK: - Preview
struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CategoryView(showSignInView: .constant(false))
        }
    }
}


