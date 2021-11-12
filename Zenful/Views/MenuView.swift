//
//  MenuView.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//

import SwiftUI
import FirebaseAuth

struct MenuView: View {
    @EnvironmentObject var appState: AppState
    
 
    var body: some View {
        
        let level = self.appState.user?.level ?? 1
        let levelProgress = self.appState.user?.levelProgress ?? 0

        let progress: Double = (levelProgress / Double(level)) / 100
    
        VStack(alignment: .leading){

            
            HStack{
                Image(systemName: "person.circle")
                    .foregroundColor(.gray)
                    .imageScale(.large)
                
                NavigationLink(destination: ProfileView(progressValue: progress)){
                
                    Text("Profile")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top,100)
            
            HStack{
                Image("MeditateIcon")
                    .foregroundColor(.gray)
                    .imageScale(.large)
                
                NavigationLink(destination: MeditateView()){
                Text("Meditate")
                    .foregroundColor(.gray)
                    .font(.headline)
                }.buttonStyle(PlainButtonStyle())
            }
            .padding(.top,30)
            
            HStack{
                       
                Image(systemName: "bed.double.fill")
                    .foregroundColor(.gray)
                
                NavigationLink(destination: SleepView()){
                Text("Sleep")
                    .foregroundColor(.gray)
                    .font(.headline)
                }.buttonStyle(PlainButtonStyle())
                
                
            }
            .padding(.top,30)
            
//            HStack{
//                Image(systemName: "arrow.triangle.2.circlepath.circle")
//                    .foregroundColor(.gray)
//                    .imageScale(.large)
//               
//                NavigationLink(destination: SyncView()){
//                Text("Sync")
//                    .foregroundColor(.gray)
//                    .font(.headline)
//                }.buttonStyle(PlainButtonStyle())
//            }
//            .padding(.top,30)
            
            HStack{ 
                Image(systemName: "gearshape") 
                    .foregroundColor(.gray)
                    .imageScale(.large)
                
                NavigationLink(destination: SettingsView()){
                Text("Settings")
                    .foregroundColor(.gray)
                    .font(.headline)
                }.buttonStyle(PlainButtonStyle())
            }
            .padding(.top,30)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//struct MenuView_Previews: PreviewProvider {
//    static var previews: some View {
//        MenuView()
//    }
//}
