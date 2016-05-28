//
//  selectTimeVC.swift
//  AppSurveyCouchDB
//
//  Created by mac on 5/28/16.
//  Copyright © 2016 baoTranIOS. All rights reserved.
//

import UIKit

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
        if User.currentUser != nil {
            print("Click on logOut button")
            TwitterClient.sharedInstance.logout()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func button30s(sender: AnyObject) {
        let time: Int = 30
        print("\(time)")
        self.performSegueWithIdentifier("Timer30", sender: NSNumber(integer: time))
    }
    @IBAction func button60s(sender: AnyObject) {
        let time: Int = 60
        print("\(time)")
        self.performSegueWithIdentifier("Timer30", sender: NSNumber(integer: time))
    }
    
    @IBAction func button90s(sender: AnyObject) {
        let time: Int = 90
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
