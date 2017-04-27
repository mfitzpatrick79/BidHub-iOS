
//
//  AppDelegate.swift
//  AuctionApp
//

import UIKit
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
            $0.server = "https://parse.fitz.guru/parse"
            //$0.localDatastoreEnabled = true // If you need to enable local data store
        }
        //Parse.setApplicationId("NSTu2o0vGr9UJ0JYM5iPXSYGoDoQQ3ulrERXUEG0", clientKey: "D3H1F21LuG2lOzf8xf9jRmlOE8aPjrA7pJXffx0L")
        //PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        Parse.initialize(with: configuration)
        OneSignal.initWithLaunchOptions(launchOptions, appId: "f047cf97-a1e9-4f4e-8629-2b4958977a4b")

        let frame = UIScreen.main.bounds
        window = UIWindow(frame: frame)
        
        let currentUser = PFUser.current()
        if currentUser != nil {
            let itemVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController() as? UINavigationController
            window?.rootViewController=itemVC
        } else {
            //Prompt User to Login
            let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            window?.rootViewController=loginVC
        }
        
        UITextField.appearance().tintColor = UIColor(red: 100/255, green: 128/255, blue: 67/255, alpha: 1.0)

    
        window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 100/255, green: 128/255, blue: 67/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UISearchBar.appearance().barTintColor = UIColor(red: 100/255, green: 128/255, blue: 67/255, alpha: 1.0)
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let currentInstalation = PFInstallation.current()
        
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0 ..< deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("tokenString: \(tokenString)", terminator: "")
        
        currentInstalation?.setDeviceTokenFrom(deviceToken)
        currentInstalation?.saveInBackground(block: nil)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "pushRecieved"), object: userInfo)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
}



