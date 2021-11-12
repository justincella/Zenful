//
//  ImageLoader.swift
//  Zenful
//
//  Created by Justin Cella on 5/11/21.
//

import Foundation
import FirebaseStorage
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }

    
    init(_ imageName:String) {
        let ref = Storage.storage().reference(withPath: "images/\(imageName)")

        ref.getData(maxSize: 1 * 1024 * 1024) {data, error in
            if let error = error {
                print("Error fetching image: \(imageName)")
                print(error.localizedDescription)
            } else {
                
                
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.data = data
                }
            }
        }
       
    }
}
