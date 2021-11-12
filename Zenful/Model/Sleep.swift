//
//  Sleep.swift
//  Zenful
//
//  Created by Justin Cella on 5/10/21.
//

import Foundation
import FirebaseFirestore

struct Sleep: Identifiable {
    var id: String = UUID().uuidString
    var hours: Double
    var minutes: Double
    var goalSleep: Double
    var timestamp: Timestamp
    var totalSleep: Double
}
