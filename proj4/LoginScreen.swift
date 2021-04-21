//
//  LoginScreen.swift
//  proj4
//
//  Created by Joseph Ham on 4/6/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import SwiftUI
import UIKit

let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

let storedUsername = "Myusername"
let storedPassword = "Mypassword"

struct LoginScreen : View {
    @State var username: String = ""
    @State var password: String = ""
    
    @State var authenticationFail: Bool = false
    @State var authenticationSucceed: Bool = false
    
    @ObservedObject var keyboardResponder = KeyboardResponder()
    var body: some View {
        ZStack{
            //Background Color
            Rectangle()
                .fill(Color("Background"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        VStack {
            SignIn()
            UserImage()
            UsernameField(username: $username)
            PasswordField(password: $password)
            if authenticationFail {
                Text("Username or Password Incorrect. Please Retry.")
                    .multilineTextAlignment(.center)
                    .offset(y: -10)
                    .foregroundColor(.red)
                        }
            Button(action: {
                //If Username and Password are correct, Login is succesful
                if self.username == storedUsername && self.password == storedPassword {
                    self.authenticationSucceed = true
                    self.authenticationFail = false
                    hideKeyboard()
                }
                else {
                    self.authenticationFail = true
                }
            }) {
                LoginText()

            }
        }
        .padding()
        .offset(y: -keyboardResponder.currentHeight*0.04)
        if authenticationSucceed {
            MainView()
            }
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}

struct SignIn: View {
    var body: some View {
        Text("Sign In")
            .font(.largeTitle)
            .fontWeight(.semibold)
            .padding(.bottom, 20)
    }
}

struct UserImage: View {
    var body: some View {
        Image("UserImage")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 150, height: 150)
            .clipped()
            .cornerRadius(150)
            .padding(.bottom, 75)
    }
}

struct LoginText: View {
    var body: some View {
        Text("LOGIN")
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(width: 220, height: 60)
            .background(Color.green)
            .cornerRadius(15.0)
    }
}

struct UsernameField: View {
    @Binding var username: String
    var body: some View {
        TextField("Username", text: $username)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}

struct PasswordField: View {
    @Binding var password: String
    var body: some View {
        SecureField("Password", text: $password)
            .padding()
            .background(lightGreyColor)
            .cornerRadius(5.0)
            .padding(.bottom, 20)
    }
}
