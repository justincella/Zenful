//
//  Meditate.swift
//  Zenful
//
//  Created by Justin Cella on 5/10/21.
//

import Foundation
import FirebaseFirestore

struct Meditate: Identifiable {
    var id: String = UUID().uuidString
    var distractions: Int
    var hours: Int
    var minutes: Int
    var Seconds: Int
    var goalDistractions: Int
    var goalMeditation: Int
    var timestamp: Timestamp
    var totalDistractions: Int
    var totalMeditation: Int
}
