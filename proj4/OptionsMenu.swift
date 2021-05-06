//
//  OptionsMenu.swift
//  proj4
//
//  Created by Joseph Ham on 4/5/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import SwiftUI

struct OptionsMenu: View{
    @State public var inactivityThreshold = "3600" // time of lack of movement in seconds before automatic SoS alert is sent out
    @State public var automaticSoS = "1" // "1" will automatically send out SoS
    @State public var calibrationFactor = ".01" // accelerometer calibration factor (higher values will decrease sensitivity to movement), defualt is .01
    @State public var appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    @ObservedObject var vc:ViewController = sceneDel.vc
    @Environment(\.managedObjectContext) var managedObjectContext
    var body: some View {
        NavigationView {
            Form {
                NavigationLink(destination: AccelerometerSettings()) {
                    Text("Accelerometer")
                        .font(.title2)}
                Section(header: Text("ABOUT")) {
                    NavigationLink(destination: Disclaimer()) {
                        Text("Disclaimer")
                            .font(.title3)}
                    HStack {
                        Text("Version")
                            .font(.title3)
                        Spacer()
                        Text("\(self.appVersion ?? "0.0.0")")
                            .font(.title3)
                    }
                }
            }
            .navigationBarTitle("Settings")
            
        }
        
    }
    
}


struct OptionsMenu_Previews: PreviewProvider {
    static var previews: some View {
        OptionsMenu()
    }
}
