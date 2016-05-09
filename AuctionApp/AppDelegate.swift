
//
//  AppDelegate.swift
//  AuctionApp
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        Parse.setApplicationId("NSTu2o0vGr9UJ0JYM5iPXSYGoDoQQ3ulrERXUEG0", clientKey: "D3H1F21LuG2lOzf8xf9jRmlOE8aPjrA7pJXffx0L")
        PFAnalytics.trackAppOpenedWithLaunchOptionsInBackground(launchOptions, block: nil)
        

        let frame = UIScreen.mainScreen().bounds
        window = UIWindow(frame: frame)
        
        
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            let itemVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController() as? UINavigationController
            window?.rootViewController=itemVC
        } else {
            //Prompt User to Login
            let loginVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
            window?.rootViewController=loginVC
        }
        
        UITextField.appearance().tintColor = UIColor(red: 100/255, green: 128/255, blue: 67/255, alpha: 1.0)

    
        window?.makeKeyAndVisible()
        
        UINavigationBar.appearance().barTintColor = UIColor(red: 100/255, green: 128/255, blue: 67/255, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        UISearchBar.appearance().barTintColor = UIColor(red: 100/255, green: 128/255, blue: 67/255, alpha: 1.0)
        
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstalation = PFInstallation.currentInstallation()
        
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0 ..< deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        print("tokenString: \(tokenString)", terminator: "")
        
        currentInstalation.setDeviceTokenFromData(deviceToken)
        currentInstalation.saveInBackgroundWithBlock(nil)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        NSNotificationCenter.defaultCenter().postNotificationName("pushRecieved", object: userInfo)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    }
    
}



