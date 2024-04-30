import SwiftUI

struct SnipsView: View {
    let categoryName: String
    @State private var isAddSnipViewPresented = false
    @State private var selectedCategoryName: String?
   
    init(categoryName: String) {
          self.categoryName = categoryName
          _selectedCategoryName = State(initialValue: categoryName)
      }
    
    var body: some View {
        VStack {
            HStack {
                //MARK: - Add Category Button
                Button(action: {
                    isAddSnipViewPresented = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Add A New Snip")
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
            
        }
        .navigationBarTitle(categoryName, displayMode: .large)
        .sheet(isPresented: $isAddSnipViewPresented) {
            AddSnipView(isPresented: $isAddSnipViewPresented, selectedCategoryName: selectedCategoryName ?? "Sample Category")
        }
    }
}

struct SnipsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SnipsView(categoryName: "Sample Category")
        }
    }
}
