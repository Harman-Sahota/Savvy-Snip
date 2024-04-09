import SwiftUI

struct Home: View {
    let username: String?
    
    var body: some View {
        VStack {
            if let username = username {
                Text("Welcome, \(username)")
                    .font(.title)
                    .fontWeight(.bold)
            } else {
                Text("Welcome")
                    .font(.title)
                    .fontWeight(.bold)
            }
            Spacer()
        }
    }
}

#if DEBUG
struct Home_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Home(username: nil)
        }
    }
}
#endif
