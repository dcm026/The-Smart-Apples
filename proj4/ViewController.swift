import Foundation
import UIKit
import CoreMotion


class ViewController: UIViewController, ObservableObject {
    var motion = CMMotionManager();
    // store last x, y, and z measurement
    public var x: Double = 0.0
    public var y: Double = 0.0
    public var z: Double = 0.0
    public var lastMovementTime = -1 // unix time of last movement according to accelerometer data
    public var lastUpdateTime = -1
    private var movementThreshold: Double = 0.01
    private var updateFrequency = 0.01 // refresh frequency (in seconds)
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            }
        }
    }
}




