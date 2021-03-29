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
import WatchConnectivity

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

class ExtensionDelegate: NSObject, WKExtensionDelegate {
//    private var healthStore = HKHealthStore()
//    let heartRateQuantity = HKUnit(from: "count/min")
    let health: HKHealthStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var heartRateQuery:HKSampleQuery?
    
    //KeyChain test vals
    let status = KeyChain.save(key: "MyNumber", data: Data(from: 555))
    let receivedData = KeyChain.load(key: "MyNumber")
    var keychaincheck = KeyChain.load(key: "MyNumber")
    
    
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
                
                //test print keychain vals
                //print("status test keychain: ", status)
                keychaincheck = Data(from:000);
                
                keychaincheck = KeyChain.load(key: "MyNumber")
                
                
                if (keychaincheck != receivedData){
                    keychaincheck = Data(from:000);
                }
                
                
                //message passing to Iphone for keychain test
                WCSession.default.sendMessageData(Data(), replyHandler: { (data) in
                            let samplemessage = self.keychaincheck
                            print("TEST MESSAGE PASSING : \(samplemessage)")
                        }, errorHandler: nil)
                
                
                
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
