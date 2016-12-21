//
//  UnConfirmedDuel.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/17/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable class UnConfirmedDuel: UIView {

  var view: UIView!
  var tapped = false
  @IBOutlet weak var topBarBackground: UIView!
  @IBOutlet weak var duelIcon: UIImageView!
  @IBOutlet weak var duelLabel: UILabel!
  @IBOutlet weak var recipientImage: UIImageView!
  
  @IBOutlet weak var challengeDescriptionLabel: UILabel!
  
  @IBOutlet weak var statsLabel: UILabel!
  
  @IBOutlet weak var daysLabel: UILabel!
  
  @IBOutlet weak var declineIcon: UIBarButtonItem!
  @IBOutlet weak var historyIcon: UIBarButtonItem!
  @IBOutlet weak var acceptIcon: UIBarButtonItem!
  var challengeObject: JSON! = nil
  var opponentId: String = ""
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
    let nib    = UINib(nibName: "UnConfirmedDuel", bundle: bundle)
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
  //updatePhotoOnCards
  
  
  
  func setUp(_ json:JSON = nil){
    challengeObject = json
    let gradient:CAGradientLayer = CAGradientLayer()
    let frame                    = CGRect(x: 0, y:0, width: self.frame.size.width, height: topBarBackground.frame.size.height)
    gradient.frame               = frame
    
    gradient.colors              = [CHGradients().thirdTopBarColor, CHGradients().secondTopBarColor, CHGradients().firstTopBarColor]
    gradient.opacity = 0.8
    //Or any colors
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
    
    self.daysLabel.text = "\(days) \(day)"
    
    switch  CHSession().currentUserId {
    case json["sender"]["_id"].stringValue:
      self.duelLabel.text = "New challenge from \(json["recipient"]["name"].stringValue)"
      opponentId = json["recipient"]["_id"].stringValue
      CHImages().setImageForFriend(json["recipient"]["_id"].stringValue, imageView: self.recipientImage)
      break
    case json["recipient"]["_id"].stringValue:
      self.duelLabel.text = "New challenge from \(json["sender"]["name"].stringValue)"
      opponentId = json["sender"]["_id"].stringValue
      CHImages().setImageForFriend(json["sender"]["_id"].stringValue, imageView: self.recipientImage)
      break
    default:
      self.duelLabel.text = "New challenge"
    }
    
    
  }
  
  func refreshImage() {
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }

  @IBAction func historyAction(_ sender: AnyObject) {
    guard !tapped else {
      return
    }
    
    tapped = true
    
    UIApplication.topViewController()!.navigationController?.performSegue(withIdentifier: "toHistory", sender: self)
    tapped = false
  }
  
  
  @IBAction func acceptAction(_ sender: AnyObject) {
    guard !tapped else {
      return
    }
    
    let button = sender as! UIButton
    
    tapped = true
    button.isHidden = self.tapped
    
    CHRequests().joinToChallenge(self.challengeObject["_id"].stringValue) { (result, json) in
      if result {
        self.tapped = false
        CHPush().localPush("refreshIcarousel", object: self)
        CHPush().sendPushToUser(self.opponentId, message: "\(CHSession().currentUserName) has joined your challenge", options: "")
//        CHPush().alertPush("Accepted", type: "Success")
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
    
    CHRequests().rejectInvite(self.challengeObject["_id"].stringValue) { (result, json) in
      if result {
        self.tapped = false
        CHPush().localPush("refreshIcarousel", object: self)
        CHPush().sendPushToUser(self.opponentId, message: "\(CHSession().currentUserName) has declined your challenge", options: "")
//        CHPush().alertPush("Rejected", type: "Success")
      } else {
        self.tapped = false
        button.isHidden = self.tapped
        CHPush().alertPush(json["error"].stringValue, type: "Warning")
      }
    }
    
  }
 
}
