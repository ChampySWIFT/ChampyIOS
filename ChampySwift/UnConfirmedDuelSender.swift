//
//  UnConfirmedDuelSender.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/19/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import SwiftyJSON
@IBDesignable class UnConfirmedDuelSender: UIView {

  var view: UIView!
  var challengeObject:JSON! = nil
  @IBOutlet weak var topBarBackground: UIView!
  @IBOutlet weak var duelIcon: UIImageView!
  @IBOutlet weak var duelLabel: UILabel!
  @IBOutlet weak var recipientImage: UIImageView!
  
  @IBOutlet weak var challengeDescriptionLabel: UILabel!
  
  @IBOutlet weak var statsLabel: UILabel!
  
  @IBOutlet weak var daysLabel: UILabel!
  
 
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
    let nib    = UINib(nibName: "UnConfirmedDuelSender", bundle: bundle)
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
    challengeObject = json

    let gradient:CAGradientLayer = CAGradientLayer()
    let frame                    = CGRect(x: 0, y:0, width: self.frame.size.width, height: topBarBackground.frame.size.height)
    gradient.frame               = frame
    gradient.colors              = [CHGradients().thirdTopBarColor, CHGradients().secondTopBarColor, CHGradients().firstTopBarColor]
    gradient.opacity = 0.8
    
    self.topBarBackground.layer.addSublayer(gradient)
    self.bringSubview(toFront: self.topBarBackground)
    self.recipientImage.layer.masksToBounds = true
    self.topBarBackground.bringSubview(toFront: duelIcon)
    self.topBarBackground.bringSubview(toFront: duelLabel)
    
    var changed = false
    if json["challenge"]["name"].stringValue.contains("a books") {
      challengeDescriptionLabel.text = "Reading Books"
      changed = true
    }
    
    if json["challenge"]["name"].stringValue.contains("Taking stares") {
      challengeDescriptionLabel.text = "Taking Stairs"
      changed = true
    }
    
    if !changed {
      challengeDescriptionLabel.text = json["challenge"]["name"].stringValue
    }
//    challengeDescriptionLabel.text = json["challenge"]["description"].stringValue
    statsLabel.text = "Level 1 Champy / Reward +\(json["challenge"]["points"].stringValue) "
    
    let days = Int(CHSettings().secToDays(json["challenge"]["duration"].intValue))
    var day = "days"
    
      if days == 1 {
      day = "day"
    }
    
    if json["challenge"]["description"].stringValue == "customStepCountingDuel" {
      self.challengeDescriptionLabel.text = "\(challengeObject["challenge"]["name"].stringValue) every day \(challengeObject["challenge"]["details"].stringValue) steps"
    }
    
    self.daysLabel.text = "\(days) \(day)"
    
    switch  CHSession().currentUserId {
    case json["sender"]["_id"].stringValue:
      self.duelLabel.text = "New challenge to \(json["recipient"]["name"].stringValue)"
      CHImages().setImageForFriend(json["recipient"]["_id"].stringValue, imageView: self.recipientImage)
      break
    case json["recipient"]["_id"].stringValue:
      self.duelLabel.text = "New challenge to \(json["sender"]["name"].stringValue)"
      CHImages().setImageForFriend(json["sender"]["_id"].stringValue, imageView: self.recipientImage)
      break
    default:
      self.duelLabel.text = "New challenge"
    }
    
    
  }
  
  @IBAction func cancelrequestAction(_ sender: Any) {
    
    
    
  }
  @IBAction func cancelRequest2Action(_ sender: Any) {
    let alert = UIAlertController(title: "Warning", message: "Are You Sure?", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in
      CHRequests().rejectInvite(self.challengeObject["_id"].stringValue) { (result, json) in
        if result {
          CHPush().localPush("refreshIcarousel", object: self)
        } else {
          CHPush().alertPush(json["error"].stringValue, type: "Warning")
        }
      }
    }))
    
    alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
    if let topController = UIApplication.topViewController() {
      topController.present(alert, animated: true, completion: nil)
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