//
//  APPBanners.swift
//  Plug Spot
//
//  Created by Molnar Kristian on 3/2/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit


class CHBanners: NSObject {
  
  var banner:UIView!           = nil
  var target:UIView!           = nil
  var tableTarget:UITableView! = nil
  var backgroundColor:UIColor! = nil
  var textColor:UIColor!       = UIColor.whiteColor()
  var bannerText:String        = ""
  
  var bannerLabel:UILabel! = nil
  
  let bannerHeight:CGFloat = 44.0
  var visibilityDuration:Double = 2.0
  
  var vibrating:Bool = false
  
  enum CHBannerTypes: String {
    case Info    = "Info"
    case Warning = "Warning"
    case Success = "Success"
    case Default = "Default"
  }
  
  override init() {
    super.init()
  }
  
  convenience init(withTarget targetView: UIView, andType type:CHBannerTypes) {
    self.init()
    self.target          = targetView
    self.backgroundColor = CHUIElements().APPColors[type.rawValue]
    if type == .Warning {
      vibrating = true
    }
  }
  
  convenience init(withTableTarget targetView: UITableView, andType type:CHBannerTypes) {
    self.init()
    self.tableTarget     = targetView
    self.backgroundColor = CHUIElements().APPColors[type.rawValue]
  }
  
  func showBannerForViewControllerAnimated(animated:Bool, message:String) {
    if message == "" {
      return
    }
    self.bannerText = message
    self.createBanner(message)
    self.target.addSubview(self.banner)
    self.target.bringSubviewToFront(self.banner)
    
    animated ? self.animateView(): setUpOpacity()
    
    if vibrating {
      CHUIElements().vibrating()
    }
    
    setTimeout(self.visibilityDuration, block: { () -> Void in
      self.dismissView()
    })
    
  }
  
  
  func showBannerForViewControllerAnimatedWithReturning(animated:Bool, message:String) -> CHBanners {
    self.bannerText = message
    self.createBanner(message)
    self.target.addSubview(self.banner)
    self.target.bringSubviewToFront(self.banner)
    animated ? self.animateView(): setUpOpacity()
    
    
    
    //    setTimeout(self.visibilityDuration, block: { () -> Void in
    //      self.dismissView()
    //    })
    
    return self
  }
  
  func showBannerForTableViewControllerAnimated(animated:Bool, message:String) {
    self.bannerText = message
    self.tableTarget.addSubview(self.createBanner(message))
    animated ? self.animateView(): setUpOpacity()
    
    
    
    setTimeout(self.visibilityDuration, block: { () -> Void in
      self.dismissView()
    })
  }
  
  func changeText(text:String) {
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      self.bannerLabel.text = text
    }
  }
  
  func changeType(type:CHBannerTypes) {
    self.backgroundColor = CHUIElements().APPColors[type.rawValue]
    self.banner.backgroundColor = self.backgroundColor
  }
  
  func createBanner(message:String) -> UIView {
    self.banner                 = UIView(frame: CGRectMake(0, 0, self.target.frame.size.width, self.bannerHeight + 20))
    self.banner.backgroundColor = self.backgroundColor
    self.banner.layer.opacity   = 0
    
    self.bannerLabel                           = UILabel(frame: CGRectMake(0, 20, self.target.frame.size.width, self.bannerHeight))
    self.bannerLabel.font = CHUIElements().font12
    self.bannerLabel.text                      = self.bannerText
    self.bannerLabel.textColor                 = self.textColor
    self.bannerLabel.textAlignment             = .Center
    //    self.bannerLabel.adjustsFontSizeToFitWidth = true
    self.bannerLabel.lineBreakMode = .ByWordWrapping
    self.bannerLabel.numberOfLines = 3
    
    
    banner.addSubview(bannerLabel)
    return banner
  }
  
  func changeBannerTopmargin(margin:CGFloat) {
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      self.banner.frame = CGRectMake(0, margin, self.target.frame.size.width, self.bannerHeight)
    }
  }
  
  func dismissView(withTimeOut:Bool = false) {
    var frame = banner.frame
    frame.origin.x = 2 * frame.size.width
    var time:Double = 0.0
    if withTimeOut {
      time = 2.0
    }
    
    UIView.animateWithDuration(1.0, delay: time, options: .CurveEaseOut, animations: {
      self.banner.frame = frame
      self.banner.layer.opacity = 0
      }, completion: { finished in
        self.banner.removeFromSuperview()
    })
  }
  
  func forceDismiss(){
    dispatch_async(dispatch_get_main_queue()) { () -> Void in
      self.banner.layer.opacity = 0
      self.banner.removeFromSuperview()
    }
  }
  
  func animateView() {
    var frame = banner.frame
    let newFrame = banner.frame
    
    frame.origin.x = -1 * frame.size.width
    banner.frame = frame
    self.banner.layer.opacity = 0
    
    UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseOut, animations: {
      self.banner.layer.opacity = 1
      self.banner.frame = newFrame
      }, completion: { finished in
        
    })
  }
  
  func setUpOpacity() {
    self.banner.layer.opacity = 1
  }
  
  func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
    return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: #selector(NSOperation.main), userInfo: nil, repeats: false)
  }
  
  //  convenience override init() {
  //    self.init(fromString:"John") // calls above mentioned controller with default name
  //  }
  
}
