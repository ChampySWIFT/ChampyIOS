//
//  CHImages.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/4/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Kingfisher
import DynamicBlurView
import SwiftyJSON

class CHImages: NSObject {
  
  func setUpAvatar(imageView:UIImageView, urlString:String = CHUsers().getPhotoUrlString(CHSession().currentUserId)) {
    
    let url = NSURL(string: CHUsers().getPhotoUrlString(CHSession().currentUserId))
    let userObject:JSON = CHUsers().getUserById(CHSession().currentUserId)
    
    var cachename = "initialCache"
    if userObject["lastPhotoUpdated"].intValue != 0 {
      cachename = userObject["lastPhotoUpdated"].stringValue
    }
    let myCache = ImageCache(name: cachename)
    
    imageView.kf_setImageWithURL(url!, placeholderImage: UIImage(named: "MainBackground"), optionsInfo: [.TargetCache(myCache)], progressBlock: { (receivedSize, totalSize) in

    }) { (image, error, cacheType, imageURL) in
    }
  }
  
  func setImageForFriend(userId:String, imageView:UIImageView, frame:CGRect = CGRect()) {
    let url = NSURL(string: CHUsers().getPhotoUrlString(userId))
    var userObject:JSON! = nil
    
    if userId == CHSession().currentUserId {
      userObject = CHSession().currentUserObject
    } else {
      userObject = CHUsers().getUserById(userId)
    }
    
    var cachename = "initialCache"
    if userObject["lastPhotoUpdated"].intValue != 0 {
      cachename = userObject["lastPhotoUpdated"].stringValue
    }
    let myCache = ImageCache(name: cachename)

    imageView.kf_setImageWithURL(url!, placeholderImage: UIImage(named: "noImageIcon"), optionsInfo: [.TargetCache(myCache)], progressBlock: { (receivedSize, totalSize) in
    }) { (image, error, cacheType, imageURL) in }
  }
  
  func setUpBackground(imageView:UIImageView, frame:CGRect = CGRect()) {
    imageView.layer.masksToBounds = true
    let url = NSURL(string: CHUsers().getPhotoUrlStringForBackgroung(CHSession().currentUserId))
    let userObject:JSON =  CHSession().currentUserObject
    
    var cachename = "initialCache"
    if userObject["lastPhotoUpdated"].intValue != 0 {
      cachename = userObject["lastPhotoUpdated"].stringValue
    }
    let myCache = ImageCache(name: cachename)

    
    let optionInfo: KingfisherOptionsInfo = [
      .TargetCache(myCache),
      .DownloadPriority(1),
      .Transition(ImageTransition.Fade(1))
    ]
    
    imageView.kf_setImageWithURL(url!, placeholderImage: UIImage(named: "MainBackground"), optionsInfo: optionInfo, progressBlock: { (receivedSize, totalSize) in

    }) { (image, error, cacheType, imageURL) in

      
    }
    
    
    let gradient     = CAGradientLayer()
    gradient.frame   = frame
    gradient.colors  = [CHGradients().backgroundGradiend1, CHGradients().backgroundGradiend2]//Or any colors
    gradient.opacity = 0.75
    
    
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame   = frame
    blurView.frame = blurView.bounds
    blurView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
    
    imageView.makeBlurImage(imageView)
    imageView.layer.addSublayer(gradient)
    
    
  }
  
}

extension UIImageView{
  
  func makeBlurImage(targetImageView:UIImageView?) {
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
    
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.alpha = 0.7
    blurEffectView.frame = targetImageView!.bounds
    blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
    targetImageView?.addSubview(blurEffectView)
  }
  
}
