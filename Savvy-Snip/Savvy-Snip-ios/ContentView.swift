import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("LaunchImage")
                    .resizable()
                    .frame(width: 300, height: 300)
                
                Spacer()
                
                NavigationLink(destination: CreateAccountScreen()) {
                    Text("Register")
                        .frame(width: 300, height: 20)
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .textCase(.uppercase)
                }
                
                NavigationLink(destination: LoginWithEmail()) {
                    Text("Login with email")
                        .frame(width: 300, height: 20)
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .textCase(.uppercase)
                }
                
                Spacer()
                
                Text("OR")
                    .font(.subheadline)
                
                Rectangle() // Horizontal line
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                    .padding(.top, -5)
                
                Spacer()
                
                
                Spacer()
            }
        } .onAppear {
            // Hide the navigation bar when this view appears
            UINavigationBar.appearance().isHidden = true
        }
        .onDisappear {
            // Show the navigation bar when this view disappears
            UINavigationBar.appearance().isHidden = false
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
