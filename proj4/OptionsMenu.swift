//
//  OptionsMenu.swift
//  proj4
//
//  Created by Joseph Ham on 4/5/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import SwiftUI


struct OptionsMenu: View {
    @State public var inactivityThreshold = "3600" // time of lack of movement in seconds before automatic SoS alert is sent out
    @State public var automaticSoS = "1" // "1" will automatically send out SoS
    @State public var calibrationFactor = ".01" // accelerometer calibration factor (higher values will decrease sensitivity to movement), defualt is .01
    let defaults = UserDefaults.standard
    @ObservedObject var vc = ViewController.shared//ViewController()
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
                    defaults.set($inactivityThreshold, forKey: "inactivityThreshold")
                    hideKeyboard()
                }
            }
            HStack {
                Text("Accelerometer Calibration Factor (default is .01)")
                TextField("Input value here", text: $calibrationFactor)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                Button("Submit") {
                    print("$calibrationFactor set to: \($calibrationFactor)")
                    defaults.set($calibrationFactor, forKey: "calibrationFactor")
                    hideKeyboard()
                }
            }
            HStack {
                Text("Automatic SoS (1 automatically sends, 0 will not)")
                TextField("Input value here", text: $automaticSoS)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)

                Button("Submit") {
                    print("$inactivityThreshold set to: \($automaticSoS)")
                    defaults.set($automaticSoS, forKey: "automaticSoS")
                    hideKeyboard()
                }
            }
            Spacer()
            Text("Accelerometer Data")
            Text("X: \(self.vc.x) Y: \(self.vc.y) Z: \(self.vc.z)")
            Text("Time elapsed since movement: \(self.vc.lastUpdateTime - self.vc.lastMovementTime)")
//            Text("X: \(ViewController.shared.x) Y: \(ViewController.shared.y) Z: \(ViewController.shared.z)")
//            Text("Time elapsed since movement: \(ViewController.shared.lastUpdateTime - ViewController.shared.lastMovementTime)")
        }  
        
    }
}


struct OptionsMenu_Previews: PreviewProvider {
    static var previews: some View {
        OptionsMenu()
    }
}


