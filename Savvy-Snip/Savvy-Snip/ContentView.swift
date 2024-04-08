import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(rectangleColor)
                .edgesIgnoringSafeArea(.all) // Fill the entire window
            
            VStack {
                
                HStack {
                    Text("Your Categories")
                        .font(.title) // Set as a heading
                        .foregroundColor(textColor) // Set text color
                        .padding(.top, 40)
                    // Add top padding
                    
                    Button("Add A New Category") {
                        //do something
                    }
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.top, 40)
                }
                
                Spacer() // Spacer to push views to the top
            }
        }
    }
    
    // Variables from Constants
    var textColor: Color {
        return colorScheme == .dark ? K.darkTextColor : K.lightTextColor
    }
    
    var rectangleColor: Color {
        return colorScheme == .dark ? K.darkBackgroundColor : K.lightBackgroundColor
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
