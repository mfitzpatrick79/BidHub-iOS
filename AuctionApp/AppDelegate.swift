
//
//  AppDelegate.swift
//  AuctionApp
//

import UIKit
import UserNotifications
import OneSignal
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSPermissionObserver, OSSubscriptionObserver {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let configuration = ParseClientConfiguration {
            $0.applicationId = "NSTu2o0vGr9UJ0JYM5iPXSYGoDoQQ3ulrERXUEG0"
            $0.clientKey = "D3H1F21LuG2lOzf8xf9jRmlOE8aPjrA7pJXffx0L"
            $0.server = "https://parse.fitz.guru/parse"
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
        // For debugging
        // OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
        
        let notificationReceivedBlock: OSHandleNotificationReceivedBlock = { notification in
            
            print("Received Notification: \(String(describing: notification!.payload.notificationID))")
            print("launchURL = \(notification?.payload.launchURL ?? "None")")
            print("content_available = \(notification?.payload.contentAvailable ?? false)")
        }
        
        let notificationOpenedBlock: OSHandleNotificationActionBlock = { result in
            // This block gets called when the user reacts to a notification received
            let payload: OSNotificationPayload? = result?.notification.payload
            
            print("Message = \(String(describing: payload!.body))")
            print("badge number = \(payload?.badge ?? 0)")
            print("notification sound = \(payload?.sound ?? "None")")
            
            if let additionalData = result!.notification.payload!.additionalData {
                print("additionalData = \(additionalData)")

                if let actionSelected = payload?.actionButtons {
                    print("actionSelected = \(actionSelected)")
                }
                
                // DEEP LINK from action buttons
                if let actionID = result?.action.actionID {
                    // For presenting a ViewController from push notification action button
//                    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                    let instantiateItemListViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "RedViewControllerID") as UIViewController
//                    let instantiatedGreenViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "GreenViewControllerID") as UIViewController
//                    self.window = UIWindow(frame: UIScreen.main.bounds)
                    
                    print("actionID = \(actionID)")
                    
//                    if actionID == "id2" {
//                        print("do something when button 2 is pressed")
//                        self.window?.rootViewController = instantiateRedViewController
//                        self.window?.makeKeyAndVisible()
//
//
//                    } else if actionID == "id1" {
//                        print("do something when button 1 is pressed")
//                        self.window?.rootViewController = instantiatedGreenViewController
//                        self.window?.makeKeyAndVisible()
//
//                    }
                }
            }
        }
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true, ]
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: "f047cf97-a1e9-4f4e-8629-2b4958977a4b", handleNotificationReceived: notificationReceivedBlock, handleNotificationAction: notificationOpenedBlock, settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification
        
        // Add your AppDelegate as an obsserver
        OneSignal.add(self as OSPermissionObserver)
        OneSignal.add(self as OSSubscriptionObserver)
        
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

    func onOSPermissionChanged(_ stateChanges: OSPermissionStateChanges!) {
        // Example of detecting answering the permission prompt
        if stateChanges.from.status == OSNotificationPermission.notDetermined {
            if stateChanges.to.status == OSNotificationPermission.authorized {
                print("Thanks for accepting notifications!")
            } else if stateChanges.to.status == OSNotificationPermission.denied {
                print("Notifications not accepted. You can turn them on later under your iOS settings.")
            }
        }
        // prints out all properties
        print("PermissionStateChanges: \n\(String(describing: stateChanges))")
    }
    
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(String(describing: stateChanges))")
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



