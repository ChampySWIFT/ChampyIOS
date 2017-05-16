//
//  APPBanners.swift
//  Plug Spot
//
//  Created by Molnar Kristian on 3/2/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit

enum CHBannerTypes: String {
  case Info    = "Info"
  case Warning = "Warning"
  case Success = "Success"
  case Default = "Default"
}

class CHBanners: NSObject {
  
  var banner:UIView!           = nil
  var target:UIView!           = nil
  var tableTarget:UITableView! = nil
  var backgroundColor:UIColor! = nil
  var textColor:UIColor!       = UIColor.white
  var bannerText:String        = ""
  
  var bannerLabel:UILabel! = nil
  
  let bannerHeight:CGFloat = 10.0
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
  
  func showBannerForViewControllerAnimated(_ animated:Bool, message:String) {
    if message == "" {
      return
    }
    self.bannerText = message
    self.createBanner(message)
    self.target.addSubview(self.banner)
    self.target.bringSubview(toFront: self.banner)
    
    animated ? self.animateView(): setUpOpacity()
    
    if vibrating {
      CHUIElements().vibrating()
    }
    
    setTimeout(self.visibilityDuration, block: { () -> Void in
      self.dismissView()
    })
    
  }
  
  
  func showBannerForViewControllerAnimatedWithReturning(_ animated:Bool, message:String) -> CHBanners {
    self.bannerText = message
    self.createBanner(message)
    self.target.addSubview(self.banner)
    self.target.bringSubview(toFront: self.banner)
    animated ? self.animateView(): setUpOpacity()
        
    return self
  }
  
  func showBannerForTableViewControllerAnimated(_ animated:Bool, message:String) {
    self.bannerText = message
    self.tableTarget.addSubview(self.createBanner(message))
    animated ? self.animateView(): setUpOpacity()
    
    
    
    setTimeout(self.visibilityDuration, block: { () -> Void in
      self.dismissView()
    })
  }
  
  func changeText(_ text:String) {
    DispatchQueue.main.async { () -> Void in
      self.bannerLabel.text = text
    }
  }
  
  func changeType(_ type:CHBannerTypes) {
    self.backgroundColor = CHUIElements().APPColors[type.rawValue]
    if self.banner != nil {
      self.banner.backgroundColor = self.backgroundColor
    }
  }
  
  func createBanner(_ message:String) -> UIView {
    self.banner                 = UIView(frame: CGRect(x: 0, y: 64, width: self.target.frame.size.width, height: self.bannerHeight + 20))
    self.banner.backgroundColor = self.backgroundColor
    self.banner.layer.opacity   = 0
    
    self.bannerLabel                           = UILabel(frame: CGRect(x: 0, y: 10, width: self.target.frame.size.width, height: self.bannerHeight))
    self.bannerLabel.font = CHUIElements().font12
    self.bannerLabel.text                      = self.bannerText
    self.bannerLabel.textColor                 = self.textColor
    self.bannerLabel.textAlignment             = .center
    //    self.bannerLabel.adjustsFontSizeToFitWidth = true
    self.bannerLabel.lineBreakMode = .byWordWrapping
    self.bannerLabel.numberOfLines = 3
    
    
    banner.addSubview(bannerLabel)
    return banner
  }
  
  func changeBannerTopmargin(_ margin:CGFloat) {
    DispatchQueue.main.async { () -> Void in
      self.banner.frame = CGRect(x: 0, y: margin, width: self.target.frame.size.width, height: self.bannerHeight)
    }
  }
  
  func dismissView(_ withTimeOut:Bool = false) {
    if banner != nil {
      var time:Double = 0.0
      if withTimeOut {
        time = 2.0
      }
      
      UIView.animate(withDuration: 1.0, delay: time, options: .curveEaseOut, animations: {
        self.banner.layer.opacity = 0
        }, completion: { finished in
          self.banner.removeFromSuperview()
      })
    }
  }
  
  func forceDismiss(){
    DispatchQueue.main.async { () -> Void in
      self.banner.layer.opacity = 0
      self.banner.removeFromSuperview()
    }
  }
  
  func animateView() {
    var frame = banner.frame
    frame.origin.x = -1 * frame.size.width
    self.banner.layer.opacity = 0
    
    UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
      self.banner.layer.opacity = 1
      }, completion: { finished in
        
    })
  }
  
  func setUpOpacity() {
    self.banner.layer.opacity = 1
  }
  
  func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
  }
}
