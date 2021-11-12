//
//  ZenfulApp.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//

import SwiftUI

@main
struct ZenfulApp: App {
	//This has to be here to connect the AppDelegate since AppDelegate isn't a SwiftUI standard.
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.appState)
                .background(Color("Background"))
        }
    }
}
