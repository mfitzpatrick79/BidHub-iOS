
//
//  AppDelegate.swift
//  AuctionApp
//

import UIKit
import UserNotifications
import OneSignal
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let configuration = ParseClientConfiguration {
            $0.applicationId = "NSTu2o0vGr9UJ0JYM5iPXSYGoDoQQ3ulrERXUEG0"
            $0.clientKey = "D3H1F21LuG2lOzf8xf9jRmlOE8aPjrA7pJXffx0L"
            $0.server = "https://save-venice-app.herokuapp.com/parse"
            //$0.localDatastoreEnabled = true // If you need to enable local data store
        }
        Parse.initialize(with: configuration)

        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)
        
        let currentUser = PFUser.current()
        if currentUser != nil {
            let itemVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() as? UINavigationController
            window?.rootViewController=itemVC

            // Write user email to installation table for push targetting
            let currentInstalation = PFInstallation.current()
            currentInstalation?["email"] = currentUser!.email
            currentInstalation?.saveInBackground(block: nil)
        } else {
            //Prompt User to Login
            let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            window?.rootViewController=loginVC
        }
            
        window?.makeKeyAndVisible()

        // OneSignal Notifications
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            print("Received Notification: \(notification!.payload.notificationID)")
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload = result!.notification.payload
            
            var fullMessage = payload.body
            print("Message = \(String(describing: fullMessage))")
            
            if payload.additionalData != nil {
                if payload.title != nil {
                    let messageTitle = payload.title
                    print("Message Title = \(messageTitle!)")
                }
                
                let additionalData = payload.additionalData
                if additionalData?["actionSelected"] != nil {
                    fullMessage = fullMessage! + "\nPressed ButtonID: \(String(describing: additionalData!["actionSelected"]))"
                }
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false,
                                     kOSSettingsKeyInAppLaunchURL: true]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "f047cf97-a1e9-4f4e-8629-2b4958977a4b",
                                        handleNotificationReceived: notificationReceivedBlock, 
                                        handleNotificationAction: notificationOpenedBlock, 
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let currentInstalation = PFInstallation.current()
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0 ..< deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("tokenString: \(tokenString) \r\n", terminator: "")
        
        currentInstalation?.setDeviceTokenFrom(deviceToken)
        currentInstalation?.saveInBackground(block: nil)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "pushRecieved"), object: userInfo)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
}



