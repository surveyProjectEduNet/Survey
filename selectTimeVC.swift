//
//  selectTimeVC.swift
//  AppSurveyCouchDB
//
//  Created by mac on 5/28/16.
//  Copyright © 2016 baoTranIOS. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
protocol dataEnteredDelegate {
    func userDidSelectTime(time: Int)
}

class selectTimeVC: UIViewController {
    
    var delegate: dataEnteredDelegate? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        if User.currentUser != nil || flat == false {
            print("Click on logOut button")
            TwitterClient.sharedInstance.logout()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
//        else {
        if flat == true || NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            User.currentUser = nil
            NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UID)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
//        }
    }
    
    @IBAction func button30s(sender: AnyObject) {
        let time: Int = 1
        print("\(time)")
        self.performSegueWithIdentifier("Timer30", sender: NSNumber(integer: time))
    }
    @IBAction func button60s(sender: AnyObject) {
        let time: Int = 2
        print("\(time)")
        self.performSegueWithIdentifier("Timer30", sender: NSNumber(integer: time))
    }
    
    @IBAction func button90s(sender: AnyObject) {
        let time: Int = 3
        print("\(time)")
        self.performSegueWithIdentifier("Timer30", sender: NSNumber(integer: time))
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Timer30" {
            let viewcontroller : ViewController = segue.destinationViewController as! ViewController
            viewcontroller.timer = (sender as! NSNumber).integerValue
            
        }
    }
}
