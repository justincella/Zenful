//
//  MeditateView.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//

import SwiftUI
import FirebaseFirestore
import AVFoundation
import FirebaseAuth

struct MeditateView: View {
    @EnvironmentObject var appState: AppState
	@State var playerMusic: AVAudioPlayer?
	@State var playerAlarm: AVAudioPlayer?
	@State private var selectedFrameworkIndex = 0
    @State var showStart = true
	@State var enterTime = true
    @State var count = 0
    @State var hours = 0
    @State var hrsInitial = 0
    @State var minutes = 0
    @State var minsInitial = 0
    @State var seconds = 0
    @State var secsInitial = 0
    @State var totalMeditation = 0 //In minutes
    @State var totalDistractions = 0
    @State var secondsAccumulator = 0
    
    @ObservedObject var meditateVM = MeditateVM()
    
	//Create current meditation session object
    
    var body: some View {
		let current = Session(hrs: hrsInitial, mins: minsInitial, secs: secsInitial, distractions: count, totalMeditationFirebase: totalMeditation, totalDistractionsFirebase: totalDistractions)
		
        VStack{
			//Timer
			if (enterTime == true){
			
				HStack{
					Text("Hours")
						.padding(33)
					Text("Minutes")
						.padding(33)
					Text("Seconds")
						.padding(33)
				} .padding(.top, 200)
				
				GeometryReader { geometry in
				HStack(alignment: .top, spacing: 0.0){
					Picker("Hours", selection: $hours) {
                        ForEach(0..<25) {
							Text("\($0)")
                        }
					}
					.frame(maxWidth: geometry.size.width / 3)
					.clipped()
					.pickerStyle(WheelPickerStyle())

                    Text(" : ")
                    
                    Picker("Minutes", selection: $minutes) {
                        ForEach(0..<61) {
							Text("\($0)")
                        }
					}
					.frame(maxWidth: geometry.size.width / 3)
					.clipped()
					.pickerStyle(WheelPickerStyle())
                    
                    Text(" : ")
                    
                    Picker("Seconds", selection: $seconds) {
                        ForEach(0..<61) {
							Text("\($0)")
                        }
					}
					.frame(maxWidth: geometry.size.width / 3)
					.clipped()
					.pickerStyle(WheelPickerStyle())
				}
				.padding(.top, -50.0)
			}
			} else{
                Spacer()
				HStack{
					Text("\(hours)")
						.font(Font.system(size: 60, design: .default))
					Text(" : ")
						.font(Font.system(size: 60, design: .default))
					Text("\(minutes)")
						.font(Font.system(size: 60, design: .default))
					Text(" : ")
						.font(Font.system(size: 60, design: .default))
					Text("\(seconds)")
						.font(Font.system(size: 60, design: .default))
				}
                .padding(.bottom)
			}
			
			//Start/Stop Buttons
            if (showStart == true){
                Button("Start") {
					hrsInitial = hours
					minsInitial = minutes
					secsInitial = seconds
					
					//Meditation Accumulator
					//totalMeditation = totalMeditation + (hours * 60) + (minutes * 1)
					//totalMeditation = secondsAccumulator
					current.totalMeditationFirebase = totalMeditation
					
					showStart = false //Reset to stop
					enterTime = false
					
                    playMusic()
					
					Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
						if (hours == 0 && minutes == 0 && seconds == 0){
							//If timer stops on its own play alarm.
							//If user presses stop, then do not play alarm.
							if (showStart == false){
								playerMusic?.stop()
								playAlarm()
							}
							timer.invalidate()
						} else if seconds == 0 && minutes == 0{
							hours -= 1
							minutes = 59
							secondsAccumulator+=1
						} else if seconds == 0 && minutes != 59 && minutes > 0{
							minutes -= 1
							seconds = 59
							secondsAccumulator+=1
						} else if seconds == 0 && minutes == 59{
							seconds = 59
							secondsAccumulator+=1
						} else {
							seconds -= 1
							secondsAccumulator+=1
						}
					}
				}
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 220, height: 60)
                .background(Color.blue)
                .cornerRadius(15.0)
                
                Spacer()
                
			} else {
                
                Button("Stop"){
					current.distractions = count
					current.totalDistractionsFirebase = current.totalDistractionsFirebase + count
					//current.submit()
					writeSessionToFirebase()
                    
					stopSound()
					
					showStart = true //Reset to start
					enterTime = true
					hours = 0
					minutes = 0
					seconds = 0
					count = 0
				}
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 220, height: 60)
                .background(Color.blue)
                .cornerRadius(15.0)
                
                Spacer()
				
				Text("\(count)")
					.font(Font.system(size: 60, design: .default))
					.padding(.top, 50)
                
