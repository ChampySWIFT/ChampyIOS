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
  
  var currentUserObject:JSON! = nil
  var currentUserId:String         = ""
  var currentUserFacebookId:String = ""
  var currentUserName:String       = ""
  var logined:Bool                 = false
  
  override init() {
    let user = NSUserDefaults.standardUserDefaults()
    if user.objectForKey("facebookId") != nil && user.objectForKey("userName") != nil && user.objectForKey("userId") != nil && user.objectForKey("userObject") != nil {
      self.currentUserId         = self.CurrentUser.stringForKey("userId")!
      self.currentUserName       = self.CurrentUser.stringForKey("userName")!
      self.currentUserFacebookId = self.CurrentUser.stringForKey("facebookId")!
      self.currentUserObject     = CHUsers().stringToJSON(self.CurrentUser.stringForKey("userObject")!)
      self.logined               = true
    }
  }
  
  func createSessionForTheUserWithFacebookId(facebookId:String, name:String, andObjectId objectId: String, userObject:JSON) {
    
    self.CurrentUser.setObject(facebookId, forKey: "facebookId")
    self.CurrentUser.setObject(name, forKey: "userName")
    self.CurrentUser.setObject(objectId, forKey: "userId")
    self.CurrentUser.setObject("\(userObject)", forKey: "userObject")
    
  }
  
  
  func clearSession() {
    self.CurrentUser.setObject(nil, forKey: "facebookId")
    self.CurrentUser.setObject(nil, forKey: "userName")
    self.CurrentUser.setObject(nil, forKey: "userId")
//    self.CurrentUser.setObject(nil, forKey: "userObject")
    self.logined = false
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

