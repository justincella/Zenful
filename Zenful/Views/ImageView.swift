//
//  ImageView.swift
//  Zenful
//
//  Created by Justin Cella on 5/11/21.
//

import SwiftUI

struct ImageView: View {
    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()
    var scale : CGFloat = 0

    init(_ imageName: String) {
        imageLoader = ImageLoader(imageName)
    }
    
    var body: some View {
        
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .animation(
                .easeInOut(duration: 1)
            )
            .onReceive(imageLoader.didChange) { data in
                self.image = UIImage(data: data) ?? UIImage()
            }
        
        
    }
}
//struct ImageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageView()
//    }
//}
