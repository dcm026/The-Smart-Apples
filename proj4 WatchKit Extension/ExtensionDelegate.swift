//
//  ExtensionDelegate.swift
//  proj4 WatchKit Extension
//
//  Created by Sam Spohn on 8/9/20.
//  Copyright © 2020 Sam Spohn. All rights reserved.
//
import UserNotifications
import WatchKit
import HealthKit

func scheduleNotification(value:Int) {
    let center = UNUserNotificationCenter.current()

    let content = UNMutableNotificationContent()
    content.title = "background update"
    content.body = "Heart rate:" + String(value)
    content.categoryIdentifier = "alert"
    content.userInfo = ["customData": "fizzbuzz"]
    content.sound = UNNotificationSound.default
//    var dateComponents = DateComponents()
//    dateComponents.hour = 10
//    dateComponents.minute = 30
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)

    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    center.add(request)
    
}

class ExtensionDelegate: NSObject, WKExtensionDelegate {
//    private var healthStore = HKHealthStore()
//    let heartRateQuantity = HKUnit(from: "count/min")
    let health: HKHealthStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var heartRateQuery:HKSampleQuery?

    private var value = 0
    func applicationDidFinishLaunching() {
//        let refreshDate = Date(timeIntervalSinceNow: 15.0)
//
//        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: refreshDate, userInfo: nil) { (error) in
//            if let error = error {
//                print("background task error \(error.localizedDescription)")
//            }
//        }
//        print("scheduling background update")
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        print("became active")
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        print("resigning")
        
//        scheduleNotification(value: self.value)
        let refreshDate = Date(timeIntervalSinceNow: 60.0)
        
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: refreshDate, userInfo: nil) { (error) in
            if let error = error {
                print("background task error \(error.localizedDescription)")
            }
        }
         print("scheduling background update")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    private func process(_ samples: [HKSample], type: HKQuantityTypeIdentifier) {
       var lastHeartRate = 0.0

       for sample in samples {
           if type == .heartRate {
                guard let currData:HKQuantitySample = sample as? HKQuantitySample else { return }
            lastHeartRate = currData.quantity.doubleValue(for: heartRateUnit)
//               lastHeartRate = sample.quantity.doubleValue(for: heartRateUnit)
           }
       }
        self.value = Int(lastHeartRate)
        print("processesing")
        print(self.value)
        scheduleNotification(value: self.value)
       }
    
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        // Sent when the system needs to launch the application in the background to process tasks. Tasks arrive in a set, so loop through and process each one.

       
        
        for task in backgroundTasks {
            // Use a switch statement to check the task type
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                print("here1")
//               // 1
//                let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
//               // 2
//                let updateHandler: (HKSampleQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
//                    query, samples, deletedObjects, queryAnchor, error in
//                // 3
//                guard let samples = samples as? [HKQuantitySample] else {
//                    return
//                }
//                self.process(samples, type: .heartRate)
//                }
//                // 4
//                let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: .heartRate)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
//
//                // 5
//                healthStore.execute(query)
////
//                //predicate
                let predicate = HKQuery.predicateForSamples(withStart: Date(timeIntervalSinceNow: -1200.0), end: Date(timeIntervalSinceNow: 0), options: [])

                //descriptor
                let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]

                heartRateQuery = HKSampleQuery(sampleType: heartRateType,
                                                predicate: predicate,
                                                limit: HKObjectQueryNoLimit,
                                                sortDescriptors: sortDescriptors)
                    { (query:HKSampleQuery, results:[HKSample]?, error:Error?) -> Void in
                        guard error == nil else { print(error!); return }
                        self.process(results!, type: .heartRate)

                }//eo-query
                health.execute(heartRateQuery!)
               print("updating in background")

                // Be sure to complete the background task once you’re done.
                backgroundTask.setTaskCompletedWithSnapshot(false)
                
                
                let refreshDate = Date(timeIntervalSinceNow: 60.0)
                
                WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: refreshDate, userInfo: nil) { (error) in
                    if let error = error {
                        print("background task error \(error.localizedDescription)")
                    }
                }
                 print("scheduling background update")
                
                
            case let snapshotTask as WKSnapshotRefreshBackgroundTask:
                // Snapshot tasks have a unique completion call, make sure to set your expiration date
                print("here2")
                
                snapshotTask.setTaskCompleted(restoredDefaultState: true, estimatedSnapshotExpiration: Date.distantFuture, userInfo: nil)
            case let connectivityTask as WKWatchConnectivityRefreshBackgroundTask:
                // Be sure to complete the connectivity task once you’re done.
                print("here3")
                connectivityTask.setTaskCompletedWithSnapshot(false)
            case let urlSessionTask as WKURLSessionRefreshBackgroundTask:
                print("here4")
                // Be sure to complete the URL session task once you’re done.
                urlSessionTask.setTaskCompletedWithSnapshot(false)
            case let relevantShortcutTask as WKRelevantShortcutRefreshBackgroundTask:
                print("here5")
                // Be sure to complete the relevant-shortcut task once you're done.
                relevantShortcutTask.setTaskCompletedWithSnapshot(false)
            case let intentDidRunTask as WKIntentDidRunRefreshBackgroundTask:
                print("here6")
                // Be sure to complete the intent-did-run task once you're done.
                intentDidRunTask.setTaskCompletedWithSnapshot(false)
            default:
                print("here7")
                // make sure to complete unhandled task types
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
