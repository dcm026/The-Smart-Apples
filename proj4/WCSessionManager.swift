//
//  WCSessionManager.swift
//  proj4
//
//  Created by Katie Till on 4/6/21.
//  Copyright © 2021 Sam Spohn. All rights reserved.
//

import Foundation
import WatchConnectivity

class WCSessionManager : NSObject{
    static let shared = WCSessionManager();
    private var session : WCSession = .default;
    var isReachable : Bool{
        return self.session.isReachable;
    }
    
    override init() {
        super.init();
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        #if os(iOS)
            print("WatchManager Created. Paired[\(self.session.isPaired)] AppInstalled[\(self.session.isWatchAppInstalled)]");
        #else
            print("[\(#function)]]");
        #endif
    }
    
    func activate(){
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        #if os(iOS)
            print("[\(#function)]] Paired[\(self.session.isPaired)] AppInstalled[\(self.session.isWatchAppInstalled)]");
        #else
            print("[\(#function)]]");
        #endif
    }
    
    func send(){
        self.session.sendMessage(["title" : "gogo"], replyHandler: { (replyData) in
            print("Sending data has been completed. data[\(replyData)]");
        }) { (error) in
            print("Sending data has been failed. error[\(error)]");
        }
    }
}

extension WCSessionManager : WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("[\(#function)] Watch did activated. state[\(activationState.rawValue)] error[\(error)]")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("[\(#function)] Watch Receive. message[\(message)]")
    }
    
    func session(_ session: WCSession, didReceiveMessageData messageData: Data) {
        print("[\(#function)] Watch Receive. message[\(messageData)]")
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("[\(#function)] Watch Receive. message[\(userInfo)]")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("[\(#function)] Watch Receive. message[\(applicationContext)]")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("[\(#function)] Watch Receive. message[\(message)] handler[\(replyHandler)]")
        #if os(iOS)
        replyHandler(["reuslt" : "iOS"])
        #else
        replyHandler(["reuslt" : "Watch"])
        #endif
    }
    
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("[\(#function)]")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("[\(#function)]")
        self.session.activate()
    }
    #endif
}
