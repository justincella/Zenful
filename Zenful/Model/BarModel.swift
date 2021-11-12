//
//  BarModel.swift
//  Zenful
//
//  Created by Chris on 5/6/21.
//

import Foundation
import SwiftUI

struct Bar : View {
	@State var percent : CGFloat
    var day: String
	
	var body : some View{
		VStack{
			Text(String(format: "%.0f", Double(percent)) + "%")
            
			Rectangle().fill(Color.green).frame(width: 20, height: getHeight())
                .cornerRadius(45)
            
			Text(day)
		}
	}
	
	func getHeight()->CGFloat{
		return 200 / 100 * percent
	}
}
