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
        //if (delegate != nil) {
            var time: Int = 30
            delegate?.userDidSelectTime(time)
            print("\(time)")
            self.navigationController?.popViewControllerAnimated(true)
        //}
    }
    @IBAction func button60s(sender: AnyObject) {
    }
    
    @IBAction func button90s(sender: AnyObject) {
    }
}
