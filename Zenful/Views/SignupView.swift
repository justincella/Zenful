//
//  SignupView.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SignupView: View {
	let db = Firestore.firestore()
    @EnvironmentObject var appState: AppState
    @State var registerError: Bool = false
    @State var errorMessage: String = ""
    @State var name: String = ""
    @State var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSecured: Bool = true
	
    var body: some View {

        VStack{
            Text("Sign Up")
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
            
            Spacer()
            
            TextField("Full Name", text: $name)
                .padding()
                .background(Color.init(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .disableAutocorrection(true)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color.init(.systemGray6))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
            
            VStack{
                ZStack(alignment: .trailing){
                    if isSecured {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.init(.systemGray6))
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    } else {
                       TextField("Password", text: $password)
                            .padding()
                            .background(Color.init(.systemGray6))
                            .cornerRadius(5.0)
                            .padding(.bottom, 20)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    }
                    
                    
                    Button(action: {
                        isSecured.toggle()
                    }) {
                    
                        Image(systemName: self.isSecured ? "eye.slash" : "eye")
                            .accentColor(.gray)
                            .padding(.bottom, 20)
                            .padding()
                    }
                    
                    
                }
                if !self.passwordLength{
                    Text("Passwords must be more than 8 characters")
                        .font(.caption2)
                }
            
            }

            ZStack(alignment: .trailing){
                if isSecured {
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.init(.systemGray6))
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                } else {
                   TextField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.init(.systemGray6))
                        .cornerRadius(5.0)
                        .padding(.bottom, 20)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                }
                
                if !self.passwordMatch{
                    Text("Passwords do not match")
                        .font(.caption2)
                }
            }

            Button(action: { register() }) {
                if buttonDisable{
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.gray)
                        .cornerRadius(15.0)
                }else{
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.blue)
                        .cornerRadius(15.0)
                    }
            }
            .alert(isPresented: $registerError) {
                Alert(title: Text("Error!"), message: Text(errorMessage))
            }
            .disabled(buttonDisable)

            Spacer()
        }
        .padding()
    }
    
    var buttonDisable: Bool {
        return self.name.count < 3 || self.email.count < 3 || self.password.count < 8 || self.confirmPassword.count < 8 || !self.passwordMatch || self.registerError
    }
    
    var passwordMatch: Bool {
        return self.password == confirmPassword
    }
    
    var passwordLength: Bool {
        return self.password.count >= 8
    }
        
    func register() {
        Auth.auth().createUser(withEmail: self.email, password: self.password) { (result, error) in
            if let error = error {
                errorMessage = error.localizedDescription
                registerError.toggle()
            } else {
                
                let userInfo = Auth.auth().currentUser
                createFirebaseDoc(uid: userInfo!.uid)
                if let userInfo = userInfo{
                    let changeRequest = userInfo.createProfileChangeRequest()
                    changeRequest.displayName = self.name
                
                    changeRequest.commitChanges { (error) in
                        if let error = error {
                            errorMessage = error.localizedDescription
                        }
                    }
                }
               
            }
        }
    }
    
    func createFirebaseDoc(uid: String){
        db.collection("Users").document(uid).setData([
            "email": email,
            "photo": "default",
            "level": 1,
            "levelProgress": 10,
            "achievements": [
                ["title": "Account Created", "timestamp": Timestamp(date: Date()), "image": "default.png", "points": 10]
            ],
            "goalSleep": 1,
            "goalDistractions": 1,
            "goalMeditation": 1
        ], merge: true){ err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written and User Created!")
            }
        }
    }
}
//
//struct SignupView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignupView()
//    }
//}
