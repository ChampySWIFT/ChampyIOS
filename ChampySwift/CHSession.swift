//
//  CHSession.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import JWT
import SwiftyJSON

class CHSession: NSObject {
  
  let CurrentUser = NSUserDefaults.standardUserDefaults()
  
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
  
  func saveFacebookFriends(friends:String) {
    self.CurrentUser.setObject(friends, forKey: "facebookfriends")
  }
  
  func clearSession(completitionHandler:(result:Bool)->()) {
    let params = [
      "APNIdentifier" : "none" //deviceToken.description as String
    ]
    
    CHRequests().updateUserProfile(CHSession().currentUserId, params: params) { (result, json) in
    }
    
    let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
    
    self.CurrentUser.setObject(nil, forKey: "facebookId")
    self.CurrentUser.setObject(nil, forKey: "userName")
    self.CurrentUser.setObject(nil, forKey: "userId")
    self.CurrentUser.setObject(nil, forKey: "facebookfriends")
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
    FBSDKLoginManager().logOut()
    completitionHandler(result: true)
  }
  
  func getFacebookFriends() -> String {
    return self.getStringByKey("facebookfriends")
  }
  
  func getStringByKey(key:String) -> String {
    guard CurrentUser.objectForKey(key) != nil else {
      return ""
    }
    return CurrentUser.stringForKey(key)!
  }
  
  func getIntByKey(key:String) -> Int {
    guard CurrentUser.objectForKey(key) != nil else {
      return 0
    }
    return CurrentUser.integerForKey(key)
  }
  
  func getBoolByKey(key:String) -> Bool {
    
    guard CurrentUser.objectForKey(key) != nil else {
      return false
    }
    return CurrentUser.boolForKey(key)
  }
  
  func getJSONByKey(key:String) -> JSON {
//    print(self.getStringByKey(key))
    return CHUIElements().stringToJSON(self.getStringByKey(key))
  }
  
  func getToken() -> String {
    return createToken(self.currentUserFacebookId)
  }
  
  func getTokenWithFaceBookId(facebookId:String) -> String {
    return createToken(facebookId)
  }
  
  func createToken(facebookId:String) -> String {
    let ios = [
      "token": facebookId,
      "timeZone": "2"
    ]
    return JWT.encode(.HS256("secret")) { builder in
      builder["facebookId"] = facebookId
      builder["IOS"]        = ios
    }
    
  }
  
}

