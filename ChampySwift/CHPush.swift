//
//  CHPush.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Firebase
class CHPush: NSObject {
  let center = NotificationCenter.default
  var CurrentUser:UserDefaults = UserDefaults.standard
  
  //openImagePicker - open image picker from main view
  
  func sendPushToUser(_ userId:String, message:String, options:String, type:String = "usual", requestId:String = "nill")  {
    
  }
  
  
  func subscribeForNotifications() {
    #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
      return
    #endif
    
    
    if CurrentUser.object(forKey: "deviceToken") == nil {
      return
    }
    
    
    let deviceToken:Data = CurrentUser.data(forKey: "deviceToken")!
    FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .prod)
    
    guard FIRInstanceID.instanceID().token() != nil
      else {
        return
    }
    
    let firtoken = FIRInstanceID.instanceID().token()!
    
    let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
    var token = ""
    
    for i in 0..<deviceToken.count {
      token += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    
    
    let params = [
      "APNIdentifier" : firtoken 
    ]
    
    CHRequests().updateUserProfile(CHSession().currentUserId, params: params) { (result, json) in
     
    }
  }
  
  
  
  /*
   clear badge number
   */
  
  func clearBadgeNumber(){
    CHRequests().cleareBadgeNumber(CHSession().currentUserId) { (json, status) in
      
    }
  }
  
  func updateImageOnSettings(_ image:UIImage) {
    let name:String = "updateImage"
    let userObject = [
      "image": image
    ]
    
    center.post(name: Notification.Name(rawValue: name), object: nil, userInfo: userObject)
    
  }
  
  func localPush(_ name:String, object:AnyObject) {
    center.post(name: Notification.Name(rawValue: name), object: object)
  }
  
  func alertPush(_ message:String, type:String) {
    let object:[String:String] = [
      "type": type,
      "message": message
    ]
    
    center.post(name: Notification.Name(rawValue: "alert"), object: nil, userInfo: object)
  }
  
}
