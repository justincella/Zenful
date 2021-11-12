//
//  SleepView.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SleepView: View {
	@State var hours = 0.0
	@State var minutes = 0.0
	@State var toggle1: Bool = true
	@State var toggle2: Bool = true
	@State var slider = 0.0
    @State private var currentDate = Date()
    @State var totalSleep = 0.0 //In minutes
    @EnvironmentObject var appState: AppState
    @ObservedObject var sleepVM = SleepVM()
    

    var body: some View {
        VStack{
			//1440 minutes in 24 hours
			Slider(value: $slider, in: 0...1440)
				.padding(.bottom, 100)
				.accentColor(.green)
			
			HStack{
				//1440 minutes divided by 60 gives hours.
				Text("Hours: \(floor(slider / 60), specifier: "%.0f")")
				Text("Minutes: \(slider.truncatingRemainder(dividingBy: 60), specifier: "%.0f")")
			}.padding(.bottom, 200)
			
			Button("Submit") {
				hours = floor(slider / 60)
				minutes = slider.truncatingRemainder(dividingBy: 60)
				totalSleep = totalSleep + hours + (minutes / 60)
                
                sleepVM.writeData(hrs: hours, mins: minutes, totalSleep: totalSleep)
//				let current = Sleep(hrs: hours, mins: minutes, totalSleepFirebase: totalSleep)
//				current.writeSleepToFirebase()
				slider = 0.0
				
			} .font(.title)
		}
		.padding()
		.navigationBarTitle("Sleep", displayMode: .inline)
	}
}

//Session defines a meditation session for submission to Firestore Database.

	
//func CurrentDate() -> String{
//		// get the current date and time
//		let currentDateTime = Date()
//
//		// initialize the date formatter and set the style
//		let formatter = DateFormatter()
//		formatter.timeStyle = .none
//		formatter.dateStyle = .long
//		//Get the date time String from the date object
//		let today = formatter.string(from: currentDateTime) //"October 8, 2016"
//		
//		return today
//	}
//}

//struct SleepView_Previews: PreviewProvider {
//    static var previews: some View {
//        SleepView()
//    }
//}
