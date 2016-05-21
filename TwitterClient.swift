//
//  TwitterClient.swift
//  Survey
//
//  Created by mac on 5/9/16.
//  Copyright © 2016 mac. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
class TwitterClient: BDBOAuth1SessionManager {
    
    static let sharedInstance = TwitterClient(baseURL: NSURL(string:"https://api.twitter.com"), consumerKey: "EtaEkdKJpYPMBLQ5MknEJ38GC", consumerSecret:
        "LMx7plisz0gIMcSjxG2yziX7M5503ES4oIyCQWogXrS8EpFjDr")
    
    var loginSuccess : (() -> ())?
    var loginFailure : ((NSError) -> ())?
    
    func login(success: () -> (), failure: (NSError) -> ()) {
        self.loginSuccess = success
        self.loginFailure = failure
        
        TwitterClient.sharedInstance.deauthorize()
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "survey://oauth"), scope: nil, success: { (requrestToken:BDBOAuth1Credential!) in
            print("I got a token")
            let url = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requrestToken.token)")
            UIApplication.sharedApplication().openURL(url!)
        }) { (error: NSError!) in
                print("Error: \(error.localizedDescription)")
        }
    }
    func handleOpenUrl (url: NSURL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential!) -> Void in
            
            self.currentAccount({ (user: User) -> () in
                User.currentUser = user
                self.loginSuccess?()
                }, failure:{ (error: NSError) -> () in
                    (self.loginFailure?(error))!
            })
            
        }) {(error: NSError!) -> Void in
            print("error: \(error.localizedDescription)")
            self.loginFailure?(error)
        }
    }
    func currentAccount(success: (User) -> (), failure: (NSError) -> ()){
        GET("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: {(task: NSURLSessionDataTask, response: AnyObject?)-> Void in
            
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            
            success(user)
            
            }, failure: {(task: NSURLSessionDataTask?, error: NSError) -> Void in
                failure(error)
        })
        
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        
        //NSNotificationCenter.defaultCenter().postNotificationName(User.userDidLogoutNotification, object: nil)
        
    }
}
