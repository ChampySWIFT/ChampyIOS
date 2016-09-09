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
  
  /**
   Return's photo url of the selected user
   
   @param userId object id of the selected user
   
   @return photo url of some user
   */
  func getPhotoUrlString(userId:String) -> String {
    return "http://46.101.213.24:3007/photos/users/\(userId)/medium.png"
  }
  
  /**
   Return's photo url of the selected user for background image
   
   @param userId object id of the selected user
   
   @return photo url of some user
   */
  func getPhotoUrlStringForBackgroung(userId:String) -> String {
    return "http://46.101.213.24:3007/photos/users/\(userId)/small.png"
  }
  
  /**
   Save information about the user locally
   
   @param facebookId user's facebook id
   @param objectId user's object id
   @param name the name of the user
   @param userObject json object [the user]
   
   @return null
   */
  func localCreateUser(facebookId:String, objectId:String, name:String, userObject:JSON) {
    CHSession().createSessionForTheUserWithFacebookId(facebookId, name: name, andObjectId: objectId, userObject: userObject )
  }
  
  
  /**
   check the selected user is valid
   
   @return users json array
   */
  func isValidUser(item:JSON) -> Bool {
    guard item["_id"].stringValue != CHSession().currentUserId else {
      return false
    }
    
//    guard item["photo"] != nil else {
//      return false
//    }
    
    guard item["name"].stringValue != "sadasfirstFacebookIdasda" else {
      return false
    }
    
    guard item["name"].stringValue != "sadassecondFacebookIdasda" else {
      return false
    }
    
    //    guard getStatus(item) == "Other" else {
    //      return false
    //    }
    return true
  }
  
  /**
   Get users from local database
   
   @return users json array
   */
  func getUsers() -> [JSON] {
    var friends:[JSON] = []
    for (_, item): (String, JSON) in CHSession().getJSONByKey("userList") {
      if self.isFacebookFriend(item["facebookId"].stringValue) {
        if isValidUser(item) {
          friends.append(item)
        }
      }
    }
    return friends
  }
  
  /**
   Get one user from local database
   
   @param userId user's object id
   
   @return user json object
   */
  func getUserById(userId:String) -> JSON {
    for (_, item): (String, JSON) in CHSession().getJSONByKey("userList") {
      guard item["_id"].stringValue == userId else {
        continue
      }
      return item
    }
    return nil
  }
  
  /**
   Get friends by status
   
   @param userId logged in user's object id
   @param status status [true, false]
   
   @return array of friends
   */
  func getFriendsByStatus(userId:String, status:Bool) -> [JSON] {
    var friends:[JSON] = []
    
    for (_, item): (String, JSON) in CHSession().getJSONByKey("friendsList(\(userId))") {
      guard item["owner"] != nil else {
        continue
      }
      
      guard item["friend"] != nil else {
        continue
      }
      
      guard item["status"].boolValue == status else {
        continue
      }
      
      friends.append(item)
      
    }
    return friends
  }
  
  
  /**
 
 */
  
  func isFacebookFriend(facebookId:String) -> Bool {
    let facebookFriends = CHSession().getFacebookFriends()
    if facebookFriends.rangeOfString(facebookId) != nil {
      return true
    }
    
    return false
  }
  
  func getFacebookFriendsQueryPart() -> String {
    let array:[String] = CHSettings().facebookFriendsStringToArray(CHSession().getFacebookFriends())
    var i = 0
    var queryString = ""
    for item in array {
      queryString = queryString + "&facebookFriends[\(i)]=\(item)"
      i=i+1
    }
   
    return queryString
  }
  
  
  
  /**
   Get pending friends
   
   @param userId logged in user's object id
   
   @return array of pending friends
   */
  func getPendingFriend(userId:String) -> [JSON] {
    return getFriendsByStatus(userId, status: false)
  }
  
  /**
   Get pending friends [helper]
   
   @param userId logged in user's object id
   
   @return array of pending friends
   */
  func getFriends(userId:String) -> [JSON] {
    return getFriendsByStatus(userId, status: true)
  }
  
  /**
   Get pending friends
   
   @param jsonItem friendship json object
   
   @return the status of selected friendship [Outgoing, Incoming, Other, Friends]
   */
  func getStatus(jsonItem:JSON) -> String {
    let userId: String = jsonItem["_id"].stringValue
    var result = "Other"
    for (_, item): (String, JSON) in CHSession().getJSONByKey("friendsList(\(CHSession().currentUserId))") {
      guard item["owner"] != nil else {
        continue
      }
      
      guard item["friend"] != nil else {
        continue
      }
      
      if item["owner"]["_id"].stringValue == userId || item["friend"]["_id"].stringValue == userId {
        if !item["status"].boolValue  {
          if item["owner"]["_id"].stringValue == userId {
            result =  "Outgoing"
            break
          }
          
          if item["friend"]["_id"].stringValue == userId {
            result =  "Incoming"
            break
          }
          
          result =  "Other"
          break
        } else {
          result =  "Friends"
          break
        }
      }
      
      
    }
    
    return result
  }
  
  
  
}
