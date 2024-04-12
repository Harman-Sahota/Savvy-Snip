import SwiftUI
import FirebaseAuth // Make sure FirebaseAuth is imported

struct RootView: View {
    
    @State private var showSignInView: Bool = false
    private let authManager = AuthManager()
    
    var body: some View {
        ZStack {
            NavigationStack {
                CategoryView(showSignInView: $showSignInView)
            }
        }
        .onAppear {
            let authUser = try? authManager.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        }
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack{
                ContentView()
            }
        }
    }
    
}



struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            RootView()
        }
    }
}
