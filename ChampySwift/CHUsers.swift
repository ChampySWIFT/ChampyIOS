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
  func getPhotoUrlString(_ userId:String) -> String {
    return "http://46.101.213.24:3007/photos/users/\(userId)/medium.png"
  }
  
  /**
   Return's photo url of the selected user for background image
   
   @param userId object id of the selected user
   
   @return photo url of some user
   */
  func getPhotoUrlStringForBackgroung(_ userId:String) -> String {
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
  func localCreateUser(_ facebookId:String, objectId:String, name:String, userObject:JSON) {
    CHSession().createSessionForTheUserWithFacebookId(facebookId, name: name, andObjectId: objectId, userObject: userObject )
  }
  
  
  /**
   check the selected user is valid
   
   @return users json array
   */
  func isValidUser(_ item:JSON) -> Bool {
    guard item["_id"].stringValue != CHSession().currentUserId else {
      return false
    }
    
//    guard item["photo"] != nil else {
//      return false
//    }
//    
    guard item["name"].stringValue != "sadasfirstFacebookIdasda" else {
      return false
    }
    
    guard item["name"].stringValue != "sadassecondFacebookIdasda" else {
      return false
    }
    
//        guard getStatus(item) == "Other" else {
//          return false
//        }
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
  
  func getUsersCount() -> Int {
    return CHSession().getJSONByKey("userList").arrayValue.count
  }
  
  func getUsers(from:Int, to:Int) -> [JSON] {
    let array = CHSession().getJSONByKey("userList").arrayValue[from...to]
    var friends:[JSON] = []
    for item in array {
      if !self.isFacebookFriend(item["facebookId"].stringValue) || !isValidUser(item) {
//                continue
      }
//      
      if !isValidUser(item) {
//        continue
      }
      friends.append(item)
    }
//    
//    for i:Int in from...to {
//     
//    }
//    
    return friends
  }
 
  
  func getIncomingRequestCount() -> Int {
    var result = 0
    for friend in getPendingFriend(CHSession().currentUserId) {
      
      switch CHSession().currentUserId {
      case friend["friend"]["_id"].stringValue:
        break
        
      case friend["owner"]["_id"].stringValue:
       result += 1
        break
      default:
        continue
      }
    }
    
    return result
  }
  
  /**
   Get one user from local database
   
   @param userId user's object id
   
   @return user json object
   */
  func getUserById(_ userId:String) -> JSON {
    return CHSession().getJSONByKey("userList").userImLookinFor(key: "_id", value: userId)
   
  }

  
  
  /**
   Get friends by status
   
   @param userId logged in user's object id
   @param status status [true, false]
   
   @return array of friends
   */
  func getFriendsByStatus(_ userId:String, status:Bool) -> [JSON] {
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
  
  func isFacebookFriend(_ facebookId:String) -> Bool {
    if CHSession().getFacebookFriends().range(of: facebookId) != nil {
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
  func getPendingFriend(_ userId:String) -> [JSON] {
    return getFriendsByStatus(userId, status: false)
  }
  
  /**
   Get pending friends [helper]
   
   @param userId logged in user's object id
   
   @return array of pending friends
   */
  func getFriends(_ userId:String) -> [JSON] {
    return getFriendsByStatus(userId, status: true)
  }
  
  /**
   Get pending friends
   
   @param jsonItem friendship json object
   
   @return the status of selected friendship [Outgoing, Incoming, Other, Friends]
   */
  func getStatus(_ jsonItem:JSON) -> String {
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

//extension FDataSnapshot {
//  var json : JSON {
//    return JSON(self.value)
//  }
//}
