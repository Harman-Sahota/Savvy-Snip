import SwiftUI

struct SnipDetailView: View {
    let title: String
    let code: String
    let timestamp: Date
    @Environment(\.colorScheme) var colorScheme
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d yyyy 'at' h:mm a"
        return formatter
    }()
    
    init(title: String, code: String, timestamp: Date) {
        self.title = title
        self.code = code
        self.timestamp = timestamp
        
        // Print the code to the console
        print("Code:", code)
    }
    
    var body: some View {
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
                
                Text("Created on: \(dateFormatter.string(from: timestamp))")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                
                
                Spacer()
            }
            .padding()
        }
    }
    
}

struct SnipDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        SnipDetailView(title: "Sample Snip", code: "print(\"Hello, World!\")", timestamp: Date())
    }
}
