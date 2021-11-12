//  ContentView.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @State var showMenu = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        
        //Define swipe to open/close Navbar
        let showNav = DragGesture().onEnded {
            if $0.translation.width < 100 {
                withAnimation {
                    self.showMenu = true
                }
            } else { self.showMenu = false }
        }

        if Auth.auth().currentUser == nil {
            LoginView()
        } else {
            NavigationView {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Dashboard()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .offset(x: self.showMenu ? geometry.size.width/2 : 0)
                            .disabled(self.showMenu ? true : false)
                        
                            
                        if self.showMenu {
                            MenuView()
                                .frame(width: geometry.size.width/2)
                                .transition(.move(edge: .leading))
                        }
                        
                    }
                    .gesture(showNav)
                }
                    
                .navigationBarTitle(CurrentDate(), displayMode: .inline)
                .navigationBarItems(
                    //Hamburger Button
                    leading: (
                        Button(action: {
                            withAnimation {
                                self.showMenu.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                        }
                    ),
                    //Social Media Button
                    trailing:(
                    //Placeholder for Social Media
                        Text("Share")
                    )
                )
            }
        }
    }
}

func CurrentDate() -> String{
		// get the current date and time
		let currentDateTime = Date()

		// initialize the date formatter and set the style
		let formatter = DateFormatter()
		formatter.timeStyle = .none
		formatter.dateStyle = .long
		//Get the date time String from the date object
		let today = formatter.string(from: currentDateTime) //"October 8, 2016"
		
		return today
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
