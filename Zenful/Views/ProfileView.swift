//
//  ProfileView.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//

import SwiftUI
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @State var progressValue: Double = 0.0
    @State private var showingImagePicker = false

    @State private var image: Image?
    @State private var inputImage: UIImage?
    
    let columns = [
        GridItem(.adaptive(minimum: 100))
    ]
    
    var body: some View {
        let achievements = self.appState.user!.achievement
        let level = self.appState.user?.level ?? 1
        let picture = self.appState.user?.photo ?? "default.png"
        
        ScrollView{
            
            ImageView(picture)
                .clipShape(Circle())
                .frame(width: 200, height: 200, alignment: .center)
                .padding(.top)
                
                
                Button(action: {
                    self.showingImagePicker = true
                }) {
                    Text("Change Photo")
                        .font(.headline)
                        .padding()
                }
                        
            
            Text("Level \(String(level))")
                .font(.title)
            
            ProgessbarView(value: $progressValue)
                .frame(width: 350, height: 20)
                .padding(.bottom)
             
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(achievements, id: \.self) { achievement in
                    let title = achievement.title
                    let image = achievement.image
                    let timestamp = achievement.timestamp
                    let points = achievement.points
                    
                    
                    AchievementsView(title: title, image: image, timestamp: timestamp, points: points)
                }
            }
            
        }
        .padding(.horizontal)
        .navigationBarTitle("Profile", displayMode: .inline)
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage){
            ImagePicker(image: self.$inputImage)
        }
        
    }
    
    func loadImage() {
        guard let inputImage = inputImage else{ return }
        image = Image(uiImage: inputImage)
        
        
        let uuid = UUID().uuidString
        let name = uuid + ".jpeg"
        let uploadImage = inputImage
        guard let data: Data = uploadImage.jpegData(compressionQuality: 0.2) else {return}
                        
       
                        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
                        
        let uploadTask = Storage.storage().reference(withPath: "images/").child("\(name)").putData(data, metadata: metadata)
         
        uploadTask.observe(.success) { snapshot in
            guard let currentUserID = Auth.auth().currentUser?.uid else {
                print("Error Collecting: UID")
                return
            }
            
            let db = Firestore.firestore()
            db.collection("Users").document(currentUserID).setData(["photo" : name], merge: true)
            
        }
    }
    
}



//
//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        ProfileView()
//    }
//}
