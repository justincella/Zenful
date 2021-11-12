//
//  ProgessbarView.swift
//  Zenful
//
//  Created by Justin Cella on 3/25/21.
//

import SwiftUI

struct ProgessbarView: View {
    @Binding var value: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().frame(width: geometry.size.width , height: geometry.size.height)
                    .opacity(0.3)
                    .foregroundColor(Color(UIColor.systemTeal))
                
                Rectangle().frame(width: min(CGFloat(self.value)*geometry.size.width, geometry.size.width), height: geometry.size.height)
                    .foregroundColor(Color(UIColor.systemBlue))
                    .animation(.linear)
            }
            .cornerRadius(45.0)
            
        }
    }
}
//
//struct ProgessbarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgessbarView(value: <#Binding<Float>#>)
//    }
//}
