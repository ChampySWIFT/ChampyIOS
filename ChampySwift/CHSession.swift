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
  
  let CurrentUser = UserDefaults.standard
  
  var currentUserObject:JSON!      = nil
  var currentUserId:String         = ""
  var currentUserFacebookId:String = ""
  var currentUserName:String       = ""
  public var logined:Bool          = false
  
  var selectedFriendId:String {
    if self.CurrentUser.object(forKey: "selectedFriendId") != nil {
      return self.CurrentUser.string(forKey: "selectedFriendId")!
    }
    return ""
  }
  
  
  override init() {
 
    super.init()
    
    
    
    
    if UserDefaults.standard.integer(forKey: "loggedIn") == 1 {
      self.currentUserId         = UserDefaults.standard.string(forKey: "userId")!
      self.currentUserName       = UserDefaults.standard.string(forKey: "userName")!
      self.currentUserFacebookId = UserDefaults.standard.string(forKey: "facebookId")!
      self.currentUserObject     = CHUIElements().stringToJSON(UserDefaults.standard.string(forKey: "userObject")!)

      self.logined               = true
    }
  }
  
    
  func updateUserObject(_ userObject:JSON) {
    self.currentUserObject     = userObject
    self.CurrentUser.set("\(userObject)", forKey: "userObject")
    
  }
  
  func isLogined() -> Bool {
    
    if CurrentUser.string(forKey: "facebookfriends") == nil  {
      self.logined = false
      return false
    }
    
    return true
  }
  
  func createSessionForTheUserWithFacebookId(_ facebookId:String, name:String, andObjectId objectId: String, userObject:JSON) {
    UserDefaults.standard.set(1, forKey: "loggedIn")
    self.CurrentUser.set(facebookId, forKey: "facebookId")
    self.CurrentUser.set(name, forKey: "userName")
    self.CurrentUser.set(objectId, forKey: "userId")
    self.CurrentUser.set("\(userObject)", forKey: "userObject")
    
  }
  
  func setSelectedFriend(_ userId:String) {
    UserDefaults.standard.set(userId, forKey: "selectedFriendId")
  }
  
  func saveFacebookFriends(_ friends:String) {
    self.CurrentUser.set(friends, forKey: "facebookfriends")
  }
  
  func clearSession(_ completitionHandler:(_ result:Bool)->()) {
    
    let userId = currentUserId
    let token = CHRequests().token
    
    Async.background {
      CHRequests().clearSession(userId, token: token) { (result, json) in
        
      }
    }
    
    
    
    
    let appDelegate     = UIApplication.shared.delegate as! AppDelegate
    
    UserDefaults.standard.set(0, forKey: "loggedIn")
   UserDefaults.standard.set(nil, forKey: "facebookId")
    UserDefaults.standard.set(nil, forKey: "userName")
    UserDefaults.standard.set(nil, forKey: "userId")
    UserDefaults.standard.set(nil, forKey: "facebookfriends")
    
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
    for (_, item) in array {
      item.removeFromSuperview()
    }
    URLCache.shared.removeAllCachedResponses()
    FBSDKLoginManager().logOut()
    completitionHandler(true)
    
  }
  
  func getFacebookFriends() -> String {
    return self.getStringByKey("facebookfriends")
  }
  
  func getStringByKey(_ key:String) -> String {
    guard CurrentUser.object(forKey: key) != nil else {
      return ""
    }
    return CurrentUser.string(forKey: key)!
  }
  
  func getIntByKey(_ key:String) -> Int {
    guard CurrentUser.object(forKey: key) != nil else {
      return 0
    }
    return CurrentUser.integer(forKey: key)
  }
  
  func getBoolByKey(_ key:String) -> Bool {
    
    guard CurrentUser.object(forKey: key) != nil else {
      return false
    }
    return CurrentUser.bool(forKey: key)
  }
  
  func getJSONByKey(_ key:String) -> JSON {

    return CHUIElements().stringToJSON(self.getStringByKey(key))
  }
  
  func getToken() -> String {
    return createToken(self.currentUserFacebookId)
  }
  
  func getTokenWithFaceBookId(_ facebookId:String) -> String {
    return createToken(facebookId)
  }
  
  func createToken(_ facebookId:String) -> String {
    let ios = [
      "token": facebookId,
      "timeZone": "2"
    ]
    let data = "secret".data(using: .utf8)
    
    
    return JWT.encode(.hs256(data!)) { (builder) in
      builder["facebookId"] = facebookId
      builder["IOS"]        = ios
    }
  }
  
}

