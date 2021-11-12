//
//  AchievementModel.swift
//  Zenful
//
//  Created by Justin Cella on 3/11/21.
//

import Foundation
import FirebaseFirestore

struct Achievement: Hashable {
    var title: String
    var points: Double
    var timestamp: Timestamp
    var image: String

}
