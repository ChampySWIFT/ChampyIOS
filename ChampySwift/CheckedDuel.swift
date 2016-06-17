//
//  CheckedDuel.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/19/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Async
@IBDesignable class CheckedDuel: UIView {

  var view: UIView!
  
  @IBOutlet weak var topBarBackground: UIView!
  @IBOutlet weak var duelIcon: UIImageView!
  @IBOutlet weak var duelLabel: UILabel!
  @IBOutlet weak var recipientImage: UIImageView!
  @IBOutlet weak var sendertImage: UIImageView!
  
  @IBOutlet weak var challengeDescriptionLabel: UILabel!
  
  @IBOutlet weak var statsLabel: UILabel!
  
  @IBOutlet weak var daysLabel: UILabel!
  
  
  var challengeObject: JSON! = nil
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
    let nib    = UINib(nibName: "CheckedDuel", bundle: bundle)
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
    
    challengeObject = json
    let gradient:CAGradientLayer = CAGradientLayer()
    let frame                    = CGRect(x: 0, y:0, width: self.frame.size.width, height: topBarBackground.frame.size.height)
    gradient.frame               = frame
    
    gradient.colors              = [CHGradients().thirdTopBarColor, CHGradients().secondTopBarColor, CHGradients().firstTopBarColor]
    gradient.opacity = 0.8
    //Or any colors
    self.topBarBackground.layer.addSublayer(gradient)
    self.bringSubviewToFront(self.topBarBackground)
    //    recipientImage
    //    self.recipientImage.layer.opacity = 0.5
    self.sendertImage.layer.masksToBounds = true
    self.recipientImage.layer.masksToBounds = true
    //    self.topBarBackground.bringSubviewToFront(recipientImage)
    self.topBarBackground.bringSubviewToFront(duelIcon)
    self.topBarBackground.bringSubviewToFront(duelLabel)
    
    challengeDescriptionLabel.text = json["challenge"]["description"].stringValue
    statsLabel.text = "Level 1 Champy / Reward +\(json["challenge"]["points"].stringValue) "
    
    
    
    switch  CHSession().currentUserId {
    case json["sender"]["_id"].stringValue:
      self.duelLabel.text = "Duel with \(json["recipient"]["name"].stringValue)"
      CHImages().setImageForFriend(json["recipient"]["_id"].stringValue, imageView: self.recipientImage)
      CHImages().setImageForFriend(json["sender"]["_id"].stringValue, imageView: self.sendertImage)
      let days = Int(CHSettings().secToDays(json["challenge"]["duration"].intValue)) - json["senderProgress"].count
      var day:String = "days"
      if days == 1 {
        day = "day"
      }
      
      self.daysLabel.text = "\(days) \(day)"
      
      break
    case json["recipient"]["_id"].stringValue:
      self.duelLabel.text = "Duel with \(json["sender"]["name"].stringValue)"
      CHImages().setImageForFriend(json["sender"]["_id"].stringValue, imageView: self.sendertImage)
      CHImages().setImageForFriend(json["recipient"]["_id"].stringValue, imageView: self.recipientImage)
      let days = Int(CHSettings().secToDays(json["challenge"]["duration"].intValue)) - json["recipientProgress"].count
      var day:String = "days"
      if days == 1 {
        day = "day"
      }
      
      self.daysLabel.text = "\(days) \(day)"
      
      break
    default:
      self.duelLabel.text = "Duel"
    }
    
    self.daysLabel.adjustsFontSizeToFitWidth =  true
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  
}
