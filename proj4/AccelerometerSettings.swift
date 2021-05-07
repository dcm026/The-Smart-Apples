//
//  AccelerometerSettings.swift
//  proj4
//
//  Created by Joseph Ham on 5/6/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import SwiftUI

struct AccelerometerSettings: View{
    @State public var inactivityThreshold = "3600" // time of lack of movement in seconds before automatic SoS alert is sent out
    @State public var automaticSoS = "0" // "1" will automatically send out SoS
    @State public var calibrationFactor = ".02" // accelerometer calibration factor (higher values will decrease sensitivity to movement), defualt is .02
    
    @ObservedObject private var alert = Alert.shared
    @ObservedObject var vc:ViewController = sceneDel.vc
    @Environment(\.managedObjectContext) var managedObjectContext
    var body: some View {
        VStack() {
            Text("Settings")
            HStack {
                Text("Inactivity Threshold (time remaining still before alert is automatically sent out)")
                TextField("Input value here", text: $inactivityThreshold)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                Button("Submit") {
                    print("$inactivityThreshold set to: \($inactivityThreshold)")
                    vc.inactivityThreshold = Int(inactivityThreshold)!
                    hideKeyboard()
                }
            }
            HStack {
                Text("Accelerometer Calibration Factor (default is 0.02)")
                TextField("Input value here", text: $calibrationFactor)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                Button("Submit") {
                    print("$calibrationFactor set to: \($calibrationFactor)")
                    vc.movementThreshold = Double(calibrationFactor)!
                    hideKeyboard()
                }
            }
            HStack {
                Text("Automatic SoS (1 automatically sends, 0 will not)")
                TextField("Input value here", text: $automaticSoS)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                Button("Submit") {
                    print("$automaticSoS set to: \($automaticSoS)")
                    vc.automaticSoS = automaticSoS
                    hideKeyboard()
                }
            }
            if alert.sent == true {
                Text("Alert Sent. Go to alert tab to cancel alert.")
            }
            
            Spacer()
            Text("Accelerometer Data")
            Text("X: \(self.vc.x) Y: \(self.vc.y) Z: \(self.vc.z)")
            Text("Time elapsed since movement: \(self.vc.lastUpdateTime - self.vc.lastMovementTime)")
//            Text("Time Threshold: \(self.vc.inactivityThreshold) Calibration: \(self.vc.movementThreshold) AutoSOS: \(self.vc.automaticSoS)")
        }
        
    }
    
}

struct AccelerometerSettings_Previews: PreviewProvider {
    static var previews: some View {
        AccelerometerSettings()
    }
}
