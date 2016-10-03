//
//  SelfImprovementDone.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/2/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON

@IBDesignable class SelfImprovementDone: UIView {

  var view: UIView!
  var objectChallenge:JSON = nil
  
  @IBOutlet weak var topBarBackground: UIView!
  @IBOutlet weak var selfImprovementUpIcon: UIImageView!
  @IBOutlet weak var selfImprovementLabel: UILabel!
  @IBOutlet weak var reminingDays: UILabel!
  @IBOutlet weak var challenge: UILabel!
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
    let nib    = UINib(nibName: "SelfImprovementDone", bundle: bundle)
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
    if object != nil {
      self.objectChallenge = object
      self.challenge.text = object["challenge"]["name"].stringValue
      
      let originalDays = CHSettings().secToDays(object["challenge"]["duration"].intValue)
      let passedDays = object["senderProgress"].count
      
      var day:String = "days"
      if originalDays - passedDays == 1 {
        day = "day"
      }
      self.reminingDays.text = "\(originalDays - passedDays) \(day) to go"
      self.reminingDays.adjustsFontSizeToFitWidth = true
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  @IBAction func shareAction(sender: AnyObject) {
    let textToShare = "Constantly improving myself with Champy. Self-Improvement challenge “\(self.objectChallenge["challenge"]["name"].stringValue)”"
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
  
  
  @IBAction func surrenderAction(sender: AnyObject) {
    
    guard !tapped else {
      return
    }
    
    let button = sender as! UIButton
    
    tapped = true
    button.hidden = tapped
    
    
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
