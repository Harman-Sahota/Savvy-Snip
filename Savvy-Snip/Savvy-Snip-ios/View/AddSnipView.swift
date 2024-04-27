import SwiftUI
import Highlightr

struct HighlightedCodeView: UIViewRepresentable {
    @Binding var code: String
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTheme: String = ""
    
    let lightTheme = "atom-one-dark"
    let darkTheme = "mono-blue"
    
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.backgroundColor = UIColor(Color.clear)  // Light blue color
        textView.font = UIFont.systemFont(ofSize: 30)
        return textView
    }
    
    private func setTheme() {
        let highlightr = Highlightr()
        if colorScheme == .dark {
            selectedTheme = darkTheme
        }
        if colorScheme == .light  {
            selectedTheme = lightTheme
        }
        highlightr?.setTheme(to: selectedTheme)
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        let highlightr = Highlightr()
        setTheme()
        
        if let highlightedCode = highlightr?.highlight(code, fastRender: true) {
            uiView.attributedText = highlightedCode
        } else {
            print("Code could not be highlighted")
            uiView.text = code
        }
    }
}

struct AddSnipView: View {
    @Binding var isPresented: Bool
    @State private var title: String = ""
    @State private var code: String = ""
    @State private var showError: Bool = false
    
    var body: some View {
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
                HighlightedCodeView(code: $code)
                    .frame(maxWidth: .infinity, minHeight: 200) // Set a minHeight for the HighlightedCodeView
                    .background(Color.clear)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Button(action: {
                    // Validation
                    if title.isEmpty || code.isEmpty {
                        showError = true
                    } else {
                        // Save action
                        isPresented = false // Close the sheet view
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
            AddSnipView(isPresented: .constant(true))
                .previewLayout(.sizeThatFits)
                .padding()
                .environment(\.colorScheme, .dark) // Preview in dark mode
        }
    }
}
