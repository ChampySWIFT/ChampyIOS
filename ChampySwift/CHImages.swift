//
//  CHImages.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/4/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyJSON

class CHImages: NSObject {
  let appDelegate     = UIApplication.shared.delegate as! AppDelegate
  
  func setUpAvatar(_ imageView:UIImageView, urlString:String = CHUsers().getPhotoUrlString(CHSession().currentUserId)) {
    
    let url = URL(string: CHUsers().getPhotoUrlString(CHSession().currentUserId))
    let user:JSON = CHSession().currentUserObject
    
    var cachename = "initialCache"
    
    
    if user["lastPhotoUpdated"].intValue != 0 {
      cachename = user["lastPhotoUpdated"].stringValue
    }
    let myCache = ImageCache(name: cachename)
    
    imageView.kf.setImage(with: url, placeholder:  appDelegate.prototypeNoImage, options: [.targetCache(myCache)], progressBlock: { (receivedSize, totalSize) in
      
      }) { (image, error, cacheType, imageUrl) in
        
    }
    
    
  }
  //Bundle.main.url(forResource: "champy", withExtension: "png")
  
  func setUpDefaultImageForFriend(_ userId:String, imageView:UIImageView, frame:CGRect = CGRect()) {
    let url = Bundle.main.url(forResource: "champy", withExtension: "png")
    
    let cachename = "defaultImage"
    let myCache = ImageCache(name: cachename)
    
    
    imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "noImageIcon"), options: [.targetCache(myCache)], progressBlock: { (receivedSize, totalSize) in
      
    }) { (image, error, cacheType, imageUrl) in
      
    }
  }
  
  func setImageForFriend(_ userId:String, imageView:UIImageView, frame:CGRect = CGRect(), userObject:JSON = nil) {
    let url = URL(string: CHUsers().getPhotoUrlString(userId))
    var user:JSON! = userObject
    
    
    if user == nil {
      if userId == CHSession().currentUserId {
        user = CHSession().currentUserObject
      } else {
        user = CHUsers().getUserById(userId)
      }
    }
    
    var cachename = "default"
    if user["lastPhotoUpdated"].intValue != 0 {
      cachename = user["lastPhotoUpdated"].stringValue
    }
    let myCache = ImageCache(name: cachename)
    
    
    imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "noImageIcon"), options: [.targetCache(myCache)], progressBlock: { (receivedSize, totalSize) in
      
    }) { (image, error, cacheType, imageUrl) in
      
    }
    
  }
  
  
  
  
  func setUpBackground(_ imageView:UIImageView, frame:CGRect = CGRect()) {
    imageView.layer.masksToBounds = true
    let url = URL(string: CHUsers().getPhotoUrlStringForBackgroung(CHSession().currentUserId))
    let userObject:JSON =  CHSession().currentUserObject
    
    var cachename = "initialCache"
    if userObject["lastPhotoUpdated"].intValue != 0 {
      cachename = userObject["lastPhotoUpdated"].stringValue
    }
    let myCache = ImageCache(name: cachename)

    
//    let optionInfo: KingfisherOptionsInfo = [
//      .targe(myCache),
//      .DownloadPriority(1),
//      .Transition(ImageTransition.Fade(1))
//    ]
    
    imageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "MainBackground"), options: [.targetCache(myCache)], progressBlock: { (receivedSize, totalSize) in
      
    }) { (image, error, cacheType, imageUrl) in
      
    }
    
    
    let gradient     = CAGradientLayer()
    gradient.frame   = frame
    gradient.colors  = [CHGradients().backgroundGradiend1, CHGradients().backgroundGradiend2]//Or any colors
    gradient.opacity = 0.75
    
    
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame   = frame
    blurView.frame = blurView.bounds
    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
    
    imageView.makeBlurImage(imageView)
    imageView.layer.addSublayer(gradient)
    
    
  }
  
}


