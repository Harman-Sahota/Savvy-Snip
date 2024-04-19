import SwiftUI

struct SnipsView: View {
    let categoryName: String
    
    var body: some View {
        Text("Snips for \(categoryName)")
            .navigationBarTitle(categoryName)
    }
}

struct SnipsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            SnipsView(categoryName: "Sample Category")
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}
