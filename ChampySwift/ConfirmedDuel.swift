//
//  ConfirmedDuel.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/19/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Async

@IBDesignable class ConfirmedDuel: UIView {
  var view: UIView!
  var tapped = false
  @IBOutlet weak var topBarBackground: UIView!
  @IBOutlet weak var duelIcon: UIImageView!
  @IBOutlet weak var duelLabel: UILabel!
  @IBOutlet weak var recipientImage: UIImageView!
  @IBOutlet weak var sendertImage: UIImageView!
  
  @IBOutlet weak var challengeDescriptionLabel: UILabel!
  
  @IBOutlet weak var statsLabel: UILabel!
  
  @IBOutlet weak var daysLabel: UILabel!
  
  @IBOutlet weak var declineIcon: UIBarButtonItem!
  @IBOutlet weak var acceptIcon: UIBarButtonItem!
  var opponentId: String = ""
  
  var challengeObject: JSON! = nil
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
    let nib    = UINib(nibName: "ConfirmedDuel", bundle: bundle)
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
  
  func updatePhotoOnCards() {
    switch  CHSession().currentUserId {
    case challengeObject["sender"]["_id"].stringValue:
      CHImages().setImageForFriend(CHSession().currentUserId, imageView: self.sendertImage)
      break
    case challengeObject["recipient"]["_id"].stringValue:
      CHImages().setImageForFriend(CHSession().currentUserId, imageView: self.recipientImage)
      break
    default:
      self.duelLabel.text = "New challenge"
    }
  }
  
  func setUp(_ json:JSON = nil){
    NotificationCenter.default.addObserver(self, selector: #selector(ConfirmedDuel.updatePhotoOnCards), name: NSNotification.Name(rawValue: "updatePhotoOnCards"), object: nil)
    
    challengeObject = json
    let gradient:CAGradientLayer = CAGradientLayer()
    let frame                    = CGRect(x: 0, y:0, width: self.frame.size.width, height: 80.0)
    gradient.frame               = frame
    
    gradient.colors              = [CHGradients().thirdTopBarColor, CHGradients().secondTopBarColor, CHGradients().firstTopBarColor]
    gradient.opacity = 0.8
    //Or any colors
    self.topBarBackground.layer.addSublayer(gradient)
    self.bringSubview(toFront: self.topBarBackground)
    //    recipientImage
    //    self.recipientImage.layer.opacity = 0.5
    self.sendertImage.layer.masksToBounds = true
    self.recipientImage.layer.masksToBounds = true
    //    self.topBarBackground.bringSubviewToFront(recipientImage)
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
    
//    self.daysLabel.text = "\(Int(CHSettings().secToDays(json["challenge"]["duration"].intValue))) days"
    
    switch  CHSession().currentUserId {
    case json["sender"]["_id"].stringValue:
      self.duelLabel.text = "Duel with \(json["recipient"]["name"].stringValue)"
      CHImages().setImageForFriend(json["recipient"]["_id"].stringValue, imageView: self.recipientImage)
      opponentId = json["recipient"]["_id"].stringValue
      CHImages().setImageForFriend(json["sender"]["_id"].stringValue, imageView: self.sendertImage)
      break
    case json["recipient"]["_id"].stringValue:
      self.duelLabel.text = "Duel with \(json["sender"]["name"].stringValue)"
      CHImages().setImageForFriend(json["sender"]["_id"].stringValue, imageView: self.sendertImage)
      opponentId = json["sender"]["_id"].stringValue
      CHImages().setImageForFriend(json["recipient"]["_id"].stringValue, imageView: self.recipientImage)
      break
    default:
      self.duelLabel.text = "Duel"
    }
    
    self.daysLabel.adjustsFontSizeToFitWidth = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  @IBAction func acceptAction(_ sender: AnyObject) {
    guard !tapped else {
      return
    }
    
    let button = sender as! UIButton
    
    tapped = true
    button.isHidden = self.tapped
    
    CHRequests().checkChallenge(self.challengeObject["_id"].stringValue) { (result, json) in
      if result {
        self.tapped = false
        CHPush().localPush("refreshIcarousel", object: self)
        CHPush().sendPushToUser(self.opponentId, message: "\(CHSession().currentUserName) has done his challenge for today", options: "")
//        CHPush().alertPush("Done For today", type: "Success")
      } else {
        self.tapped = false
        button.isHidden = self.tapped
        CHPush().alertPush(json["error"].stringValue, type: "Warning")
      }
    }
    
  }
  @IBAction func declineAction(_ sender: AnyObject) {
    guard !tapped else {
      return
    }
    
    let button = sender as! UIButton
    
    tapped = true
    button.isHidden = self.tapped
    
    CHRequests().surrender(self.challengeObject["_id"].stringValue) { (result, json) in
      if result {
        self.tapped = false
        CHPush().localPush("refreshIcarousel", object: self)
        CHPush().sendPushToUser(self.opponentId, message: "\(CHSession().currentUserName) has failed the duel", options: "")
//        CHPush().alertPush("You are a LOOSER", type: "Success")
      } else {
        self.tapped = false
        button.isHidden = self.tapped
        CHPush().alertPush(json["error"].stringValue, type: "Warning")
      }
    }
    
  }
}
