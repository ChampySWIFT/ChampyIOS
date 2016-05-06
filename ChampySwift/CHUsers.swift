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
    return "http://46.101.213.24:3007/photos/users/\(userId)/large.png"
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
  
}
