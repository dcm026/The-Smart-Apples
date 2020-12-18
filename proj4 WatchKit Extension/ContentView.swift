//
//  ContentView.swift
//  proj4 WatchKit Extension
//
//  Created by Sam Spohn on 8/9/20.
//  Copyright © 2020 Sam Spohn. All rights reserved.
//
import UserNotifications
import SwiftUI
import HealthKit
//import mailgun

struct ContentView: View {
    private var healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    @State private var showingAlert = false
    @State private var value = 0
    
    var body: some View {
        VStack{
            HStack{
                Text("❤️")
                    .font(.system(size: 50))
                Spacer()
//                Button(action: {
//                    let mailgun = Mailgun.client(withDomain: "https://api.mailgun.net/v3/sandbox432db17eded547af9697cfa4a6d5c417.mailgun.org", apiKey: "caab645c4fd848d79585f55c77996437-53c13666-df0d60ae")
//
//                        mailgun?.sendMessage(to: "samuel.c.spohn@gmail.com", from: "Excited User <someone@sample.org>", subject: "SOS", body: "howdy")
//                }) {
//                    Text("Send SOS")
//                }
            }
            
            HStack{
                Text("\(value)")
                    .fontWeight(.regular)
                    .font(.system(size: 40))
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("WARNING"), message:  Text("are you ded")
                        , dismissButton: .cancel(Text("false alarm")))
                    }
                
                Text("BPM")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(Color.red)
                    .padding(.bottom, 28.0)
                
                Spacer()
                
            }

        }
        .padding()
        .onAppear(perform: start)
    }

    
    func start() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("auth granted")
            } else {
                print("auth failed/denied")
            }
        }
        autorizeHealthKit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }
    
    func autorizeHealthKit() {
        let healthKitTypes: Set = [
        HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]

        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) { _, _ in }
    }
    
    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        
        // 1
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        // 2
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
            // 3
        guard let samples = samples as? [HKQuantitySample] else {
            return
        }
            
        self.process(samples, type: quantityTypeIdentifier)

        }
        
        // 4
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        
        // 5
        
        healthStore.execute(query)
    }
    
    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        var lastHeartRate = 0.0
        
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            
            self.value = Int(lastHeartRate)
//            self.showingAlert = self.value < 67
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
