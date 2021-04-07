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


class HostingController: WKHostingController<ContentViewWatch>{
    //message time counter
    public var lastMessage: CFAbsoluteTime = 0
    var sessionManager : WCSessionManager{
       return WCSessionManager.shared;
   }

    func sendToPhone(){
       guard self.sessionManager.isReachable else{
           return;
       }
       
       self.sessionManager.send();
   }

   @IBAction func onSend() {
       self.sendToPhone();
   }
   
    override var body: ContentViewWatch {
        return ContentViewWatch()
    }
}
