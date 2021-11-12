//
//  AppState.swift
//  Zenful
//
//  Created by Justin Cella on 5/6/21.
//

import Foundation

class AppState: ObservableObject {
    @Published var isDarkMode: Bool = true
    @Published var loggedIn: Bool = false
    @Published var user: User? = nil
}
