//
//  HKDataStore.swift
//  proj4
//
//  Created by Katie Till on 4/29/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import Foundation
import HealthKit

class HKDataStore {
    class func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
      
    //1. Use HKQuery to load the most recent samples.
    let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                          end: Date(),
                                                          options: .strictEndDate)
        
    let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                          ascending: false)
        
    let limit = 1
        
    let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                    predicate: mostRecentPredicate,
                                    limit: limit,
                                    sortDescriptors: [sortDescriptor]) { (query, samples, error) in
        
        //2. Always dispatch to the main thread when complete.
        DispatchQueue.main.async {
            
          guard let samples = samples,
                let mostRecentSample = samples.first as? HKQuantitySample else {
                    
                completion(nil, error)
                return
          }
            
          completion(mostRecentSample, nil)
        }
      }
     
    HKHealthStore().execute(sampleQuery)
    }
}
