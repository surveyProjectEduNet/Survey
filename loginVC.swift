//
//  loginVC.swift
//  AppSurveyCouchDB
//
//  Created by mac on 5/21/16.
//  Copyright © 2016 baoTranIOS. All rights reserved.
//

import UIKit

class loginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onLoginTwitter(sender: UIButton) {
        TwitterClient.sharedInstance.login({ () -> () in
            
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
            //            print("I've logged in!")
            
        }) { (error: NSError) -> () in
            print("Error \(error.localizedDescription)")
        }
    }
}
