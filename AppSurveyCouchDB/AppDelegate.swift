//
//  AppDelegate.swift
//  AppSurveyCouchDB
//
//  Created by admin on 5/7/16.
//  Copyright © 2016 baoTranIOS. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import FBSDKCoreKit
import FBSDKLoginKit

private let kDatabaseName = "example02" //Đây là tên Database

private let kServerDbURL = NSURL(string: "http://116.118.119.102:5984/example02/") //Đây là đường dẫn đến file database

//Anh Cường có thể vào đường link sau để test database: http://116.118.119.102:5984/_utils/

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIAlertViewDelegate {

    var window: UIWindow?

    private var _push: CBLReplication! //Đây là biến để push dữ liệu từ máy lên database trên server
    
    private var _pull: CBLReplication! //Đây là biến để pull dữ liệu từ server xuống máy
    private var _syncError: NSError? //Đây là biến để kiểm lỗi trong vấn đề đồng bộ dữ liệu
    
    var database: CBLDatabase! //Đây là biến database, mình sẽ dùng nó để truy xuất đến data base
    
    override init() { //Hàm khởi tạo lấy database từ server về và gán vào cho biến database mỗi khi ứng dụng chạy lại, hàm này luôn luôn phải chạy.
        
        database = try? CBLManager.sharedInstance().databaseNamed(kDatabaseName)
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        guard database != nil else { //Kiểm tra nếu Database rỗng, có thể bị xoá thì thông báo Alert cho người dùng lỗi như sau
            
            fatalAlert("Unable to initialize Couchbase Lite") //Xuất lỗi, Hàm fatalAlert viết phía dưới
            return false
        }
        
        // Initialize replication:
        
        //Setup biến push dữ liệu lên server, hàm setupReplication viết bên dưới
        _push = setupReplication(database.createPushReplication(kServerDbURL!))
        //Setup biến pull dữ liệu về máy, hàm setupReplication viết bên dưới
        _pull = setupReplication(database.createPullReplication(kServerDbURL!))
        _push.start() //Bắt đầu push dữ liệu lên server
        _pull.start() //Bắt đầu pull dữ liệu xuống máy

        if User.currentUser != nil {
            print("There is a current user")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("MainScreenNavigationController")
            window?.rootViewController = vc
        }
        return FBSDKApplicationDelegate.sharedInstance()
            .application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    //Hàm để xuất Alert thông báo lỗi bình thường
    func showAlert(var message: String, forError error: NSError?) {
        if error != nil {
            message = "\(message)\n\n\((error?.localizedDescription)!)"
        }
        NSLog("ALERT: %@ (error=%@)", message, (error ?? ""))
        let alert = UIAlertView(
            title: "Error",
            message: message,
            delegate: nil,
            cancelButtonTitle: "Sorry")
        alert.show()
    }
    
    //Hàm để xuất Alert thông báo lỗi nghiêm trọng
    func fatalAlert(message: String) {
        NSLog("ALERT: %@", message)
        let alert = UIAlertView(
            title: "Fatal Error",
            message: message,
            delegate: self,
            cancelButtonTitle: "Quit")
        alert.show()
    }
    
    //Hàm để tắt Alert
    func alertView(alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        exit(0)
    }
    
    //Hàm cài đặt phương thức truyền tải dữ liệu, gọi hàm replicationProgress bên dưới
    func setupReplication(replication: CBLReplication!) -> CBLReplication! {
        if replication != nil {
            replication.continuous = true
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(AppDelegate.replicationProgress(_:)),
                                                             name: kCBLReplicationChangeNotification,
                                                             object: replication)
        }
        return replication
    }
    
    //Hàm này sẽ cho thấy được quá trình đồng bộ, sẽ xuất dưới console khi có pull, push dữ liệu và sẽ chạy lên tục khi có thay đổi trên cả server hay máy
    func replicationProgress(n: NSNotification) {
        if (_pull.status == CBLReplicationStatus.Active || _push.status == CBLReplicationStatus.Active) {
            // Sync is active -- aggregate the progress of both replications and compute a fraction:
            let completed = _pull.completedChangesCount + _push.completedChangesCount
            let total = _pull.changesCount + _push.changesCount
            NSLog("SYNC progress: %u / %u", completed, total)
            // Update the progress bar, avoiding divide-by-zero exceptions:
        } else {
            // Sync is idle -- hide the progress bar:
            NSLog("Finished Sync")
        }
        
        // Check for any change in error status and display new errors:
        let error = _pull.lastError ?? _push.lastError
        if (error != _syncError) {
            _syncError = error
            if error != nil {
                self.showAlert("Error syncing", forError: error)
            }
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        if flat == true {
            return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }else {
            TwitterClient.sharedInstance.handleOpenUrl(url)
            return true
        }
    }
}

