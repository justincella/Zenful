//
//  SettingsView.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

struct SettingsView: View {
	let db = Firestore.firestore()
    @EnvironmentObject var appState: AppState
    @State var name: String = ""
	@State var email: String = ""
	@State var meditation: String = ""
	@State var sleep: String = ""
	@State var distractions: String = ""
	@State var password: String = ""
	@State private var notify = true
	@State private var schedule = true
	
    var body: some View {
        ScrollView{
            VStack{
                Text("Profile Settings")
                    .font(.title2)
                
                TextField("Full Name", text: $name)
                    .padding()
                    .background(Color.init(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .disableAutocorrection(true)
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.init(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .disableAutocorrection(true)
                    .keyboardType(.emailAddress)
                
                TextField("Password", text: $password)
                    .padding()
                    .background(Color.init(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .disableAutocorrection(true)
            
                Text("Daily Goal Settings")
                    .font(.title2)
                
                TextField("Meditation (minutes)", text: $meditation)
                    .padding()
                    .background(Color.init(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .disableAutocorrection(true)
                    .keyboardType(.numberPad)
                
                TextField("Sleep (hours)", text: $sleep)
                    .padding()
                    .background(Color.init(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .disableAutocorrection(true)
                    .keyboardType(.numberPad)
                
                TextField("Distractions", text: $distractions)
                    .padding()
                    .background(Color.init(.systemGray6))
                    .cornerRadius(5.0)
                    .padding(.bottom, 20)
                    .disableAutocorrection(true)
                    .keyboardType(.numberPad)
                
                Group{
                    Toggle("Allow Notifications", isOn: $notify)
                    Toggle("Schedule Reminder", isOn: $schedule)
                }
                
                Button(action: { submit() }) {
                    Text("Save")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                }
                
                
            }
            .padding()
            Spacer()
            .navigationBarTitle("Settings", displayMode: .inline)
            .onAppear{
                getSettingsFromFirebase()
                allowNotifications() //If enabled
                scheduleReminder()
            }
            
            Spacer()
            
            Button(action: logout, label: {
                Text("Logout")
                    .foregroundColor(.red)
                    .font(.headline)
            })
            
            
            Spacer()
        }
	}
    
    func logout(){
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            self.appState.loggedIn = false
        
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
	
	func allowNotifications(){
		if (notify) {
			UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
				if success {
					print("All set!")
				} else if let error = error {
					print(error.localizedDescription)
				}
			}
		}
	}
	
    func scheduleReminder(){
		if (schedule) {
			let content = UNMutableNotificationContent()
			content.title = "Remember to Meditate!"
			content.subtitle = "Meditation requires consistency"
			content.sound = UNNotificationSound.default

			// show this notification 60 seconds * 60 mins * 24 hours
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (60*60*24), repeats: true)

			// choose a random identifier
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

			// add our notification request
			UNUserNotificationCenter.current().add(request)
		}
	}
	
    
    func getSettingsFromFirebase(){
		guard let currentUserID = Auth.auth().currentUser?.uid else {
			print("Error Collecting: UID")
			return
		}
        
        name = Auth.auth().currentUser!.displayName!
        email = Auth.auth().currentUser!.email!
        
//		let db = Firestore.firestore()
//		//Replace testProfile with logged in user.
//		let profile = db.collection("Users").document(currentUserID)
//
//        profile.getDocument { (document, error) in
//			if let document = document, document.exists {
//                name = self.appState.user!.displayName
//                email = self.appState.user!.email
////                password = document.get("password") as! String
//            } else {
//                print("Document does not exist in cache")
//            }
//        }
	}
	
	func writeSettingsToFirebase(){
		guard let userID = Auth.auth().currentUser?.uid else {
			print("Error Collecting: UID")
			return
		}
		let goalMeditation = Int(meditation) ?? 0 //Set to 0, if not a number.
        let goalSleep: Int = Int(sleep) ?? 0
		let goalDistractions = Int(distractions) ?? 0

//		let profile = ["username": name, "email": email, "password": password, "timestamp": Timestamp(date: Date())] as [String : Any]
		let meditationGoals = ["goalMeditation": goalMeditation, "goalDistractions": goalDistractions]
		let sleepGoals = ["goalSleep": goalSleep, "timestamp": Timestamp(date: Date())] as [String : Any]
        
        
        let userInfo = Auth.auth().currentUser
        if let userInfo = userInfo{
            let changeRequest = userInfo.createProfileChangeRequest()
            changeRequest.displayName = name
        
            changeRequest.commitChanges { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                
                appState.user?.displayName = name
            }
        }
        
        Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            db.collection("Users").document(userID).setData(["email": email], merge: true)
            appState.user?.email = email
        })
        
        if !password.isEmpty {
            Auth.auth().currentUser?.updatePassword(to: password, completion: { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            })
        }
        
        db.collection("Users").document(userID).setData(meditationGoals, merge: true)
        db.collection("Users").document(userID).setData(sleepGoals, merge: true)
	}
	
	func CurrentDate() -> String{
		// get the current date and time
		let currentDateTime = Date()

		// initialize the date formatter and set the style
		let formatter = DateFormatter()
		formatter.timeStyle = .none
		formatter.dateStyle = .long
		//Get the date time String from the date object
		let today = formatter.string(from: currentDateTime) //"October 8, 2016"
		
		return today
	}
	
	//Reset text fields to values in Firebase.
	func resetTextFields(){
		getSettingsFromFirebase()
		
        meditation = ""
        sleep = ""
        distractions = ""
	}
	
	func submit(){
		writeSettingsToFirebase()
		resetTextFields()
	}
}
	
//struct SettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsView()
//    }
//}
