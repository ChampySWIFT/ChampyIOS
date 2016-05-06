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
  
  //openImagePicker - open image picker from main view
  
  
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
