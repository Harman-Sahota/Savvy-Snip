import SwiftUI
import FirebaseFirestore

import SwiftUI
import FirebaseFirestore

struct EditSnipView: View {
    @State private var editedTitle: String
    @State private var editedCode: String
    @State private var isEditing: Bool = false
    let snip: Snip
    let categoryName: String
    let onComplete: () -> Void
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme // Add colorScheme environment variable
    
    init(snip: Snip, categoryName: String, onComplete: @escaping () -> Void) {
        self.snip = snip
        self.categoryName = categoryName
        self._editedTitle = State(initialValue: snip.title)
        self._editedCode = State(initialValue: snip.code)
        self.onComplete = onComplete
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("Enter Title", text: $editedTitle)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section(header: Text("Code")) {
                    TextEditor(text: $editedCode)
                        .frame(minHeight: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
                
                Section(header: Text("Highlighted Code")) {
                    HighlightedCodeView(code: editedCode, colorScheme: colorScheme)
                        .frame(minHeight: 200) // Set a minHeight for the HighlightedCodeView
                        .background(Color.clear)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                }
            }
            
            Button(action: {
                updateSnip()
            }) {
                Text("Save Changes")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()
        }
        .navigationTitle("Edit Snip")
        .onAppear {
            editedTitle = snip.title
            editedCode = snip.code
        }
    }
    
    private func updateSnip() {
        let updatedSnip = Snip(title: editedTitle, code: editedCode, timestamp: snip.timestamp)
        AuthManager().updateSnip(snip: updatedSnip, categoryName: categoryName) { error in
            if let error = error {
                print("Error updating snip: \(error.localizedDescription)")
            } else {
                onComplete()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}


struct EditSnipView_Previews: PreviewProvider {
    static var previews: some View {
        EditSnipView(snip: Snip(title: "Sample Snip", code: "print(\"Hello, World!\")", timestamp: Timestamp(date: Date())), categoryName: "Sample Category", onComplete: {})
    }
}
