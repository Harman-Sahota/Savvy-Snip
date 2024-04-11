import SwiftUI

struct ContentView: View {
    @State private var registrationActive: Bool = false
    @State private var loginActive: Bool = false
    @State private var hideBackButtonForHome: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image("LaunchImage")
                    .resizable()
                    .frame(width: 300, height: 300)
                
                Spacer()
                
                Button(action: {
                    registrationActive = true
                }) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(
                    destination: CreateAccountScreen(),
                    isActive: $registrationActive,
                    label: { EmptyView() }
                )
                .isDetailLink(false) // Disable back button for this link
                
                Button(action: {
                    loginActive = true
                }) {
                    Text("Login with email")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(
                    destination: LoginWithEmail(),
                    isActive: $loginActive,
                    label: { EmptyView() }
                )
                .isDetailLink(false) // Disable back button for this link
                
                Spacer()
                
                Text("OR")
                    .font(.subheadline)
                
                Rectangle() // Horizontal line
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 30)
                    .padding(.top, -5)
                
                Spacer()
            }
            .padding() // Add overall padding to the VStack
            .navigationBarBackButtonHidden(hideBackButtonForHome)
            .onChange(of: loginActive) { newValue in
                // Hide back button when navigating to Home from LoginWithEmail
                hideBackButtonForHome = newValue
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
