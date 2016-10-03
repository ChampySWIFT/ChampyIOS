//
//  SelfImprovementInProgress.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/2/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
@IBDesignable class SelfImprovementInProgress: UIView {

  var view: UIView!
  
  @IBOutlet weak var topBarBackground: UIView!
  @IBOutlet weak var selfImprovementUpIcon: UIImageView!
  @IBOutlet weak var selfImprovementLabel: UILabel!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var doneForToday: UILabel!
  @IBOutlet weak var revardLabel: UILabel!
  
  var objectChallenge:JSON! = nil
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
    let bundle = NSBundle(forClass: type(of: self))
    let nib    = UINib(nibName: "SelfImprovementInProgress", bundle: bundle)
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
  
  func setUp(object:JSON = nil){
    let gradient:CAGradientLayer = CAGradientLayer()
    let frame                    = CGRect(x: 0, y:0, width: self.frame.size.width, height: topBarBackground.frame.size.height)
    gradient.frame               = frame
    gradient.colors              = [CHGradients().thirdTopBarColor, CHGradients().secondTopBarColor, CHGradients().firstTopBarColor]//Or any colors
    self.topBarBackground.layer.addSublayer(gradient)
    self.bringSubviewToFront(self.topBarBackground)
    self.topBarBackground.bringSubviewToFront(selfImprovementUpIcon)
    self.topBarBackground.bringSubviewToFront(selfImprovementLabel)
    self.doneForToday.adjustsFontSizeToFitWidth = true
    if object != nil {
      self.objectChallenge = object
      self.descLabel.text = object["challenge"]["name"].stringValue
    }
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }

  @IBAction func acceptAction(sender: AnyObject) {
    guard !tapped else {
      return
    }
    let button = sender as! UIButton
    
    tapped = true
    button.hidden = self.tapped
    
    CHRequests().checkChallenge(self.objectChallenge["_id"].stringValue) { (result, json) in
      if result {
        self.tapped = false
//        button.hidden = self.tapped
        CHPush().localPush("refreshIcarousel", object: [])
//        CHPush().alertPush("Confirmed", type: "Success")
      } else {
        self.tapped = false
        button.hidden = self.tapped
        CHPush().alertPush(json["error"].stringValue, type: "Warning")
      }
    }
  }
  
  @IBAction func failAction(sender: AnyObject) {
    guard !tapped else {
      return
    }
    
    let button = sender as! UIButton
    tapped = true
    button.hidden = self.tapped
    
    CHRequests().surrender(self.objectChallenge["_id"].stringValue) { (result, json) in
      if result {
        self.tapped = false
//        button.hidden = self.tapped
        CHPush().localPush("refreshIcarousel", object: [])
//        CHPush().alertPush("You are a looser", type: "Success")
      } else {
        self.tapped = false
        button.hidden = self.tapped
        CHPush().alertPush(json["error"].stringValue, type: "Warning")
      }
    }
  }
  
}
