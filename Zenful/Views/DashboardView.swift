//
//  DashboardView.swift
//  Zenful
//
//  Created by Chris on 5/6/21.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Dashboard: View {
    @EnvironmentObject var appState: AppState
    @State var streak: Int = 0
	//Retrieve data from Firebase
	//Has to be CGFloat due to progress bar library.
	@State var totalMeditation: CGFloat = 0.0
	@State var totalDistractions: CGFloat = 0.0
	@State var totalSleep: CGFloat = 0.0
	
	@State var goalMeditation: CGFloat = 1.0
	@State var goalDistractions: CGFloat = 1.0
	@State var goalSleep: CGFloat = 1.0
	
	@State var progressMeditation: Double = 0
	@State var progressDistractions: Double = 0
	@State var progressSleep: Double = 0
	
	
    @State var meditationPercents: [Type] = []
    @State var distractionPercents: [Type] = []
    @State var sleepPercents: [Type] = []
    
    @ObservedObject var meditateVM = MeditateVM()
    @ObservedObject var sleepVM = SleepVM()
    
	var body: some View {
        VStack{
			Text("\(streak) Day Streak")
				.padding()
				.font(.largeTitle)
			
			//ProgressMeditation is a percent. Meditation / Goal Meditation
			Text("Meditation (mins)")
			ProgessbarView(value: $progressMeditation)
                .frame(width: 350, height: 20)
                .padding(.bottom)
                
			//ProgressDistractions is a percent. Distractions / Goal Distractions
			Text("Distractions")
			ProgessbarView(value: $progressDistractions)
                .frame(width: 350, height: 20)
                .padding(.bottom)
                
            //ProgressSleep is a percent. Sleep / Goal Sleep
			Text("Sleep (hrs)")
			ProgessbarView(value: $progressSleep)
                .frame(width: 350, height: 20)
                .padding(.bottom)
			
			// Display Weekly Bargraphs
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack(spacing: -10){
                    CardView(dataPercent: meditationPercents, title: "Meditation")
                    CardView(dataPercent: distractionPercents, title: "Distractions")
                    CardView(dataPercent: sleepPercents, title: "Sleep")
                }
            }
		}
        .onAppear(){
            getDataFromFirebase()
            calculateProgress()
            populateWeeklyData()
            
            meditateVM.fetchData()
            sleepVM.fetchData()
            streakUpdater()
            
            
        }
