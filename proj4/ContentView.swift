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



struct contactRow : View {
    var c: Contact_
    var body: some View{
        Text(c.email ?? "")
    }
}
/// Main View
struct ContentView: View {

    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Contact_.allContactsFetchRequest()) var contactList: FetchedResults<Contact_>

    @State private var text = ""

    @ObservedObject var lm = LocationManager()
    @ObservedObject var vc = ViewController()
    
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
        VStack() {
            Text("Enter Email Address for SOS Contact")
                
                
            Spacer()
            TextField("Enter Contact Here", text: $text)
            
            Button(action: {
                let contact = Contact_(context: self.managedObjectContext)
                contact.email = self.text
                
                do {
                    try self.managedObjectContext.save()
                } catch {
                    print(error)
                }
                self.text = ""
            }) {
                Text("save contact")
            }
//


            
            Spacer()
            Button(action: {
//                self.presentMailCompose()
                for con in self.contactList {
                    let mailgun = Mailgun.client(withDomain: "www.mikeoneal.com", apiKey: "key-8e717175b238cd0964ba5cc74026c69f")

                    mailgun?.sendMessage(to: con.email ?? "", from: "Excited User <someone@sample.org>", subject: "SOS", body: "\nHello!\nYou have been listed as an Emergency Contact for an Alcor member. They are in need of immediate attention. Their location is provided below.\nLocation Link: https://www.google.com/maps/search/\(self.latitude),\(self.longitude)")
                 //   mailgun?.sendMessage(to: con.email ?? "", from: "Excited User <someone@sample.org>", subject: "SOS", body: "Latitude: \(self.latitude) \n Longitude: \(self.longitude) \n Placemark: \(self.placemark)")
                }
            })
            {
                sosButton()
            }

            Spacer()


//            Text("Latitude: \(self.latitude)")
//            Text("Longitude: \(self.longitude)")
//            Text("Placemark: \(self.placemark)")
            Text("Current Location: \(self.subLocality), " + "\(self.thoroughfare), " + "\(self.locality), " + "\(self.country), " + "\(self.postalCode)")
//            Text("Status: \(self.status)")
            Spacer()
        }
        
        Text("X: \(self.vc.x) Y: \(self.vc.y) Z: \(self.vc.z)").onAppear { self.vc.startAccelerometer()} // start accelerometer after this loads up
        Text("Time elapsed since movement: \(self.vc.lastUpdateTime - self.vc.lastMovementTime)")
        
        NavigationView {
            List{
            Section(header: Text("Contacts")) {
                ForEach(self.contactList) { con in
                     NavigationLink(destination: EditView(contact: con)) {
                         VStack(alignment: .leading) {
                            Text(con.email ?? "")
                                 .font(.headline)
                         }
                     }
                 }
                 .onDelete { (indexSet) in // Delete gets triggered by swiping left on a row
                     // ❇️ Gets the BlogIdea instance out of the blogIdeas array
                     // ❇️ and deletes it using the @Environment's managedObjectContext
                     let toDelete = self.contactList[indexSet.first!]
                     self.managedObjectContext.delete(toDelete)
                     
                     do {
                         try self.managedObjectContext.save()
                     } catch {
                         print(error)
                     }
                 }
             }
             .font(.headline)
        }
         .listStyle(GroupedListStyle())
         .navigationBarTitle(Text("Contact List"))
         .navigationBarItems(trailing: EditButton())
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


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

struct sosButton: View {
    @State var buttonTapped = false
    @State var buttonPressed = false
    
    var body: some View {
        ZStack {
            VStack{Text("SOS")
                .font(.title)
                .fontWeight(.bold)
                
            Spacer()
            Image(systemName: "staroflife.fill")
                .font(.system(size: 40, weight: .bold))
                
            }
                
            .offset(x: buttonPressed ? -90 : 0, y: buttonPressed ? -90 : 0)
            .rotation3DEffect(Angle(degrees: buttonPressed ? 20 : 0), axis: (x: 10, y: -10, z :0))
            
        }
        .frame(width: 60, height: 60)
        .background(
            ZStack{
                Circle()
                    .fill(Color.white)
                    .frame(width: 100.0, height: 100.0)//Button Size
                    .shadow(color: Color("LightShadow"), radius: 8, x: -8, y: -8)
                    .shadow(color: Color("DarkShadow"), radius: 8, x: 8, y: 8)
            }
        )
    }
}
