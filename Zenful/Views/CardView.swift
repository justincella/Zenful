//
//  CardView.swift
//  Zenful
//
//  Created by Justin Cella on 3/11/21.
//

import SwiftUI

struct CardView: View {
    var dataPercent: [Type]
    @State var title: String
    
    var body: some View {
        ZStack{
            
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(gradient: Gradient(colors: [Color("LightBlue"), Color("DarkBlue")]), startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .frame(width: 325, height: 350)
                .shadow(color: Color("LightShadow"), radius: 5, x: -2, y: -2)
                .shadow(color: Color("DarkShadow"), radius: 5, x: 2, y: 2)
            
            VStack{
                Text(title)
                    .fontWeight(.bold)
                    .padding()
                    .font(.title)
                
                HStack(alignment: .bottom, spacing: 8){
                    
                    ForEach(dataPercent) { data in
                        let percent = data.percent
                        let day = data.day
                        
                        Bar(percent: percent, day: day)
                    }
                }.frame(minHeight: 250, alignment: .bottom).padding(.bottom)
                
            }
            
        }
        .frame(maxWidth: 350, maxHeight: 375)
        .padding()
        
        
    }
}

//struct CardView_Previews: PreviewProvider {
//    static var previews: some View {
//        CardView()
//    }
//}
