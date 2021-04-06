//
//  SceneDelegate.swift
//  proj4
//
//  Created by Sam Spohn on 8/9/20.
//  Copyright © 2020 Sam Spohn. All rights reserved.
//

import UIKit
import SwiftUI
import BackgroundTasks
import mailgun
import CoreData

//extension CLLocation {
//    var latitude: Double {
//        return self.coordinate.latitude
//    }
//
//    var longitude: Double {
//        return self.coordinate.longitude
//    }
//}

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(fetchRequest: Contact_.allContactsFetchRequest()) var contactList: FetchedResults<Contact_>

    var placemark = ""
    @ObservedObject var lm = LocationManager()
    var userProvidedInput = true
    
    func userNotificationCenter(
            _ center: UNUserNotificationCenter,
            willPresent notification: UNNotification,
            withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
            -> Void) {
        print("set user input provided: true")
        self.userProvidedInput = true
        completionHandler([.alert, .badge, .sound])
        }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Use a UIHostingController as window root view controller.
        print("launching app")
        UNUserNotificationCenter.current().delegate = self
        registerBackgroundTask()
        registerLocalNotification()
        
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            // ❇️ Get the managedObjectContext from the persistent container
            let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            // ❇️ Pass it to the ContentView through the managedObjectContext @Environment variable
            let contentView = MainView()
                                .environment(\.managedObjectContext, managedObjectContext)

            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        // Save changes in the application's managed object context when the application transitions to the background.
        print("entered background")
        scheduleLocalNotification()
        cancelAllPandingBGTask()
        scheduleAppRefresh()
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
   
    //MARK: Regiater BackGround Tasks
    private func registerBackgroundTask() {
        
//        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.SO.imagefetcher", using: nil) { task in
//            //This task is cast with processing request (BGProcessingTask)
//            self.scheduleLocalNotification()
//            self.handleImageFetcherTask(task: task as! BGProcessingTask)
//        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "checkUser", using: nil) { task in
            //This task is cast with processing request (BGAppRefreshTask)
            self.scheduleLocalNotification()
            self.handleAppRefreshTask(task: task as! BGAppRefreshTask)
        }
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "checkUserInput", using: nil) { task in
            //This task is cast with processing request (BGAppRefreshTask)
            self.checkUserInput(task: task as! BGAppRefreshTask)
        }
    }

}


//MARK:- BGTask Helper
extension SceneDelegate {
    
    func cancelAllPandingBGTask() {
        BGTaskScheduler.shared.cancelAllTaskRequests()
    }
    
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "checkUser")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 2 * 60) // App Refresh after 2 minute.
        //Note :: EarliestBeginDate should not be set to too far into the future.
        do {
            try BGTaskScheduler.shared.submit(request)
            print("scheduling refresh")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func handleAppRefreshTask(task: BGAppRefreshTask) {
        //Todo Work
        print("refreshing")
        /*
         //AppRefresh Process
         */
        self.userProvidedInput = false
        task.expirationHandler = {
            //This Block call by System
            //Cancel your all task's & queues
        }
        scheduleLocalNotification()
        //
        task.setTaskCompleted(success: true)
    }
    
    
    func checkUserInput(task: BGAppRefreshTask) {
        //Todo Work
        print("checking input")
        /*
         //AppRefresh Process
         */
        if(!self.userProvidedInput){
            for con in self.contactList {
                let mailgun = Mailgun.client(withDomain: "www.mikeoneal.com", apiKey: "key-8e717175b238cd0964ba5cc74026c69f")

                mailgun?.sendMessage(to: con.email ?? "", from: "Excited User <someone@sample.org>", subject: "SOS", body: "Latitude: \(lm.location?.latitude ?? 0) \n Longitude: \(lm.location?.longitude ?? 0) \n Placemark: \(String(describing: lm.placemark))")
            }
        }
        scheduleAppRefresh()
        
        task.expirationHandler = {
            //This Block call by System
            //Cancel your all task's & queues
        }
//        scheduleLocalNotification()
        //
        task.setTaskCompleted(success: true)
    }
    
}

//MARK:- Notification Helper

extension SceneDelegate {
    
    func registerLocalNotification() {
        let notificationCenter = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
    }
    
    func scheduleLocalNotification() {
        print("scheduling notification")
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.fireNotification()
            }
        }
    }
    
    func fireNotification() {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Application Update"
        notificationContent.body = "Alcor Health Monitoring App is running in the background"
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
}
