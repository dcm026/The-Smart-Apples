//
//  ContentView.swift
//  proj4
//
//  Created by Sam Spohn on 8/9/20.
//  Copyright © 2020 Sam Spohn. All rights reserved.
//
import SwiftUI
import MessageUI
import mailgun
import CoreData
import os

struct contactRow : View {
    var c: Contact_
    var body: some View{
        Text(c.email ?? "")
    }
}
/// SOS View
struct ContentView: View {

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Contact_.allContactsFetchRequest()) var contactList: FetchedResults<Contact_>

    @State private var alertSent = false
    @State private var text = ""

    @ObservedObject var lm = LocationManager()
    @ObservedObject var vc = ViewController()
    @ObservedObject var hk =
        HealthKitSetupAssistant()
    
    var latitude: String  { return("\(lm.location?.latitude ?? 0)") }
    var longitude: String { return("\(lm.location?.longitude ?? 0)") }
    var placemark: String { return("\(lm.placemark?.description ?? "XXX")") }
    var subLocality: String { return("\(lm.placemark?.subLocality ?? "XXX")") }
    var thoroughfare: String { return("\(lm.placemark?.thoroughfare ?? "XXX")") }
    var locality: String { return("\(lm.placemark?.locality ?? "XXX")") }
    var country: String { return("\(lm.placemark?.country ?? "XXX")") }
    var postalCode: String { return("\(lm.placemark?.postalCode ?? "XXX")") }
    var status: String    { return("\(String(describing: lm.status))") }
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color("Background"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
        
        VStack() {
            Text("Enter Email Address for SOS Contact")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .frame(height: 100.0)
                .onAppear { self.vc.startAccelerometer()}
                //.onAppear {self.vc.authorizeHealthKit()}
                //.onAppear {self.vc.LoadRecentHeartrate()}
            Spacer()
            TextField("Press Here to Enter Contact", text: $text)
                .keyboardType(.numberPad)
            
            Button(action: {
                let contact = Contact_(context: self.managedObjectContext)
                contact.email = self.text + "@txt.att.net"
                
                if self.text.count == 10 {
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
                self.text = ""
                    hideKeyboard()}
                else{
                    hideKeyboard()
                }
            }) {
                Text("Save Contact")
                    .font(.title)
            }
//


            
            Spacer()
            if self.alertSent{
                Text("Alert Sent. Hold Button 2 Seconds to Clear Alert")
                Button( action: {
//                self.presentMailCompose()
                for con in self.contactList {
                    let mailgun = Mailgun.client(withDomain: "www.mikeoneal.com", apiKey: "key-8e717175b238cd0964ba5cc74026c69f")

                    mailgun?.sendMessage(to: con.email ?? "" + "@txt.att.net", from: "Alcor Health User <someone@sample.org>", subject: "SOS", body: "\nHello!\nThe Alcor member has cancelled the alert or someone else has arrived. Thank you.")
                    mailgun?.sendMessage(to: con.email ?? "" + "@tmomail.net", from: "Alcor Health User <someone@sample.org>", subject: "SOS", body: "\nHello!\nThe Alcor member has cancelled the alert or someone else has arrived. Thank you.")
                    let text:StaticString = "clear sent"
                    os_log(text)
                    self.alertSent = false
                }
            })
            {
                clearButton()
                }}
            else{
            Text("Hold Button 2 Seconds to Send Alert")
                Button( action: {
//                self.presentMailCompose()
                for con in self.contactList {
                    let mailgun = Mailgun.client(withDomain: "www.mikeoneal.com", apiKey: "key-8e717175b238cd0964ba5cc74026c69f")

                    mailgun?.sendMessage(to: con.email ?? "", from: "Alcor Health User <someone@sample.org>", subject: "SOS", body: "\nHello!\nYou have been listed as an Emergency Contact for an Alcor member. They are in need of immediate attention. Their location is provided below.\nLocation Link: https://www.google.com/maps/search/\(self.latitude),\(self.longitude)")
                 //   mailgun?.sendMessage(to: con.email ?? "", from: "Excited User <someone@sample.org>", subject: "SOS", body: "Latitude: \(self.latitude) \n Longitude: \(self.longitude) \n Placemark: \(self.placemark)")
                    let text:StaticString = "mail sent"
                    os_log(text)
                    self.alertSent = true
                }
            })
            {
                sosButton()
                }}

            Spacer()



//            Text("Latitude: \(self.latitude)")
//            Text("Longitude: \(self.longitude)")
//            Text("Placemark: \(self.placemark)")
           // Text("Current Location: \(self.subLocality), " + "\(self.thoroughfare), " + "\(self.locality), " + "\(self.country), " + "\(self.postalCode)")
//            Text("Status: \(self.status)")
          //  Spacer()
        }}
 
