//
//  LoginView.swift
//  Zenful
//
//  Created by Chris on 3/9/21.
//

import SwiftUI
import FirebaseAuth

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)


struct LoginView: View {
    @EnvironmentObject var appState: AppState
    @State var loginErr: Bool = false
    @State var errorMessage: String = ""
    @State var email: String = ""
    @State private var password: String = ""
    @State private var isSecured: Bool = true
    
    var body: some View {
        NavigationView{
            VStack{
                Text("Login")
                    .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                
                Spacer()
                
                TextField("Email", text: $email)
                    .padding()
                    .background(Color.init(.systemGray6))
                    .cornerRadius(5)
                    .padding(.bottom, 10)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    
                
                ZStack(alignment: .trailing){
                    if isSecured {
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.init(.systemGray6))
                            .cornerRadius(5)
                            .padding(.bottom, 20)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                    } else {
                       TextField("Password", text: $password)
                            .padding()
                            .background(Color.init(.systemGray6))
                            .cornerRadius(5)
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
                
                Button(action: { login() }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 220, height: 60)
                        .background(Color.accentColor)
                        .cornerRadius(15.0)
                }
                .alert(isPresented: $loginErr) {
                    Alert(title: Text("Alert!"), message: Text(errorMessage))
                }
                
                Button(action: {forgotPassword()}, label: {
                    Text("Forgot your password?")
                        .font(.headline)
                        .foregroundColor(.blue)
                })
                .padding(.bottom)
                
                NavigationLink("Sign Up", destination: SignupView())
                    .font(.headline)
                    .foregroundColor(.blue)

                Spacer()
                
            }
            .padding()
        }
    }
    
    func forgotPassword(){
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                errorMessage = error.localizedDescription
                loginErr.toggle()
                
            } else {
                print("Email Sent")
                loginErr.toggle()
                errorMessage = "Please Check your email"
            }
        }
    }
    
    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                errorMessage = error.localizedDescription
                loginErr.toggle()
                
            } else {
                print("User signs in successfully")
                let userInfo = Auth.auth().currentUser
                
                email = ""
                password = ""
            }
        }
    }
}

//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginView()
//    }
//}
