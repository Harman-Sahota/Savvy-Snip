import SwiftUI

struct SnipsView: View {
    let categoryName: String
    @State private var isAddSnipViewPresented = false
    @State private var snips: [Snip] = []
    @State private var copiedSnipIndex: Int? // Track the index of the copied snip
    @Environment(\.colorScheme) var colorScheme
    @State private var searchText = ""
    @State private var selectedSnip: Snip? // Track the selected snip for navigation
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d yyyy 'at' h:mm a"
        return formatter
    }()
    
    init(categoryName: String) {
        self.categoryName = categoryName
    }
    
    var body: some View {
            VStack {
                HStack {
                    //MARK: - Add Snip Button
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
                        .padding(.vertical, 10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20) // Increase top padding
                
                // List view to display the snips with proper separation
                List {
                    if snips.isEmpty {
                        Text("No Snips Found.")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        ForEach(filteredSnips.indices, id: \.self) { index in
                            let snip = filteredSnips[index]
                            VStack(alignment: .leading, spacing: 10) {
                                NavigationLink(destination: SnipDetailView(title: snip.title, code: snip.code, timestamp: snip.timestamp, categoryName: categoryName), tag: snip, selection: $selectedSnip) {
                                    EmptyView() // Empty view to enable navigation
                                }
                                .hidden()
                                
                                Text(snip.title)
                                    .font(.headline)
                                    .onTapGesture {
                                        // Navigate to detail view only when the title is tapped
                                        navigateToSnipDetail(snip)
                                    }
                                
                                HighlightedCodeView(code: String(snip.code.prefix(200)), colorScheme: colorScheme)
                                    .padding()
                                    .frame(height: 100)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray, lineWidth: 1)
                                    )
                                
                                HStack {
                                    Text(dateFormatter.string(from: snip.timestamp.dateValue()))
                                        .font(.caption)
                                        .foregroundColor(Color.gray)
                                    
                                    Spacer()
                                    
                                    // Share Button
                                    Button(action: {
                                        print("Share button tapped for index \(index)")
                                        shareSnip(snip)
                                    }) {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 20))
                                            .padding(8)
                                            .background(Color.clear)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to remove button styling
                                    
                                    // Copy Button
                                    Button(action: {
                                        print("Copy button tapped for index \(index)")
                                        copyToClipboard(String(snip.code), index: index)
                                    }) {
                                        Image(systemName: copiedSnipIndex == index ? "checkmark.circle.fill" : "doc.on.doc")
                                            .foregroundColor(copiedSnipIndex == index ? .green : .blue)
                                            .font(.system(size: 20))
                                            .padding(8)
                                            .background(Color.clear)
                                            .cornerRadius(8)
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to remove button styling
                                }
                            }
                            .padding(.vertical, 20) // Increase vertical padding for each list item
                        }
                    }
                }
                .searchable(text: $searchText)
                .onAppear {
                    fetchSnips()
                }
            }
            .navigationBarTitle(categoryName, displayMode: .large)
            .navigationBarItems(trailing:
                Button(action: {
                    isAddSnipViewPresented = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $isAddSnipViewPresented) {
                AddSnipView(isPresented: $isAddSnipViewPresented, selectedCategoryName: categoryName)
                    .onDisappear {
                        fetchSnips()
                    }
            }
        }
    
    private var filteredSnips: [Snip] {
        if searchText.isEmpty {
            return snips
        } else {
            return snips.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private func fetchSnips() {
        // Call the getSnips function to retrieve snips for the current category name
        AuthManager().getSnips(forCategoryName: categoryName) { result, error in
            if let error = error {
                // Handle error
                print("Error fetching snips: \(error.localizedDescription)")
            } else if let snips = result {
                // Sort snips by timestamp in descending order
                self.snips = snips.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() })
            }
        }
    }
    
    // Function to navigate to snip detail view
    private func navigateToSnipDetail(_ snip: Snip) {
        selectedSnip = snip
    }
    
    // Function to share snip
    private func shareSnip(_ snip: Snip) {
        let activityViewController = UIActivityViewController(activityItems: [snip.code], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
    }
    
    // Function to copy snip to clipboard
    private func copyToClipboard(_ code: String, index: Int) {
        UIPasteboard.general.string = code
        copiedSnipIndex = index // Update the index of the copied snip
        
        // Reset copiedSnipIndex after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            copiedSnipIndex = nil
        }
    }
}

struct SnipsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SnipsView(categoryName: "Sample Snip")
        }
    }
}