//        Text("X: \(self.vc.x) Y: \(self.vc.y) Z: \(self.vc.z)") // start accelerometer after this loads up
    /*    Text("Time elapsed since movement: \(self.vc.lastUpdateTime - self.vc.lastMovementTime)")
    */

    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

struct clearButton: View {
    @State var buttonTapped = false
    @State var buttonPressed = false
    
    var body: some View {
        ZStack {
            VStack{Text("Cancel Alert")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.red)
                .multilineTextAlignment(.center)
                
            Image(systemName: "xmark.octagon")
                .font(.system(size: 40, weight: .bold))
            }
                
            .offset(x: buttonPressed ? -90 : 0, y: buttonPressed ? -90 : 0)
            .rotation3DEffect(Angle(degrees: buttonPressed ? 20 : 0), axis: (x: 10, y: -10, z :0))
            
        }
        .frame(width: /*@START_MENU_TOKEN@*/250.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/250.0/*@END_MENU_TOKEN@*/)
        .background(
            ZStack{
                Circle()
                    .fill(Color.white)
                    .frame(width: 200.0, height: 200.0)//Button Size
                    .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                    .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
            }
        )
        .scaleEffect(buttonTapped ? 1.2 : 1)
        .onTapGesture(count:1) {
            self.buttonTapped.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.buttonTapped = false
            }
        }
    }
}

struct sosButton: View {
    @State var buttonTapped = false
    @State var buttonPressed = false
    
    var body: some View {
        ZStack {
            VStack{Text("Send Alert")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Color.red)
                .multilineTextAlignment(.center)
                
            Image(systemName: "staroflife.fill")
                .font(.system(size: 40, weight: .bold))
                
            }
                
            .offset(x: buttonPressed ? -90 : 0, y: buttonPressed ? -90 : 0)
            .rotation3DEffect(Angle(degrees: buttonPressed ? 20 : 0), axis: (x: 10, y: -10, z :0))
            
        }
        .frame(width: /*@START_MENU_TOKEN@*/250.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/250.0/*@END_MENU_TOKEN@*/)
        .background(
            ZStack{
                Circle()
                    .fill(Color.white)
                    .frame(width: 200.0, height: 200.0)//Button Size
                    .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                    .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
            }
        )
        .scaleEffect(buttonTapped ? 1.2 : 1)
        .onTapGesture(count:1) {
            self.buttonTapped.toggle()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.buttonTapped = false
            }
        }
    }
}

import Foundation
import CoreLocation
import Combine

extension CLLocation {
    var latitude: Double {
        return self.coordinate.latitude
    }
    
    var longitude: Double {
        return self.coordinate.longitude
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.status = status
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.location = location
        self.geocode()
    }
}

class LocationManager: NSObject, ObservableObject {
    private let geocoder = CLGeocoder()
  private let locationManager = CLLocationManager()
  let objectWillChange = PassthroughSubject<Void, Never>()

  @Published var status: CLAuthorizationStatus? {
    willSet { objectWillChange.send() }
  }

  @Published var location: CLLocation? {
    willSet { objectWillChange.send() }
  }

  override init() {
    super.init()

    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    self.locationManager.requestWhenInUseAuthorization()
    self.locationManager.startUpdatingLocation()
  }

    @Published var placemark: CLPlacemark? {
       willSet { objectWillChange.send() }
     }
  
    
    
  private func geocode() {
    guard let location = self.location else { return }
       geocoder.reverseGeocodeLocation(location, completionHandler: { (places, error) in
         if error == nil {
            self.placemark = places?[0]
         } else {
            self.placemark = nil
         }
       })

  }
}


