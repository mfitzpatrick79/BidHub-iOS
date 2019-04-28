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

class LoginViewController: UIViewController, EulaViewControllerDelegate {

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var telephoneTextField: UITextField!
    @IBOutlet var eulaToggle: UISwitch!
    @IBOutlet var eulaTrigger: UIButton!
    @IBOutlet var loginButton: UIButton!

    var viewShaker:AFViewShaker?
    
    let buttonColorEnabled = UIColor(red: 215/255, green: 67/255, blue: 49/255, alpha: 0.95)
    let buttonColorDisabled = UIColor(red: 175/255, green: 175/255, blue: 175/255, alpha: 0.95)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableLoginButton()
        viewShaker = AFViewShaker(viewsArray: [nameTextField!, emailTextField!, telephoneTextField!])
    }

    @IBAction func textFieldShouldReturn(_ textField: UITextField) {
        textField.nextField?.becomeFirstResponder()
    }

    @IBAction func eulaAgreementTogglePressed() {
        view.endEditing(true)
        if (eulaToggle.isOn) {
            enableLoginButton()
        } else {
            disableLoginButton()
        }
    }

    @IBAction func eulaLinkTriggerPressed() {
        let EulaVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "EulaViewController") as? EulaViewController
        if let eulaVC = EulaVC {
            eulaVC.delegate = self
            addChild(eulaVC)
            view.endEditing(true)
            view.addSubview(eulaVC.view)
            eulaVC.didMove(toParent: self)
        }
    }

    @IBAction func loginPressed(_ sender: AnyObject) {
        view.endEditing(true)

        if nameTextField.text != "" && emailTextField.text != "" && telephoneTextField.text != "" && eulaToggle.isOn {
            
            let user = PFUser()
            user["fullname"] = nameTextField.text!.lowercased()
            user.username = emailTextField.text!.lowercased()
            user.password = "test"
            user.email = emailTextField.text!.lowercased()
            user["telephone"] = telephoneTextField.text!
            
            user.signUpInBackground {
                (succeeded, error) in
                if succeeded == true {
                    self.promptForPush(user: user)
                } else {
                    let errorString = error?.localizedDescription
                    print("Error Signing up: \(String(describing: errorString))", terminator: "")
                    PFUser.logInWithUsername(inBackground: user.username!, password: user.password!, block: { (user, error) -> Void in
                        if error == nil {
                            self.promptForPush(user: user!)
                        }else{
                            print("Error logging in ", terminator: "")
                            self.viewShaker?.shake()
                        }
                    })
                }
            }
            
        } else if !eulaToggle.isOn {
            let alertController = UIAlertController(title: "Please Accept Terms", message: "To register or login you must accept the terms of the MFA Auction App End User License Agreement.", preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        } else {
            //Can't login with nothing set
            viewShaker?.shake()
        }
    }

    /// OneSignal Push Registration
    func promptForPush(user: PFUser) {
        let alertController = UIAlertController(title: "Enable Push Notifications?", message: "Get the most out of your auction experience - we'll send you notifications when bidding is about to open, when you've been outbid, and when bidding is about to end.", preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "No thanks", style: UIAlertAction.Style.cancel, handler: { action in                     self.performSegue(withIdentifier: "loginToItemSegue", sender: nil) }))
        alertController.addAction(UIAlertAction(title: "Register", style: UIAlertAction.Style.default, handler: { action in self.doPushRegistration(user: user) }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func doPushRegistration(user: PFUser) {
        OneSignal.setEmail(user.email!)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        self.performSegue(withIdentifier: "loginToItemSegue", sender: nil)
    }
    
    /// Login/Register Button
    func enableLoginButton() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.loginButton.backgroundColor = UIColor(red: 215/255, green: 67/255, blue: 49/255, alpha: 0.95);
        }, completion: { (finished: Bool) -> Void in
            self.loginButton.isEnabled = true;
        })
    }
    
    func disableLoginButton() {
        UIView.animate(withDuration: 0.5, animations: { () -> Void in
            self.loginButton.backgroundColor = UIColor(red: 175/255, green: 175/255, blue: 175/255, alpha: 0.95);
        }, completion: { (finished: Bool) -> Void in
            self.loginButton.isEnabled = false;
        })
    }

    /// EULA VC
    func eulaViewControllerDidRespond(_ viewController: EulaViewController, agree: Bool){
        viewController.view.removeFromSuperview()
        // Mark toggle agreed
        if (agree) {
            eulaToggle.setOn(true, animated: true)
            enableLoginButton()
        } else {
            eulaToggle.setOn(false, animated: true)
            disableLoginButton()
        }
    }
}
