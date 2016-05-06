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

class CHImages: NSObject {
  
  func setUpAvatar(imageView:UIImageView, urlString:String = CHUsers().getPhotoUrlString(CHSession().currentUserId)) {
    let url = NSURL(string: CHUsers().getPhotoUrlString(CHSession().currentUserId))
    let myCache = ImageCache(name: urlString)
    
    if IJReachability.isConnectedToNetwork() {
      myCache.clearDiskCache()
      myCache.clearMemoryCache()
      myCache.cleanExpiredDiskCache()
    }
    imageView.kf_setImageWithURL(url!, placeholderImage: UIImage(named: "MainBackground"), optionsInfo: [.TargetCache(myCache)], progressBlock: { (receivedSize, totalSize) in
      print("Downloading")
    }) { (image, error, cacheType, imageURL) in
      print("Downloaded")
      
    }
  }
  
  func setUpBackground(imageView:UIImageView, frame:CGRect = CGRect()) {
    let url = NSURL(string: CHUsers().getPhotoUrlString(CHSession().currentUserId))
    let myCache = ImageCache(name: "\(url)")
    
    let optionInfo: KingfisherOptionsInfo = [
      .TargetCache(myCache),
      .DownloadPriority(1),
      .Transition(ImageTransition.Fade(1))
    ]
    if IJReachability.isConnectedToNetwork() {
      myCache.clearDiskCache()
      myCache.clearMemoryCache()
      myCache.cleanExpiredDiskCache()
    }
    imageView.kf_setImageWithURL(url!, placeholderImage: UIImage(named: "MainBackground"), optionsInfo: optionInfo, progressBlock: { (receivedSize, totalSize) in
      print("Downloading")
    }) { (image, error, cacheType, imageURL) in
      print("Downloaded")
      
    }
    
    //    let frame        = CGRect(x: 0, y: 0, width: imageView.frame.size.width, height: imageView.frame.size.height)
    //    let frame = frame
    let blurView     = APCustomBlurView(withRadius: 10)
    let gradient     = CAGradientLayer()
    blurView.frame   = frame
    gradient.frame   = frame
    gradient.colors  = [CHGradients().backgroundGradiend1, CHGradients().backgroundGradiend2]//Or any colors
    gradient.opacity = 0.75
    
    blurView.layer.addSublayer(gradient)
    
    imageView.addSubview(blurView)
    
    
  }
  
}
