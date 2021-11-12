//
//  AchievementsView.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//

import SwiftUI
import FirebaseFirestore

struct AchievementsView: View {
    @State var title: String = ""
    @State var image: String = ""
    @State var timestamp: Timestamp
    @State var points: Double = 0.0
    
    var body: some View {
        VStack{
            
            ImageView(image)
                .frame(width: 100, height: 100, alignment: .center)
                
            Text(title)
                .fontWeight(.bold)
                .frame(width: 100, height: 100)
                .multilineTextAlignment(.center)
        }
        
    }
}

//struct AchievementsView_Previews: PreviewProvider {
//    static var previews: some View {
//        AchievementsView()
//    }
//}
