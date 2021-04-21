//
//  LoginScreen.swift
//  proj4
//
//  Created by Joseph Ham on 4/6/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import SwiftUI
import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth


let lightGreyColor = Color(red: 239.0/255.0, green: 243.0/255.0, blue: 244.0/255.0, opacity: 1.0)

let storedUsername = "Myusername"
let storedPassword = "Mypassword"

struct LoginScreen : View {
    @State var username: String = ""
    @State var password: String = ""
    
    @State var authenticationFail: Bool = false
    @State var authenticationSucceed: Bool = false
    
    @ObservedObject var keyboardResponder = KeyboardResponder()
    @State var currentNonce:String?
        
        //Hashing function using CryptoKit
        func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashedData = SHA256.hash(data: inputData)
            let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
            }.joined()

            return hashString
        }
    // from https://firebase.google.com/docs/auth/ios/apple
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
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
            })
            {
                LoginText()
            }
            
            SignInWithAppleButton(
                onRequest: { request in
                    let nonce = randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                     request.nonce = sha256(nonce)
                },
                onCompletion: { result in
                    switch result {
                                                  case .success(let authResults):
                                                      switch authResults.credential {
                                                          case let appleIDCredential as ASAuthorizationAppleIDCredential:
                                                          
                                                                  guard let nonce = currentNonce else {
                                                                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                                                  }
                                                                  guard let appleIDToken = appleIDCredential.identityToken else {
                                                                      fatalError("Invalid state: A login callback was received, but no login request was sent.")
                                                                  }
                                                                  guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                                                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                                                    return
                                                                  }
                                                                 
                                                                  let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
                                                                  Auth.auth().signIn(with: credential) { (authResult, error) in
                                                                      if (error != nil) {
                                                                          // Error. If error.code == .MissingOrInvalidNonce, make sure
                                                                          // you're sending the SHA256-hashed nonce as a hex string with
                                                                          // your request to Apple.
                                                                          print(error?.localizedDescription as Any)
                                                                          return
                                                                      }
                                                                      print("signed in")
                                                                    
                                                                  }
                                                          
                                                              print("\(String(describing: Auth.auth().currentUser?.uid))")
                                                      default:
                                                        self.authenticationSucceed = true
                                                        self.authenticationFail = false
                                                              }
                                                     default:
                                                          break
                                                  }
                }
            )
            .frame(width: 280, height: 45, alignment: .center)
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

