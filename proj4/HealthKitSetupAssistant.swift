//
//  HealthKitSetupAssistant.swift
//  proj4
//
//  Created by Katie Till on 4/21/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import HealthKit

class HealthKitSetupAssistant {
  
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
    }  }
}
