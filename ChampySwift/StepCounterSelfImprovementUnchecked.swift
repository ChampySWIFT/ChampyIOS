//
//  StepCounterSelfImprovementUnchecked.swift
//  Champy
//
//  Created by Azinec Development on 1/5/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
@IBDesignable class StepCounterSelfImprovementUnchecked: UIView {

  var view: UIView!
  
  @IBOutlet weak var topBarBackground: UIView!
  @IBOutlet weak var selfImprovementUpIcon: UIImageView!
  @IBOutlet weak var selfImprovementLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var doneForToday: UILabel!
  @IBOutlet weak var revardLabel: UILabel!
  @IBOutlet weak var statsLabel: UILabel!
  
  var objectChallenge:JSON! = nil
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
    let nib    = UINib(nibName: "StepCounterSelfImprovementUnchecked", bundle: bundle)
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
  
  func updateStepsOnCards() {
    var stepCount:Int = 0
    if  UserDefaults.standard.value(forKey: "todaysStepCount") != nil {
      stepCount = UserDefaults.standard.value(forKey: "todaysStepCount") as! Int
    }
    self.statsLabel.text = "\(stepCount) steps from \(objectChallenge["challenge"]["details"].stringValue)"
    
  }
  
  
  func setUp(_ object:JSON = nil){
    NotificationCenter.default.addObserver(self, selector: #selector(self.updateStepsOnCards), name: NSNotification.Name(rawValue: "updateStepsOnCards"), object: nil)
    let gradient:CAGradientLayer = CAGradientLayer()
    let frame                    = CGRect(x: 0, y:0, width: self.frame.size.width, height: topBarBackground.frame.size.height)
    gradient.frame               = frame
    gradient.colors              = [CHGradients().thirdTopBarColor, CHGradients().secondTopBarColor, CHGradients().firstTopBarColor]//Or any colors
    self.topBarBackground.layer.addSublayer(gradient)
    self.bringSubview(toFront: self.topBarBackground)
    self.topBarBackground.bringSubview(toFront: selfImprovementUpIcon)
    self.topBarBackground.bringSubview(toFront: selfImprovementLabel)
    self.doneForToday.adjustsFontSizeToFitWidth = true
    if object != nil {
      self.objectChallenge = object
      var stepCount:Int = 0
      if  UserDefaults.standard.value(forKey: "todaysStepCount") != nil {
        stepCount = UserDefaults.standard.value(forKey: "todaysStepCount") as! Int
      }
      self.descLabel.text = "\(object["challenge"]["name"].stringValue) every day \(object["challenge"]["details"].stringValue) steps"
      self.statsLabel.text = "\(stepCount) steps from \(object["challenge"]["details"].stringValue)"
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
    let stepCount:Int = UserDefaults.standard.value(forKey: "todaysStepCount") as! Int
    let destination = self.objectChallenge["challenge"]["details"].intValue
    
    if stepCount < destination {
      CHPush().alertPush("you still need some steps to make this challenge done", type: "Warning")
      return
    }
    
    guard !tapped else {
      return
    }
    let button = sender as! UIButton
    
    tapped = true
    button.isHidden = self.tapped
    
    CHRequests().checkChallenge(self.objectChallenge["_id"].stringValue) { (result, json) in
      if result {
        self.tapped = false
        //        button.hidden = self.tapped
        CHPush().localPush("refreshIcarousel", object: self)
        //        CHPush().alertPush("Confirmed", type: "Success")
      } else {
        self.tapped = false
        button.isHidden = self.tapped
        CHPush().alertPush(json["error"].stringValue, type: "Warning")
      }
    }
  }
  
  @IBAction func failAction(_ sender: AnyObject) {
    guard !tapped else {
      return
    }
    
    let button = sender as! UIButton
    tapped = true
    button.isHidden = self.tapped
    
    CHRequests().surrender(self.objectChallenge["_id"].stringValue) { (result, json) in
      if result {
        self.tapped = false
        //        button.hidden = self.tapped
        CHPush().localPush("refreshIcarousel", object: self)
        //        CHPush().alertPush("You are a looser", type: "Success")
      } else {
        self.tapped = false
        button.isHidden = self.tapped
        CHPush().alertPush(json["error"].stringValue, type: "Warning")
      }
    }
  }

}
