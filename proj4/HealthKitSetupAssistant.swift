//
//  HealthKitSetupAssistant.swift
//  proj4
//
//  Created by Katie Till on 4/21/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant: ObservableObject {
  
  private enum HealthkitSetupError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
  }
  
  class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
    //1. Check to see if HealthKit Is Available on this device
    guard HKHealthStore.isHealthDataAvailable() else {
      completion(false, HealthkitSetupError.notAvailableOnDevice)
      return
    }
    //2. Prepare the data types that will interact with HealthKit
    guard   let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType),
            let oxygensat = HKObjectType.quantityType(forIdentifier: .oxygenSaturation),
            let heartrate = HKObjectType.quantityType(forIdentifier: .heartRate) else {
            
            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
    }
    //3. Prepare a list of types you want HealthKit to read and write
    let healthKitTypesToWrite: Set<HKSampleType> = [heartrate,
                                                    oxygensat,
                                                    HKObjectType.workoutType()]
        
    let healthKitTypesToRead: Set<HKObjectType> = [dateOfBirth,
                                                   bloodType,
                                                   HKObjectType.workoutType()]
    //4. Request Authorization
    HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                         read: healthKitTypesToRead) { (success, error) in
      completion(success, error)
    }
    }
}
