import SwiftUI
import Highlightr

struct HighlightedCodeView: UIViewRepresentable {
    var code: String
    let colorScheme: ColorScheme // Define colorScheme as a parameter
    
    let highlightr: Highlightr
    
    init(code: String, colorScheme: ColorScheme) { // Add colorScheme as a parameter
        self.code = code
        self.colorScheme = colorScheme // Assign colorScheme
        self.highlightr = Highlightr()!
        let themeName = colorScheme == .dark ? "atom-one-dark" : "mono-blue"
        self.highlightr.setTheme(to: themeName)
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = UIColor(Color.clear)
        textView.font = UIFont.systemFont(ofSize: 17)
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if let highlightedCode = highlightr.highlight(code, fastRender: true) {
            uiView.attributedText = highlightedCode
        } else {
            print("Code could not be highlighted")
            uiView.text = code
        }
    }
}

import SwiftUI
import Highlightr

struct AddSnipView: View {
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var code: String = ""
    @State private var showError: Bool = false
    let selectedCategoryName: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Add A Snip")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                    .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
              
                
                TextField("Title", text: $title)
                    .padding()
                    .font(.body)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .foregroundColor(Color.gray)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .frame(maxWidth: .infinity)
                
                VStack(alignment: .leading) {
                    Text("Code")
                        .font(.headline)
                        .foregroundColor(Color.primary)
                    
                    // Text field for code input
                    TextEditor(text: $code)
                        .padding()
                        .foregroundColor(.primary)
                        .font(.body)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .frame(maxWidth: .infinity, minHeight: 100, maxHeight: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .onChange(of: code) { newValue in
                            // Update the code whenever it changes
                            code = newValue
                        }
                }
                .padding(.horizontal)
                
                Text("Your Code")
                    .font(.headline)
                    .foregroundColor(Color.primary)
                
                // Display the highlighted code in real-time
                HighlightedCodeView(code: code, colorScheme: colorScheme)
                    .frame(maxWidth: .infinity, minHeight: 200) // Set a minHeight for the HighlightedCodeView
                    .background(Color.clear)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Button(action: {
                    if title.isEmpty || code.isEmpty {
                        showError = true
                    } else {
                        // Save action using categoryName
                        AuthManager().saveSnip(categoryName: selectedCategoryName, title: title, code: code) { error in
                            if let error = error {
                                print("Error saving snip: \(error.localizedDescription)")
                                // Handle error
                            } else {
                                isPresented = false // Close the sheet view
                            }
                        }
                    }
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
                .alert(isPresented: $showError) {
                    Alert(title: Text("Error"), message: Text("Please fill in all fields."), dismissButton: .default(Text("OK")))
                }
            }
            .padding()
        }
    }
}

struct AddSnipView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            AddSnipView(isPresented: .constant(true), selectedCategoryName: "Sample Category")
                .previewLayout(.sizeThatFits)
                .padding()
                .environment(\.colorScheme, .light) // Preview in light mode
        }
    }
}