//        .onDisappear{
//			meditationPercents = []
//			distractionPercents = []
//			sleepPercents = []
//		}
	}
	
	func streakUpdater(){
		let db = Firestore.firestore()
		guard let currentUserID = Auth.auth().currentUser?.uid else {
			print("Error Collecting: UID")
			return
		}
		let profile = db.collection("Users").document(currentUserID)
		var lastLogin: Timestamp = Timestamp(date: Date())
		let today: Timestamp = Timestamp(date: Date())
		
		profile.getDocument { (document, error) in
			if let document = document, document.exists {
				//Get last streak update from Firebase.
				guard let lastLogin = document.get("streakUpdate") as? Timestamp else {
					print("Error Collecting: streakUpdate")
					print("Making streakUpdate")
					let data = ["streak": 0, "streakUpdate": today] as [String : Any]
					db.collection("Users").document(currentUserID).setData(data, merge: true)
					return
				}
				streak = (document.get("streak") as? Int)!
				
				//Convert timestamp to something comparable
				let last1 = lastLogin.dateValue()
				let today1 = today.dateValue()
				
				//86400 seconds = 24 hours
				//Last Login > 24 hours ago AND Last Login < 48 Hours ago
				let differenceInSeconds = today1.timeIntervalSince(last1)

				//Last Login > 24 hours AND Last Login < 48 hours
				if (differenceInSeconds > 86400 && differenceInSeconds < (86400*2)){
					streak = streak + 1
                    
                    
                    // Adds streaks to levelProgress
                    let streakPoints: Double = Double(streak) * 1.5
                    db.collection("Users").document(currentUserID).updateData(["levelProgress" : FieldValue.increment(streakPoints)])
                    
                    db.collection("Users").document(currentUserID).setData(["streak": streak, "streakUpdate": today], merge: true)
				}else if(differenceInSeconds > (86400*2)){
				//Last Login > 48 hours. Then Reset.
					streak = 0
					let data = ["streak": streak]
					db.collection("Users").document(currentUserID).setData(data, merge: true)
				}
            } else {
                print("Document does not exist in cache")
            }
        }
	}
	
	func getDataFromFirebase(){
		let db = Firestore.firestore()
		
		guard let test = Auth.auth().currentUser?.uid else {
			print("Error Collecting: UID")
			return
		}
		let userID = test
        
		let meditation = db.collection("Users").document(userID).collection("meditation").document(CurrentDate())
		let sleep = db.collection("Users").document(userID).collection("sleep").document(CurrentDate())
    
		//Get progress bar data.
        meditation.getDocument { (document, error) in
			if let document = document, document.exists {
                self.goalMeditation = CGFloat(appState.user!.goalMeditation)
                self.goalDistractions = CGFloat(appState.user!.goalDistractions)
				
				guard let test3 = document.get("totalMeditation") as? CGFloat else {
					print("Error Collecting: totalMeditation")
					return
				}
				totalMeditation = test3
				
				guard let test4 = document.get("totalDistractions") as? CGFloat else {
					print("Error Collecting: totalDistractions")
					return
				}
				totalDistractions = test4
				
            } else {
                print("Document does not exist in cache")
            }
        }
        
        //Get progress bar data.
        sleep.getDocument { (document, error) in
			if let document = document, document.exists {
				
                self.goalSleep = CGFloat(appState.user!.goalSleep)
				
				guard let test2 = document.get("totalSleep") as? CGFloat else {
					print("Error Collecting: totalSleep")
					return
				}
				totalSleep = test2
            } else {
                print("Document does not exist in cache")
            }
        }
	}
	
	//CGFloat has to be used for progress bar library. CGFloat has to be cast to Float to calculate progress. Progress can't be CGFloat....
	func calculateProgress(){
        
		progressMeditation = Double(totalMeditation/60) / Double(goalMeditation)
		progressDistractions = Double(totalDistractions) / Double(goalDistractions)
		progressSleep = Double(totalSleep) / Double(goalSleep)
		
		//Error checking for greater than 100%.
		if (progressMeditation > 1 ){
            progressMeditation = 1
		}
		//Error checking for greater than 100%.
		if (progressDistractions > 1){
			progressDistractions = 1
		}
		//Error checking for greater than 100%.
		if (progressSleep > 1){
			progressSleep = 1
		}
	}
	
	func populateWeeklyData(){
		//Get weekly bar graphs data.
		let db = Firestore.firestore()
		guard let test = Auth.auth().currentUser?.uid else {
			print("Error Collecting: UID")
			return
		}
		let userID = test
		let meditation = db.collection("Users").document(userID).collection("meditation")
		let sleep = db.collection("Users").document(userID).collection("sleep")
		
        self.meditationPercents = []
        self.distractionPercents = []
        self.sleepPercents = []
        
        meditation.order(by: "timestamp", descending: true).limit(to: 7).getDocuments() { (querySnapshot, err) in
			if let err = err {
				print("Error getting documents: \(err)")
			} else {
				var count = 0
				var percentM: Double = 0
				var percentD: Double = 0
				
				for document in querySnapshot!.documents {
                    
                    
                    guard let totalMeditation: Double = document.get("totalMeditation") as? Double else {
                        print("Error Collecting: totalMeditation")
                        return
                    }
                    
                    guard let totalDistractions: Double = document.get("totalDistractions") as? Double else {
						print("Error Collecting: totalDistractions")
						return
					}
					
                    percentM = ((totalMeditation / 60) /  Double(self.goalMeditation)) * 100
                    percentD = (totalDistractions / Double(self.goalDistractions)) * 100
                    
					//Error checking for greater than 100%.
					if (percentM > 100){
						percentM = 100
					}
					//Error checking for greater than 100%.
					if (percentD > 100){
						percentD = 100
					}
                    
                    
                    meditationPercents.append(Type(id: count, percent: CGFloat(percentM), day: String(count)))
					distractionPercents.append(Type(id: count, percent: CGFloat(percentD), day: String(count)))
					
                    
					count+=1
                    
				}
			}
		}
		
		sleep.order(by: "timestamp", descending: true).limit(to: 7).getDocuments() { (querySnapshot, err) in
			if let err = err {
				print("Error getting documents: \(err)")
			} else {
				var count = 0
				var percentSleep: Double = 0
				
				for document in querySnapshot!.documents {
					
                    let goalSleep: Double = Double(self.appState.user!.goalSleep)
					
					guard let test2 = document.get("totalSleep") as? Double else {
						print("Error Collecting: totalSleep")
						return
					}
					let totalSleep: Double = test2
					
					percentSleep = (totalSleep / goalSleep) * 100
					
					//Error checking for greater than 100%.
					if (percentSleep > 100){
						percentSleep = 100
					}
					
					sleepPercents.append(Type(id: count, percent: CGFloat(percentSleep), day: String(count)))
					count+=1
				}
			}
		}
	}
}
