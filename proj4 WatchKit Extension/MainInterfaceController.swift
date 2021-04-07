//
//  MainInterfaceController.swift
//  proj4
//
//  Created by Katie Till on 4/6/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import Foundation


class MainInterfaceController: WKInterfaceController {

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
    
}
