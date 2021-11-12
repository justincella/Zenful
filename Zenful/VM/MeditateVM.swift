//
//  MeditateVM.swift
//  Zenful
//
//  Created by Justin Cella on 5/10/21.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import SwiftUI

class MeditateVM: ObservableObject {
    @Published var meditations = [Meditate]()
    private var db = Firestore.firestore()
    
    func fetchData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error Collecting: UID")
            return
        }

        db.collection("Users").document(currentUserID).collection("meditation").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else{
                print("No documents")
                
                return
            }
            
            
            self.meditations = documents.map { (queryDocumentSnapshot ) -> Meditate in
                let data = queryDocumentSnapshot.data()
                
                let distractions = data["distractions"] as? Int ?? 0
                let hours = data["hours"] as? Int ?? 0
                let minutes = data["minutes"] as? Int ?? 0
                let seconds = data["seconds"] as? Int ?? 0
                let goalDistractions = data["goalDistractions"] as? Int ?? 0
                let goalMeditation = data["goalMeditation"] as? Int ?? 0
                let timestamp = data["timestamp"] as? Timestamp ?? Timestamp.init(seconds: 0, nanoseconds: 0)
                let totalDistractions = data["totalDistractions"]  as? Int ?? 0
                let totalMeditation = data["totalMeditation"] as? Int ?? 0
                
                let meditate = Meditate(distractions: distractions, hours: hours, minutes: minutes, Seconds: seconds, goalDistractions: goalDistractions, goalMeditation: goalMeditation, timestamp: timestamp, totalDistractions: totalDistractions, totalMeditation: totalMeditation)
                    
                return meditate
                
            }
            
        }
    }
    
    func writeData(hours: Int, minutes: Int, seconds: Int, distractions: Int, totalMediation: Int, totalDistractions: Int){
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Error Collecting: UID")
            return
        }
        
        let collection = db.collection("Users").document(currentUserID).collection("meditation")
            
        let data = ["Hours": hours, "Minutes": minutes, "Seconds": seconds, "Distractions": distractions, "timestamp": Timestamp(date: Date())] as [String : Any]
            
        let total = ["totalMeditation": totalMediation, "totalDistractions": totalDistractions, "timestamp": Timestamp(date: Date())] as [String : Any]
            
        //Each Meditation Session
        collection.document(CurrentDate()).setData(data, merge: true)

        //Total of entire day
        collection.document(CurrentDate()).setData(total, merge: true)
        
        
        //Add to level progression
        db.collection("Users").document(currentUserID).updateData(["levelProgress" : FieldValue.increment(Int64(10))])
            
    }
    
}