                //Distraction Button
                Button("Distraction") {
                    count+=1
                    totalDistractions+=1
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(width: 220, height: 60)
                .background(Color.blue)
                .cornerRadius(15.0)
            }
            
            
            
        }
        .navigationBarTitle("Meditate", displayMode: .inline)
    }
    
    func writeSessionToFirebase(){
		let db = Firestore.firestore()
		
		totalMeditation = secondsAccumulator
		hours = secondsAccumulator / 3600
		minutes = (secondsAccumulator % 3600) / 60
		seconds = (secondsAccumulator % 3600) % 60
		
		let data = ["Hours": (hours), "Minutes": (minutes), "Seconds": (seconds), "Distractions": count, "timestamp": Timestamp(date: Date())] as [String : Any]
	
		guard let currentUserID = Auth.auth().currentUser?.uid else {
			print("Error Collecting: UID")
			return
		}
        
		let total = ["totalMeditation": totalMeditation, "totalDistractions": totalDistractions, "timestamp": Timestamp(date: Date())] as [String : Any]
		
		//Each Meditation Session
        db.collection("Users").document(currentUserID).collection("meditation").document(CurrentDate()).setData(data, merge: true)

		//Total of entire day
        db.collection("Users").document(currentUserID).collection("meditation").document(CurrentDate()).setData(total, merge: true)
        
        // Adds meditation time to levelProgress
        let meditationPoints: Double = Double((hours) * 10) + Double(minutes) + (Double(seconds) / 10)
        db.collection("Users").document(currentUserID).updateData(["levelProgress" : FieldValue.increment(meditationPoints)])
	}
    
    //https://developer.apple.com/library/archive/qa/qa1913/_index.html
    func playMusic() {
		//Sound from Zapsplat.com
		if let asset = NSDataAsset(name:"scott_lawlor_windchimes.mp3"){
			do {
             // Use NSDataAsset's data property to access the audio file stored in Sound.
              playerMusic = try AVAudioPlayer(data:asset.data, fileTypeHint:"caf")
             // Play the above sound file.
                playerMusic?.play()
			} catch let error as NSError {
             print(error.localizedDescription)
			}
		}
	}

	//https://developer.apple.com/library/archive/qa/qa1913/_index.html
	func playAlarm() {
		//Sound from Zapsplat.com
		if let asset = NSDataAsset(name:"tspt_church_bells_018.mp3"){
			do {
             // Use NSDataAsset's data property to access the audio file stored in Sound.
              playerAlarm = try AVAudioPlayer(data:asset.data, fileTypeHint:"caf")
             // Play the above sound file.
             playerAlarm?.play()
			} catch let error as NSError {
             print(error.localizedDescription)
			}
		}
	}
	
	func stopSound(){
        playerMusic?.stop()
		playerAlarm?.stop()
	}
}

//Session defines a meditation session for submission to Firestore Database.
struct Session{
    @EnvironmentObject var appState: AppState
	let db = Firestore.firestore()
	//Hours, minutes, seconds, and distractions will be sent to Firestore.
	@State var hrs: Int
	@State var mins: Int
	@State var secs: Int
	@State var distractions: Int
	@State var totalMeditationFirebase: Int
	@State var totalDistractionsFirebase: Int

	/*DELETE ONCE TESTED
	func writeSessionToFirebase(){
		guard let currentUserID = Auth.auth().currentUser?.uid else {
			print("Error Collecting: UID")
			return
		}
        
		let data = ["Hours": hrs, "Minutes": mins, "Seconds": secs, "Distractions": distractions, "timestamp": Timestamp(date: Date())] as [String : Any]
        
		let total = ["totalMeditation": totalMeditationFirebase, "totalDistractions": totalDistractionsFirebase, "timestamp": Timestamp(date: Date())] as [String : Any]
		
		//Each Meditation Session
        db.collection("Users").document(currentUserID).collection("meditation").document(CurrentDate()).setData(data, merge: true)

		//Total of entire day
        db.collection("Users").document(currentUserID).collection("meditation").document(CurrentDate()).setData(total, merge: true)
        
        // Adds meditation time to levelProgress
        let meditationPoints: Double = Double(hrs * 10) + Double(mins) + (Double(secs) / 10)
        db.collection("Users").document(currentUserID).updateData(["levelProgress" : FieldValue.increment(meditationPoints)])
	}
	
	func submit(){
		writeSessionToFirebase()
	}
	*/
	
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
}

struct Clock{
	var hrs: Int
	var mins: Int
	var secs: Int
	
	init(hours: Int, minutes: Int, seconds: Int){
		hrs = hours
		mins = minutes
		secs = seconds
	}
	
	func fireTimer() {
		print("Timer fired!")
	}

	func start(){
		var cntSecs = 0
		var cntMins = 0
		var cntHrs = 0

		Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
			print("Timer fired!")
			cntSecs += 1

			if cntSecs == secs {
				timer.invalidate()
			}
		}
		
		Timer.scheduledTimer(withTimeInterval: 60.0, repeats: false) { timer in
			print("Timer fired!")
			cntMins += 1

			//Minutes is 60 sec * Input
			if cntMins == (mins * 60) {
				timer.invalidate()
			}
		}
		
		Timer.scheduledTimer(withTimeInterval: 3600.0, repeats: false) { timer in
			print("Timer fired!")
			cntHrs += 1
			
			//Hours is 60 min * 60 sec * Input
			if cntHrs == (hrs * 60 * 60) {
				timer.invalidate()
			}
		}
	}
}

/*
struct MeditateView_Previews: PreviewProvider {
   static var previews: some View {
		MeditateView()
    }
}
*/
