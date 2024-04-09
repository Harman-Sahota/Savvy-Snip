import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                Text("Welcome to Savvy Snip")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                NavigationLink(destination: CreateAccountScreen()) {
                    Text("Register")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 40)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                        .textCase(.uppercase)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                
                NavigationLink(destination: LoginWithEmail()) {
                    Text("Login with Email")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 40)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                        .textCase(.uppercase)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                
                Spacer()
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
        }
        .background(
            Rectangle()
                .foregroundColor(Color("LaunchColor"))
                .ignoresSafeArea()
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
