import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color("LaunchColor"))
                .ignoresSafeArea()
            
            VStack {
                Image("LaunchImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .padding()
                
                Spacer()
                Spacer()
                
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 50)
                            .controlSize(.extraLarge)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 50)
                            .controlSize(.extraLarge)
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        // Action code
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(width: 200,height: 40)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .textCase(.uppercase)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    
                    NavigationLink(destination: Text("Forgot your password?")) {
                        Text("Forgot your password?")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    }
                    .padding(.top, 10)
                    
                    NavigationLink(destination: Text("Create An Account")) {
                        Text("Create An Account")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                    }
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
