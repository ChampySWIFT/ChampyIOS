//
//  CHSession.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import JWT
import SwiftyJSON

class CHSession: NSObject {
  
  let CurrentUser = NSUserDefaults.standardUserDefaults()
  let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
  
  var currentUserObject:JSON! = nil
  var currentUserId:String         = ""
  var currentUserFacebookId:String = ""
  var currentUserName:String       = ""
  var logined:Bool                 = false
  
  var selectedFriendId:String {
    if NSUserDefaults.standardUserDefaults().objectForKey("selectedFriendId") != nil {
      return NSUserDefaults.standardUserDefaults().stringForKey("selectedFriendId")!
    }
    return ""
  }
  
  
  override init() {
    let user = NSUserDefaults.standardUserDefaults()
    if user.objectForKey("facebookId") != nil && user.objectForKey("userName") != nil && user.objectForKey("userId") != nil && user.objectForKey("userObject") != nil {
      self.currentUserId         = self.CurrentUser.stringForKey("userId")!
      self.currentUserName       = self.CurrentUser.stringForKey("userName")!
      self.currentUserFacebookId = self.CurrentUser.stringForKey("facebookId")!
      self.currentUserObject     = CHUIElements().stringToJSON(self.CurrentUser.stringForKey("userObject")!)
      self.logined               = true
    }
  }
  
  func updateUserObject(userObject:JSON) {
    self.currentUserObject     = userObject
    self.CurrentUser.setObject("\(userObject)", forKey: "userObject")
  }
  
  func createSessionForTheUserWithFacebookId(facebookId:String, name:String, andObjectId objectId: String, userObject:JSON) {
    
    self.CurrentUser.setObject(facebookId, forKey: "facebookId")
    self.CurrentUser.setObject(name, forKey: "userName")
    self.CurrentUser.setObject(objectId, forKey: "userId")
    self.CurrentUser.setObject("\(userObject)", forKey: "userObject")
    
  }
  
  func setSelectedFriend(userId:String) {
    NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "selectedFriendId")
  }
  
  func clearSession() {
    self.CurrentUser.setObject(nil, forKey: "facebookId")
    self.CurrentUser.setObject(nil, forKey: "userName")
    self.CurrentUser.setObject(nil, forKey: "userId")
//    self.CurrentUser.setObject(nil, forKey: "userObject")
    self.logined = false
    appDelegate.subscribed = false
    
    if appDelegate.table1 != nil {
      appDelegate.table1.removeFromParentViewController()
      appDelegate.table2.removeFromParentViewController()
      appDelegate.table3.removeFromParentViewController()
    }
    
    appDelegate.table1 = nil
    appDelegate.table2 = nil
    appDelegate.table3 = nil
    appDelegate.historyTable1 = nil
    appDelegate.historyTable2 = nil
    appDelegate.historyTable3 = nil
    
    
    let array = appDelegate.mainViewCard as [String:UIView]
    for (kind, item) in array {
      item.removeFromSuperview()
    }
    
    NSURLCache.sharedURLCache().removeAllCachedResponses()
    
  }
  
  func getStringByKey(key:String) -> String {
    if CurrentUser.objectForKey(key) != nil {
      return CurrentUser.stringForKey(key)!
    }
    return ""
  }
  
  
  func getIntByKey(key:String) -> Int {
    if CurrentUser.objectForKey(key) != nil {
      return CurrentUser.integerForKey(key)
    }
    return 0
  }
  
  func getBoolByKey(key:String) -> Bool {
    if CurrentUser.objectForKey(key) != nil {
      return CurrentUser.boolForKey(key)
    }
    return false
  }
  
  func getJSONByKey(key:String) -> JSON {
    if CurrentUser.objectForKey(key) != nil {
      let string = CurrentUser.stringForKey(key)!
      return CHUIElements().stringToJSON(string)
    }
    
    return nil
  }
  
  func getToken() -> String {
    var token = ""
    let user = NSUserDefaults.standardUserDefaults()
    if user.objectForKey("facebookId") != nil {
      let ios = [
        "token": currentUserFacebookId,
        "timeZone": "2"
      ]
      token = JWT.encode(.HS256("secret")) { builder in
        builder["facebookId"] = self.currentUserFacebookId
        builder["IOS"]        = ios
      }
      
    }
    
    return token
  }
  
  func getTokenWithFaceBookId(facebookId:String) -> String {
    var token = ""
    let ios = [
      "token": facebookId,
      "timeZone": "2"
    ]
    token = JWT.encode(.HS256("secret")) { builder in
      builder["facebookId"] = facebookId
      builder["IOS"]        = ios
    }
    return token
  }
}

