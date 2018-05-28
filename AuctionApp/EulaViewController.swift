//
//  EulaViewController.swift
//  AuctionApp
//
//  Created by Michael Fitzpatrick on 5/27/18.
//  Copyright © 2018 fitz.guru. All rights reserved.
//

import Foundation
import UIKit

protocol EulaViewControllerDelegate {
    func eulaViewControllerDidRespond(_ viewController: EulaViewController, agree: Bool)
}

class EulaViewController: UIViewController {
    
    @IBOutlet var actionBar: UIToolbar!
    @IBOutlet var scrollView: UIScrollView! 
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var agreeButton: UIBarButtonItem!

    var delegate: EulaViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.contentSize = CGSize(width: self.view.frame.size.width, height: 700)
    }
    
    @IBAction func didPressCancel(_ sender: AnyObject) {
        animateOut()
    }
    
    @IBAction func didPressAgree(_ sender: AnyObject) {
        if self.delegate != nil {
            self.delegate!.eulaViewControllerDidRespond(self, agree: true)
        }
    }
    
    func animateOut(){
        if self.delegate != nil {
            self.delegate!.eulaViewControllerDidRespond(self, agree: false)
        }
    }
}
