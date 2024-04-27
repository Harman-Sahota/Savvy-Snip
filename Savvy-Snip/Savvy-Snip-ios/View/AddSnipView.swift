import SwiftUI

struct SearchableDropdown<T: Hashable>: View {
    @Binding var selectedItem: T?
    var items: [T]
    var label: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(label)
                .font(.headline)
            
            Picker(selection: $selectedItem, label: Text("")) {
                ForEach(items, id: \.self) { item in
                    Text("\(item)")
                        .tag(item as T?)
                }
            }
            .pickerStyle(WheelPickerStyle()) // Use WheelPickerStyle for an Apple-style scroll selector
            .frame(height: 150) // Adjust the height of the picker
            .clipped() // Clip content to avoid overflow
        }
        .padding()
    }
}

struct AddSnipView: View {
    @Binding var isPresented: Bool
    
    @State private var title: String = ""
    @State private var selectedCategory: String? = nil
    @State private var code: String = "" // Add state for the code
    
    let categories = ["Swift", "Python", "JavaScript", "Java", "C#", "Shell"] // Sample categories
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Add A Snip")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                        .foregroundColor(Color.primary)
                    
                    TextField("Title", text: $title)
                        .padding()
                        .foregroundColor(.primary)
                        .font(.body)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    SearchableDropdown(selectedItem: $selectedCategory, items: categories, label: "Type")

                    
                    VStack(alignment: .leading) {
                        Text("Code")
                            .font(.headline)
                            .foregroundColor(Color.primary)
                        
                        ZStack(alignment: .topLeading) {
                            Color(UIColor.systemBackground)
                                .cornerRadius(10.0)
                                .shadow(radius: 2)
                            
                            TextEditor(text: $code)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                                .padding()
                                .cornerRadius(10.0)
                                .foregroundColor(.primary)
                                .disableAutocorrection(true)
                        }
                        .frame(height: 150) // Adjust height
                        .border(Color.gray, width: 1)
                        .padding()
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        // Save action
                        isPresented = false // Close the sheet view
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
                    .disabled(title.isEmpty || selectedCategory == nil || code.isEmpty) // Check if any field is empty
                    .opacity(title.isEmpty || selectedCategory == nil || code.isEmpty ? 0.5 : 1.0) // Adjust opacity based on disabled state
                    
                    Spacer() // Add spacer to push content to the top
                        .frame(height: 200) // Add extra space at the bottom
                }
                .padding()
            }
            .onTapGesture {
                hideKeyboard() // Hide keyboard when tapped outside of text fields
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct AddSnipView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            AddSnipView(isPresented: .constant(true))
                .previewLayout(.sizeThatFits)
                .padding()
                .environment(\.colorScheme, .dark) // Preview in dark mode
        }
    }
}
