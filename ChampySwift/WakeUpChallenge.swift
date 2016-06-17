//
//  WakeUpChallenge.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/2/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON


@IBDesignable class WakeUpChallenge: UIView {
  var view: UIView!
  var objectChallenge:JSON! = nil
  @IBOutlet weak var topBarBackground: UIView!
  @IBOutlet weak var wakeUpIcon: UIImageView!
  @IBOutlet weak var wakeUpLabel: UILabel!
  @IBOutlet weak var wakeUpDesc: UILabel!
  @IBOutlet weak var wakeUpDaysLeft: UILabel!
  @IBOutlet weak var wakeUpReward: UILabel!
  
  
  var tapped = false
  func xibSetup() {
    view                  = loadViewFromNib()
    // use bounds not frame or it'll be offset
    view.frame            = bounds
    // Make the view stretch with containing view
    view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    // Adding custom subview on top of our view (over any custom drawing > see note below)
    addSubview(view)
  }
  
  func loadViewFromNib() -> UIView {
    let bundle = NSBundle(forClass: self.dynamicType)
    let nib    = UINib(nibName: "WakeUpChallenge", bundle: bundle)
    let view   = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
    view.layer.cornerRadius = 5.0
    return view
  }
  
  override init(frame: CGRect) {
    // 1. setup any properties here
    // 2. call super.init(frame:)
    super.init(frame: frame)
    // 3. Setup view from .xib file
    xibSetup()
    
    
    
  }
  
  func setUp(json:JSON = nil){
    let gradient:CAGradientLayer = CAGradientLayer()
    let frame                    = CGRect(x: 0, y:0, width: self.frame.size.width, height: topBarBackground.frame.size.height)
    gradient.frame               = frame
    
    gradient.colors              = [CHGradients().thirdTopBarColor, CHGradients().secondTopBarColor, CHGradients().firstTopBarColor]//Or any colors
    self.topBarBackground.layer.addSublayer(gradient)
    self.bringSubviewToFront(self.topBarBackground)
    self.topBarBackground.bringSubviewToFront(wakeUpIcon)
    self.topBarBackground.bringSubviewToFront(wakeUpLabel)
    
    if json != nil {
      self.objectChallenge = json
      self.wakeUpDesc.text = "\(json["challenge"]["name"].stringValue) every day during \(CHSettings().secToDays(json["challenge"]["duration"].intValue)) days"
      let remainedDays = CHSettings().secToDays(json["challenge"]["duration"].intValue) - json["senderProgress"].count
      
      print(remainedDays)
      
      var day:String = "days"
      if remainedDays == 1 {
        self.wakeUpDesc.text = "\(json["challenge"]["name"].stringValue)"
        day = "day"
      }
      
      self.wakeUpDaysLeft.text = "\(remainedDays) \(day) to go"
      self.wakeUpReward.text = "Level 1 Champy / Reward +\(json["challenge"]["points"].stringValue)"
      self.wakeUpDaysLeft.adjustsFontSizeToFitWidth = true
      
    }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  @IBAction func surrenderAction(sender: AnyObject) {
    
    guard !tapped else {
      return
    }
    
    let button = sender as! UIButton
    
    tapped = true
    button.hidden = self.tapped
    
    CHRequests().surrender(self.objectChallenge["_id"].stringValue) { (result, json) in
      if !result {
        self.tapped = false
        button.hidden = self.tapped
        CHPush().alertPush(json["error"].stringValue, type: "Warning")
      } else {
        self.tapped = false
        CHPush().alertPush("Failed a challenge", type: "Success")
        CHPush().localPush("refreshIcarousel", object: [])
      }
    }
  }
 
  @IBAction func shareAction(sender: AnyObject) {
    guard !tapped else {
      return
    }
    
    tapped = true
    
    let textToShare = "Constantly improving myself with Champy. Wake-Up challenge “\(self.objectChallenge["challenge"]["name"].stringValue)”"
    if let topController = UIApplication.topViewController() {
      if let myWebsite = NSURL(string: "http://champyapp.com") {
        self.tapped = false
        let objectsToShare = [textToShare, myWebsite]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityVC.popoverPresentationController?.sourceView = sender as! UIView
        topController.presentViewController(activityVC, animated: true, completion: nil)
      }
    }
  }
  
  
  

  
}
