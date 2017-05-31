//
//  LoginViewController.swift
//  AuctionApp
//

import UIKit
import UserNotifications
import AFViewShaker
import OneSignal
import PhoneNumberKit
import Parse

private var kAssociationKeyNextField: UInt8 = 0

extension UITextField {
    @IBOutlet var nextField: UITextField? {
        get {
            return objc_getAssociatedObject(self, &kAssociationKeyNextField) as? UITextField
        }
        set(newField) {
            objc_setAssociatedObject(self, &kAssociationKeyNextField, newField, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

class LoginViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var telephoneTextField: UITextField!

    var viewShaker:AFViewShaker?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewShaker = AFViewShaker(viewsArray: [nameTextField, emailTextField, telephoneTextField])
    }

    @IBAction func textFieldShouldReturn(_ textField: UITextField) {
        textField.nextField?.becomeFirstResponder()
    }
    
    @IBAction func loginPressed(_ sender: AnyObject) {
        
        if nameTextField.text != "" && emailTextField.text != "" && telephoneTextField.text != "" {
            
            let user = PFUser()
            user["fullname"] = nameTextField.text!.lowercased()
            user.username = emailTextField.text!.lowercased()
            user.password = "test"
            user.email = emailTextField.text!.lowercased()
            user["telephone"] = telephoneTextField.text!
            
            user.signUpInBackground {
                (succeeded, error) in
                if succeeded == true {
                    OneSignal.syncHashedEmail(user.email)
                    OneSignal.promptForPushNotifications(userResponse: { accepted in
                        print("User accepted notifications: \(accepted)")
                    })
                    self.performSegue(withIdentifier: "loginToItemSegue", sender: nil)
                } else {
                    let errorString = error?.localizedDescription
                    print("Error Signing up: \(String(describing: errorString))", terminator: "")
                    PFUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: { (user, error) -> Void in
                        if error == nil {
                            OneSignal.syncHashedEmail(user?.email)
                            OneSignal.promptForPushNotifications(userResponse: { accepted in
                                print("User accepted notifications: \(accepted)")
                                
                                // Write user email to installation table for push targetting
                                let user = PFUser.current()
                                let currentInstalation = PFInstallation.current()
                                currentInstalation?["email"] = user!.email
                                currentInstalation?.saveInBackground(block: nil)
                            })
                            self.performSegue(withIdentifier: "loginToItemSegue", sender: nil)
                        }else{
                            print("Error logging in ", terminator: "")
                            self.viewShaker?.shake()
                        }
                    })
                }
            }
            
        }else{
            //Can't login with nothing set
            viewShaker?.shake()
        }
    }
}
