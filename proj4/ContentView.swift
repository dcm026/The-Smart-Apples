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

    var latitude: String  { return("\(lm.location?.latitude ?? 0)") }
    var longitude: String { return("\(lm.location?.longitude ?? 0)") }
    var placemark: String { return("\(lm.placemark?.description ?? "XXX")") }
    var status: String    { return("\(String(describing: lm.status))") }//
    var body: some View {
        VStack {
            Spacer()
            TextField("type something...", text: $text)
            
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

                    mailgun?.sendMessage(to: con.email ?? "", from: "Excited User <someone@sample.org>", subject: "SOS", body: "Latitude: \(self.latitude) \n Longitude: \(self.longitude) \n Placemark: \(self.placemark)")
                }
            }) {
                Text("Send SOS")
            }

            Spacer()


            Text("Latitude: \(self.latitude)")
            Text("Longitude: \(self.longitude)")
            Text("Placemark: \(self.placemark)")
//            Text("Status: \(self.status)")
            Spacer()
        }
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

// Setup keychain class
class KeyChain {

    class func save(key: String, data: Data) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key,
            kSecValueData as String   : data ] as [String : Any]

        SecItemDelete(query as CFDictionary)

        return SecItemAdd(query as CFDictionary, nil)
    }

    class func load(key: String) -> Data? {
        let query = [
            kSecClass as String       : kSecClassGenericPassword,
            kSecAttrAccount as String : key,
            kSecReturnData as String  : kCFBooleanTrue!,
            kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

        var dataTypeRef: AnyObject? = nil

        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == noErr {
            return dataTypeRef as! Data?
        } else {
            return nil
        }
    }

    class func createUniqueID() -> String {
        let uuid: CFUUID = CFUUIDCreate(nil)
        let cfStr: CFString = CFUUIDCreateString(nil, uuid)

        let swiftString: String = cfStr as String
        return swiftString
    }
}

extension Data {

    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }

    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.load(as: T.self) }
    }
}

