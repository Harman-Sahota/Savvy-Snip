import SwiftUI

struct ContentView: View {
    @State private var registrationActive: Bool = false
    @State private var loginActive: Bool = false
    @State private var hideBackButtonForHome: Bool = false
    
    var body: some View {
        VStack{
            
            Image("LaunchImage")
                .resizable()
                .frame(width: 300, height: 300)
            
            Spacer()
            
            NavigationLink{
                RegisterWithEmail()
            } label: {
                Text("Sign Up With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.blue)
                    .cornerRadius(10.0)
            }
            
            
            Spacer()
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack{
            ContentView()
        }
    }
}
