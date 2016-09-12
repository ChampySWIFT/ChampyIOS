//
//  CHPush.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Parse
import Firebase
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
    
    let info:[String:String] = [
      "type":type
    ]
    
    let push = PFPush()
    push.setChannels(["user_\(userId)"])
    push.setData(data)
    
    do {
      try  push.sendPush()
    } catch  {
      
    }
  }
  
  
  func subscribeForNotifications() {
    let deviceToken:NSData = CurrentUser.dataForKey("deviceToken")!
    FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .Sandbox)
    
    guard let contents = FIRInstanceID.instanceID().token()
      else {
        return
    }
    
    let firtoken = FIRInstanceID.instanceID().token()!
    ////////print(firtoken)
    let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
    var token = ""
    //////print(token)
    for i in 0..<deviceToken.length {
      token += String(format: "%02.2hhx", arguments: [tokenChars[i]])
    }
    
    //////print(token)
    let params = [
      "APNIdentifier" : firtoken //deviceToken.description as String
    ]
    
    CHRequests().updateUserProfile(CHSession().currentUserId, params: params) { (result, json) in
      if result {
        ////////print("success")
      }
    }
  }
  
  /*
   Subscribe User to channel
   
   types of channels:
   
   user_'deviceToken' : unknown user,
   user_'objectId'    : logined and registered user
   user_'spotId'      : user or business in host mode
   */
  
  func subscribeUserTo(channelIdentifier:String){
    let installation = PFInstallation.currentInstallation()
    var deviceToken:NSData = NSData()
    if CurrentUser.objectForKey("deviceToken") != nil{
      deviceToken = CurrentUser.dataForKey("deviceToken")!
    } else {
      deviceToken = "valamicsoda".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
    
    installation.setDeviceTokenFromData(deviceToken)
    installation.addUniqueObject("user_\(channelIdentifier)", forKey: "channels")
    installation.saveInBackground()
  }
  
  /*
   Unsubscribe User to channel
   
   types of channels:
   
   user_'deviceToken' : unknown user,
   user_'objectId'    : logined and registered user
   user_'spotId'      : user or business in host mode
   */
  
  func unSubscribeUserFrom(channelIdentifier:String){
    let currentInstallation = PFInstallation.currentInstallation()
    currentInstallation.removeObject("user_\(channelIdentifier)", forKey: "channels")
    currentInstallation.saveInBackground()
    
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
