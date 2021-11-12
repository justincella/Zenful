//
//  AppDelegate.swift
//  Zenful
//
//  Created by Chris on 4/1/21.
//

import Firebase
import FirebaseAuth

class AppDelegate: UIResponder, UIApplicationDelegate {
    var appState: AppState = AppState()
        
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            FirebaseApp.configure()
            
//            let firebaseAuth = Auth.auth()
//            do {
//                try firebaseAuth.signOut()
//                self.appState.loggedIn = false
//            
//            } catch let signOutError as NSError {
//                print ("Error signing out: %@", signOutError)
//            }
            
            Auth.auth().addStateDidChangeListener { (auth, user) in
                let user = Auth.auth().currentUser
                
                
                if let user = user {
                    // The user's ID, unique to the Firebase project.
                    // Do NOT use this value to authenticate with your backend server,
                    // if you have one. Use getTokenWithCompletion:completion: instead.
                    let uid = user.uid
                    let email = user.email
                    let displayName = user.displayName ?? ""
                    
                    
                    self.appState.loggedIn = true
                    
                    
                    let db = Firestore.firestore()
                    let usersRef = db.collection("Users")
                    let docRef = usersRef.document(user.uid)
                    
                    
                    
                    docRef.addSnapshotListener { documentSnapshot, error in
                        guard let document = documentSnapshot else {
                            print("Error fetching document: \(error!)")
                            return
                        }
                        guard let data = document.data() else {
                            print("Document data was empty.")
                            return
                        }
                        
                        let photo = data["photo"] as? String ?? "default.png"
                        var level = data["level"] as? Int ?? 0
                        let levelProgress = data["levelProgress"] as? Double ?? 1
                        let achievementsArray = data["achievements"] as! Array<[String: Any]>
                        let goalSleep = data["goalSleep"] as? Int ?? 0
                        let goalMeditation = data["goalMeditation"] as? Int ?? 0
                        let goalDistractions = data["goalDistractions"] as? Int ?? 0
//                        let streak = data["streak"] as? Int ?? 0
//                        let streakUpdate = data["streakUpdate"] as? Timestamp ?? Timestamp(date: Date())
                        
                        let progress: Double = (levelProgress / Double(level)) / 100
                        
                        if progress >= 1.000 {
                            level += 1
                            docRef.setData(["level": level, "levelProgress": 0], merge: true)
                            
                        }
                            
                        var achievementList: Array<Achievement> = []
                        
                        if achievementsArray.count > 0 {
                        
                            for achievements in achievementsArray {
                                let title = achievements["title"] as? String ?? ""
                                let points = achievements["points"] as? Double ?? 0
                                let image = achievements["image"] as? String ?? ""
                                let timestamp = achievements["timestamp"] as? Timestamp ?? Timestamp(date: Date())
                                    
                                achievementList.append(Achievement(title: title, points: points, timestamp: timestamp, image: image))
                                
                            }
                        }
                            
                        self.appState.user = User(
                            uid: uid,
                            email: email!,
                            photo: photo,
                            displayName: displayName,
                            level: level,
                            levelProgress: levelProgress,
                            achievement: achievementList,
                            goalSleep: goalSleep,
                            goalMeditation: goalMeditation,
                            goalDistractions: goalDistractions
//                            streak: streak,
//                            streakUpdate: streakUpdate
                        )
                        
                    }
                    
                }else{
                    self.appState.loggedIn = false
                }

                
            }
            return true
        }
}
