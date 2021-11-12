//
//  ProfileModel.swift
//  Zenful
//
//  Created by Chris on 4/1/21.
//

import Foundation

class Profile{
    var displayName: String
    var email: String
    
    
    init?(displayName: String, email: String){
		self.displayName = displayName
		self.email = email
	}
}
