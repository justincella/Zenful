//
//  User.swift
//  Zenful
//
//  Created by Justin Cella on 5/6/21.
//

import Foundation
import FirebaseFirestore

struct User {

    var uid: String
    var email: String
    var photo: String
    var displayName: String
    var level: Int
    var levelProgress: Double
    var achievement: Array<Achievement>
    var goalSleep : Int
    var goalMeditation : Int
    var goalDistractions : Int
//    var streak: Int
//    var streakUpdate: Timestamp
}
