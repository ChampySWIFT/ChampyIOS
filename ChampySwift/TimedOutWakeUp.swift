//
//  TimedOutWakeUp.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/31/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable class TimedOutWakeUp: UIView {

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
    view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
    // Adding custom subview on top of our view (over any custom drawing > see note below)
    addSubview(view)
  }
  
  func loadViewFromNib() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nib    = UINib(nibName: "TimedOutWakeUp", bundle: bundle)
    let view   = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
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
  
  func setUp(_ json:JSON = nil){
    let gradient:CAGradientLayer = CAGradientLayer()
    let frame                    = CGRect(x: 0, y:0, width: self.frame.size.width, height: topBarBackground.frame.size.height)
    gradient.frame               = frame
    
    gradient.colors              = [CHGradients().thirdTopBarColor, CHGradients().secondTopBarColor, CHGradients().firstTopBarColor]//Or any colors
    self.topBarBackground.layer.addSublayer(gradient)
    self.bringSubview(toFront: self.topBarBackground)
    self.topBarBackground.bringSubview(toFront: wakeUpIcon)
    self.topBarBackground.bringSubview(toFront: wakeUpLabel)
    
    if json != nil {
      self.objectChallenge = json
      self.wakeUpDesc.text = "\(json["challenge"]["name"].stringValue) every day during \(CHSettings().secToDays(json["challenge"]["duration"].intValue)) days"
      let remainedDays = CHSettings().secToDays(json["challenge"]["duration"].intValue) - json["senderProgress"].intValue
      
      var day:String = "days"
      if remainedDays == 1 {
        self.wakeUpDesc.text = "\(json["challenge"]["name"].stringValue)"
        day = "day"
      }
      
      self.wakeUpDaysLeft.text = "\(remainedDays) \(day) to go"
//      self.wakeUpReward.text = "Level 1 Champy / Reward +\(json["challenge"]["points"].stringValue)"
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
  
  
  

}
