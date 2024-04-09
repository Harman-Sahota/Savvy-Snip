import SwiftUI

struct CreateAccountScreen: View {
    
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                VStack(spacing: 15) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1) // Border for the email text field
                            .frame(width: 300, height: 50)
                        
                        TextField("Email", text: $email)
                            .padding(.horizontal)
                            .frame(width: 280) // Adjust width to fit within the rectangle
                    }
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1) // Border for the password secure text field
                            .frame(width: 300, height: 50)
                        
                        SecureField("Password", text: $password)
                            .padding(.horizontal)
                            .frame(width: 280) // Adjust width to fit within the rectangle
                    }
                    
                    Button("Register") {
                        /* Action code */
                    }
                    .frame(width: 300, height: 20)
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .textCase(.uppercase)
                    
                }
                
                Spacer()
                
            }
            .padding()
            .navigationBarTitle("Create Account", displayMode: .large)
            .navigationBarBackButtonHidden(false)
        }
    }
}

#if DEBUG
struct CreateAccountScreen_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountScreen()
    }
}
#endif
