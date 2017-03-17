//
//  StepCounterDuelUnchecked.swift
//  Champy
//
//  Created by Azinec Development on 1/5/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import SwiftyJSON
class StepCounterDuelUnchecked: UIView {

  var view: UIView!
  var tapped = false
  @IBOutlet weak var topBarBackground: UIView!
  @IBOutlet weak var duelIcon: UIImageView!
  @IBOutlet weak var duelLabel: UILabel!
  @IBOutlet weak var recipientImage: UIImageView!
  @IBOutlet weak var sendertImage: UIImageView!
  
  @IBOutlet weak var challengeDescriptionLabel: UILabel!
  
  @IBOutlet weak var statsLabel: UILabel!
  
  @IBOutlet weak var recipientStepCounter: UILabel!
  @IBOutlet weak var recipientName: UILabel!
  @IBOutlet weak var senderName: UILabel!
  @IBOutlet weak var sendersStepCounter: UILabel!
  @IBOutlet weak var doneForTodayLabel: UILabel!
  
  @IBOutlet weak var declineIcon: UIBarButtonItem!
  @IBOutlet weak var acceptIcon: UIBarButtonItem!
  var opponentId: String = ""
  
  @IBOutlet weak var topBarHeightConstrait: NSLayoutConstraint!
  @IBOutlet weak var doneForTodayHeightConstrait: NSLayoutConstraint!
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
    let nib    = UINib(nibName: "StepCounterDuelUnchecked", bundle: bundle)
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
    if DeviceType.IS_IPHONE_5 {
      self.topBarHeightConstrait.constant = 80.0
      self.doneForTodayHeightConstrait.constant = 0
//      self.doneForTodayLabel.adjustsFontForContentSizeCategory = true
    }
    
    
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
  
  func updateStepsOnCards() {
    Async.main {
      self.setUpStepCounter()
    }
    
  }
  
  func setUp(_ json:JSON = nil){
    NotificationCenter.default.addObserver(self, selector: #selector(self.updatePhotoOnCards), name: NSNotification.Name(rawValue: "updatePhotoOnCards"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.updateStepsOnCards), name: NSNotification.Name(rawValue: "updateStepsOnCards"), object: nil)
    
    challengeObject = json
    let gradient:CAGradientLayer = CAGradientLayer()
    let frame                    = CGRect(x: 0, y:0, width: self.frame.size.width, height: self.topBarHeightConstrait.constant)
    gradient.frame               = frame
    
    gradient.colors              = [CHGradients().thirdTopBarColor, CHGradients().secondTopBarColor, CHGradients().firstTopBarColor]
    gradient.opacity = 0.8
    //Or any colors
    self.topBarBackground.layer.addSublayer(gradient)
    self.bringSubview(toFront: self.topBarBackground)
    self.sendertImage.layer.masksToBounds = true
    self.recipientImage.layer.masksToBounds = true
    self.topBarBackground.bringSubview(toFront: duelIcon)
    self.topBarBackground.bringSubview(toFront: duelLabel)
    
    
  
    
    self.challengeDescriptionLabel.text = "\(challengeObject["challenge"]["name"].stringValue) every day \(challengeObject["challenge"]["details"].stringValue) steps"
    self.challengeDescriptionLabel.adjustsFontSizeToFitWidth = true
//    self.statsLabel.text = "\(stepCount) steps from \(challengeObject["challenge"]["details"].stringValue)"
    
    self.statsLabel.text = "Today: "
    
    self.senderName.adjustsFontSizeToFitWidth = true
    self.recipientName.adjustsFontSizeToFitWidth = true
    self.sendersStepCounter.adjustsFontSizeToFitWidth = true
    self.recipientStepCounter.adjustsFontSizeToFitWidth = true
    
    switch  CHSession().currentUserId {
    case json["sender"]["_id"].stringValue:
      self.duelLabel.text = "Duel with \(json["recipient"]["name"].stringValue)"
      CHImages().setImageForFriend(json["recipient"]["_id"].stringValue, imageView: self.recipientImage)
      opponentId = json["recipient"]["_id"].stringValue
      
      self.recipientName.text = json["sender"]["name"].stringValue
      self.senderName.text = json["recipient"]["name"].stringValue
      
      CHImages().setImageForFriend(json["sender"]["_id"].stringValue, imageView: self.sendertImage)
      
      
      
      break
    case json["recipient"]["_id"].stringValue:
      self.duelLabel.text = "Duel with \(json["sender"]["name"].stringValue)"
      CHImages().setImageForFriend(json["sender"]["_id"].stringValue, imageView: self.sendertImage)
      opponentId = json["sender"]["_id"].stringValue
      self.senderName.text = json["sender"]["name"].stringValue
      self.recipientName.text = json["recipient"]["name"].stringValue
      
      CHImages().setImageForFriend(json["recipient"]["_id"].stringValue, imageView: self.recipientImage)
      break
    default:
      self.duelLabel.text = "Duel"
    }
    
    setUpStepCounter()
  }
  
  
  func setUpStepCounter() {
    self.autoCheckIfitisPossible()
    var mystepCount:Int = 0
    if  UserDefaults.standard.value(forKey: "todaysStepCount") != nil {
      mystepCount = UserDefaults.standard.value(forKey: "todaysStepCount") as! Int
    }
    
    switch  CHSession().currentUserId {
    case challengeObject["sender"]["_id"].stringValue:
      let opponentsStepCount = challengeObject["recipient"]["stepCount"].intValue
      
      self.senderName.text = challengeObject["recipient"]["name"].stringValue
      self.recipientName.text = challengeObject["sender"]["name"].stringValue
      
      self.recipientStepCounter.text = "\(mystepCount)"
      self.sendersStepCounter.text = "\(opponentsStepCount)"
      
      break
    case challengeObject["recipient"]["_id"].stringValue:
      let opponentsStepCount = challengeObject["sender"]["stepCount"].intValue
      
      self.senderName.text = challengeObject["recipient"]["name"].stringValue
      self.recipientName.text = challengeObject["sender"]["name"].stringValue
      
      self.recipientStepCounter.text = "\(opponentsStepCount)"
      self.sendersStepCounter.text = "\(mystepCount)"
      
      break
    default:
      self.duelLabel.text = "Duel"
    }
    
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
    
    var stepCount:Int = 0
    if  UserDefaults.standard.value(forKey: "todaysStepCount") != nil {
      stepCount = UserDefaults.standard.value(forKey: "todaysStepCount") as! Int
    }
    let destination = challengeObject["challenge"]["details"].intValue
    if stepCount < destination {
      CHPush().alertPush("you still need some steps to make this challenge done", type: "Warning")
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
  
  func autoCheckIfitisPossible() {
    var stepCount:Int = 0
    if  UserDefaults.standard.value(forKey: "todaysStepCount") != nil {
      stepCount = UserDefaults.standard.value(forKey: "todaysStepCount") as! Int
    }
    let destination = challengeObject["challenge"]["details"].intValue
    if stepCount < destination {
      return
    }
    
    CHRequests().checkChallenge(self.challengeObject["_id"].stringValue) { (result, json) in
      if result {
        self.tapped = false
        CHPush().localPush("refreshIcarousel", object: self)
      }
    }
  }
  
}
