//
//  CHUsers.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON

class CHUsers: NSObject {
  
  func getPhotoUrlString(userId:String) -> String {
    return "http://46.101.213.24:3007/photos/users/\(userId)/medium.png"
  }
  
  func getPhotoUrlStringForBackgroung(userId:String) -> String {
    return "http://46.101.213.24:3007/photos/users/\(userId)/small.png"
  }
  
  func localCreateUser(facebookId:String, objectId:String, name:String, userObject:JSON) {
    CHSession().createSessionForTheUserWithFacebookId(facebookId, name: name, andObjectId: objectId, userObject: userObject )
  }
  
  
  func stringToJSON(jsonString:String) -> JSON {
    do {
      if let data:NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
        if jsonString != "error" {
          let jsonResult:JSON = JSON(data: data)
          return jsonResult
        }
      }
    }
    catch let error as NSError {
      
    }
    
    return nil
  }
  
  func getUsers() -> [JSON] {
    var friends:[JSON] = []
    if CHSession().CurrentUser.objectForKey("userList") != nil {
      let friendsJSON = self.stringToJSON(CHSession().CurrentUser.stringForKey("userList")!)
      for (_, item): (String, JSON) in friendsJSON {
        if item["_id"].stringValue != CHSession().currentUserId {
          if item["photo"] != nil {
            friends.append(item)
          }
        }
      }
    }
    return friends
  }
  
  func getPendingFriend(userId:String) -> [JSON] {
    //friendsList(\(userId))
    var friends:[JSON] = []
    if CHSession().CurrentUser.objectForKey("friendsList(\(userId))") != nil {
      let friendsJSON = self.stringToJSON(CHSession().CurrentUser.stringForKey("friendsList(\(userId))")!)
      for (_, item): (String, JSON) in friendsJSON {
        if item["status"].stringValue == "false" {
          friends.append(item)
        }
      }
    }
    return friends
  }
  
  
  func getFriends(userId:String) -> [JSON] {
    //friendsList(\(userId))
    var friends:[JSON] = []
    if CHSession().CurrentUser.objectForKey("friendsList(\(userId))") != nil {
      let friendsJSON = self.stringToJSON(CHSession().CurrentUser.stringForKey("friendsList(\(userId))")!)
      for (_, item): (String, JSON) in friendsJSON {
        if item["status"].stringValue == "true" {
          friends.append(item)
        }
      }
    }
    return friends
  }
}
