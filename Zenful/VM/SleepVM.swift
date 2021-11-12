//
//  SleepVM.swift
//  Zenful
//
//  Created by Justin Cella on 5/10/21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class SleepVM: ObservableObject {
    @Published var sleeps = [Sleep]()
    private var db = Firestore.firestore()

    func fetchData() {        
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error Collecting: UID")
            return
        }

        db.collection("Users").document(currentUserID).collection("sleep").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("No documents")
                return
            }
            
            self.sleeps = documents.map { (queryDocumentSnapshot ) -> Sleep in
                let data = queryDocumentSnapshot.data()
                
                
                let hours = data["hours"] as? Double ?? 0
                let minutes = data["minutes"] as? Double ?? 0
                let goalSleep = data["goalSleep"] as? Double ?? 0
                let timestamp = data["timestamp"] as? Timestamp ?? Timestamp.init(seconds: 0, nanoseconds: 0)
                let totalSleep = data["totalSleep"] as? Double ?? 0
                
                let sleep = Sleep(hours: hours, minutes: minutes, goalSleep: goalSleep, timestamp: timestamp, totalSleep: totalSleep)
                    
                return sleep
                
            }
            
        }
    }
    
    func writeData(hrs: Double, mins: Double, totalSleep: Double ) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error Collecting: UID")
            return
        }
        
        let collection = db.collection("Users").document(currentUserID).collection("sleep")
        
        let data = ["Hours": hrs, "Minutes": mins, "timestamp": Timestamp(date: Date())] as [String : Any]
        let total = ["totalSleep": totalSleep, "timestamp": Timestamp(date: Date())] as [String : Any]
        
        collection.document(CurrentDate()).setData(data, merge: true)
        collection.document(CurrentDate()).setData(total, merge: true)
        
        // Adds sleep time to levelProgress
        let sleepPoints: Double = Double(hrs * 1.5) + Double(mins)
        db.collection("Users").document(currentUserID).updateData(["levelProgress" : FieldValue.increment(sleepPoints)])
    }
}
