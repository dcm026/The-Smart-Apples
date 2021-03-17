//
//  HostingController.swift
//  proj4 WatchKit Extension
//
//  Created by Sam Spohn on 8/9/20.
//  Copyright © 2020 Sam Spohn. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI
import WatchConnectivity

class HostingController: WKHostingController<ContentView>{
    //message time counter
    public var lastMessage: CFAbsoluteTime = 0
    
    override var body: ContentView {
        return ContentView()
    }
}
