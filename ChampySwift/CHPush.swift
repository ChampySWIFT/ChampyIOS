//
//  CHPush.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit

class CHPush: NSObject {
  let center = NSNotificationCenter.defaultCenter()
  var CurrentUser:NSUserDefaults = NSUserDefaults.standardUserDefaults()
  
  //openImagePicker - open image picker from main view
  
  func sendPushToUser(userId:String, message:String, options:String, type:String = "usual", requestId:String = "nill")  {
    let data = [
      "alert" : message,
      "badge" : "Increment",
      "sounds" : "cheering.caf",
      "type":type,
      "requestId": requestId
      
    ]
    
    
  }
  
  
  func subscribeForNotifications() {
    #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
      return
    #endif
    let deviceToken:NSData = CurrentUser.dataForKey("deviceToken")!
    FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .Sandbox)
    
    guard let contents = FIRInstanceID.instanceID().token()
      else {
        return
    }
    
    let firtoken = FIRInstanceID.instanceID().token()!
    
    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var token = ""
    
    for i in 0..<deviceToken.length {
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
  
  func updateImageOnSettings(image:UIImage) {
    let name:String = "updateImage"
    let userObject = [
      "image": image
    ]
    
    center.postNotificationName(name, object: nil, userInfo: userObject)
    
  }
  
  func localPush(name:String, object:AnyObject) {
    center.postNotificationName(name, object: object)
  }
  
  func alertPush(message:String, type:String) {
    let object:[String:String] = [
      "type": type,
      "message": message
    ]
    
    center.postNotificationName("alert", object: nil, userInfo: object)
  }
  
}
