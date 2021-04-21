import Foundation
import UIKit
import CoreMotion
import WatchConnectivity
import os

class ViewController: UIViewController, ObservableObject, WCSessionDelegate {
    var motion = CMMotionManager();
    // store last x, y, and z measurement
    public var x: Double = 0.0
    public var y: Double = 0.0
    public var z: Double = 0.0
    public var lastMovementTime = -1 // unix time of last movement according to accelerometer data
    public var lastUpdateTime = -1
    public var lastMessage: CFAbsoluteTime = 0
    private var movementThreshold: Double = 0.01
    private var updateFrequency = 0.01 // refresh frequency (in seconds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //WatchConnectivity check and load
        //if (WCSession.isSupported()) {
            //let session = WCSession.default
            //session.delegate = self
            //session.activate()
        //}
        WCSessionManager.shared.activate();
        
    }
    
    //required WatchConnectivity funcs
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }
    
    // Send Message to Watch func
    
    func sendWatchMessage() {
        let currentTime = CFAbsoluteTimeGetCurrent()

        // if less than half a second has passed, bail out
        if lastMessage + 0.5 > currentTime {
            return
        }

        // send a message to the watch if it's reachable
        if (WCSession.default.isReachable) {
            // this is a meaningless message, but it's enough for our purposes
            let message = ["Message": "Hello"]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }

        // update our rate limiting property
        lastMessage = CFAbsoluteTimeGetCurrent()
    }
    
    func startAccelerometer() {
        motion.accelerometerUpdateInterval = self.updateFrequency
        // callback function that triggers upon a change
        motion.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            if let myData = data{
                let date = NSDate()
                
                let x = myData.acceleration.x
                let y = myData.acceleration.y
                let z = myData.acceleration.z
                
                // if acceleration is significant enough to be considered movement, update lastMovementTime to current unix
                if (abs(self.x - x) > self.movementThreshold || abs(self.y - y) > self.movementThreshold || abs(self.z - z) > self.movementThreshold) {
                    self.lastMovementTime = Int(date.timeIntervalSince1970)
                }
                
                // print("X: \(self.x) Y: \(self.y) Z: \(self.z) ")
                //print("Differences: \(abs(self.x - x)) \(abs(self.y - y)) \(abs(self.z - z))")
                
                self.x = x
                self.y = y
                self.z = z
                
                self.lastUpdateTime = Int(date.timeIntervalSince1970)
                let actext:StaticString = "update Accelerometer"
                os_log(actext)
            }
        }
        
    }
    
    @IBAction func onActivate(_ sender: Any) {
            
            WCSessionManager.shared.send();
        }
    
}




