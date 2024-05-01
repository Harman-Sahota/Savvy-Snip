import SwiftUI
import FirebaseFirestore

struct SnipDetailView: View {
    let title: String
    let code: String
    let timestamp: Timestamp
    let categoryName: String
    @Environment(\.colorScheme) var colorScheme
    private let authManager = AuthManager()
    @Environment(\.presentationMode) var presentationMode

    
    @State private var isMenuExpanded = false
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d yyyy 'at' h:mm a"
        return formatter
    }()
    
    init(title: String, code: String, timestamp: Timestamp, categoryName: String) {
        self.title = title
        self.code = code
        self.timestamp = timestamp
        self.categoryName = categoryName
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(title)
                        .font(.largeTitle)
                        .padding(.bottom, 10)
                    
                    HighlightedCodeView(code: code, colorScheme: colorScheme)
                        .padding()
                        .frame(minHeight: 100)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    
                    Text("Created on: \(dateFormatter.string(from: timestamp.dateValue()))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            Spacer()
            
            if isMenuExpanded {
                VStack {
                    Button(action: {
                        withAnimation {
                            isMenuExpanded.toggle()
                        }
                    }) {
                        Text("Menu")
                            .font(.headline)
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(Color.white)
                            .cornerRadius(8)
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                    
                    Divider()
                        .background(colorScheme == .dark ? Color.white : Color.black)
                    
                    VStack(spacing: 0) {
                        Button("Delete Snip") {
                            deleteSnip()
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        
                        Divider()
                            .background(colorScheme == .dark ? Color.white : Color.black)
                        
                        Button("Edit") {
                            // Add functionality for editing
                        }
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        
                        Divider()
                            .background(colorScheme == .dark ? Color.white : Color.black)
                        
                        Button("Cancel") {
                            withAnimation {
                                isMenuExpanded.toggle()
                            }
                        }
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                    }
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                }
                .padding()
            } else {
                Button(action: {
                    withAnimation {
                        isMenuExpanded.toggle()
                    }
                }) {
                    Text("Menu")
                        .font(.headline)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16) // Added padding here
                        .background(Color.gray)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                        .cornerRadius(8)
                        .padding(.bottom, 8)
                }
            }
        }
    }
    
    func deleteSnip() {
        print("Delete button tapped")
        authManager.deleteSnip(categoryName: categoryName, title: title, code: code, timestamp: timestamp) { error in
            if let error = error {
                print("Error deleting snip: \(error.localizedDescription)")
            }
            else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct SnipDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SnipDetailView(title: "Sample Snip", code: "print(\"Hello, World!\")", timestamp: Timestamp(date: Date()), categoryName: "Sample Category")
    }
}
