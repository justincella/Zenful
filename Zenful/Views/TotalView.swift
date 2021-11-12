//
//  TotalView.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//

import SwiftUI

struct TotalView: View {
    var body: some View {
        VStack{
            Text("TotalView")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack{
                    ForEach(0..<10) {_ in
//                        CardView(title: "Title")
//                        Text("Item \($0)")
//                            .foregroundColor(.white)
//                            .font(.largeTitle)
//                            .frame(width: 200, height: 200)
//                            .background(Color.red)
                    }
                }
            }.frame(height: 300)
        }
    }
}

struct TotalView_Previews: PreviewProvider {
    static var previews: some View {
        TotalView()
    }
}
