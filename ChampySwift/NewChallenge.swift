//
//  NewChallenge.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/17/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Async
@IBDesignable class NewChallenge: UIView, UITextFieldDelegate {

  var view: UIView!
  
  
  @IBOutlet weak var ConditionsTextField: UITextField!
  @IBOutlet weak var daysTextField: UILabel!
  @IBOutlet weak var pointsLabel: UILabel!
  @IBOutlet weak var levelLabel: UILabel!
  @IBOutlet weak var rewardLabel: UILabel!
  
  var selectedTitle:String = ""
  var selectedDayCount:Int = 21
  let notifCenter = NotificationCenter.default
  
  
  func setUp(_ object:JSON, empty:Bool = false){
    notifCenter.addObserver(self, selector: #selector(NewChallenge.dismissKeyboard), name: NSNotification.Name(rawValue: "dismissKeyboard"), object: nil)
    self.ConditionsTextField.text = ""
    self.daysTextField.text = "21 Days"
    ConditionsTextField.delegate = self
    
    
    if !empty {
     
      pointsLabel.text = object["points"].stringValue
      pointsLabel.adjustsFontSizeToFitWidth = true
      
      ConditionsTextField.text = object["name"].stringValue
      ConditionsTextField.adjustsFontSizeToFitWidth = true
      
      rewardLabel.text = "Reward +\(object["points"].stringValue) points"
      
     
      ConditionsTextField.isUserInteractionEnabled = false
      
      self.plusOneDay.isHidden = true
      self.minusOneDay.isHidden = true
      
      self.daysTextField.text = "\(Int(CHSettings().secToDays(object["duration"].intValue))) Days"
      
    } else {
      pointsLabel.text = "10"
      pointsLabel.adjustsFontSizeToFitWidth = true
      
      ConditionsTextField.placeholder = "Type Your Challenge Name"
      ConditionsTextField.adjustsFontSizeToFitWidth = true
      ConditionsTextField.isUserInteractionEnabled = true
      rewardLabel.text = "Reward +10 points"
      
    }
    
    setUpToolbar()
  }
  
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
    let nib    = UINib(nibName: "NewChallenge", bundle: bundle)
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
  
  
  @IBOutlet weak var plusOneDay: UIButton!
  @IBOutlet weak var minusOneDay: UIButton!
  
  @IBAction func plusOneDayAction(_ sender: AnyObject) {
    var days:String = (daysTextField.text?.replacingOccurrences(of: " Days", with: ""))!
    days = (days.replacingOccurrences(of: " Day", with: ""))

    let currentValue:Int = Int(days)!
    if currentValue == 100 {
      return
    }

    let newValue = currentValue + 1

    if newValue == 1 {
      daysTextField.text = "\(newValue) Day"
    } else {
      daysTextField.text = "\(newValue) Days"
    }
    
    daysTextField.adjustsFontSizeToFitWidth = true

  }
  
  @IBAction func minusOneDayAction(_ sender: AnyObject) {
    var days:String = (daysTextField.text?.replacingOccurrences(of: " Days", with: ""))!
    days = (days.replacingOccurrences(of: " Day", with: ""))

    let currentValue:Int = Int(days)!
    if currentValue == 1 {
      return
    }

    let newValue = currentValue - 1

    if newValue == 1 {
      daysTextField.text = "\(newValue) Day"
    } else {
      daysTextField.text = "\(newValue) Days"
    }
    
    daysTextField.adjustsFontSizeToFitWidth = true

  }
  
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == self.ConditionsTextField {
      self.view.bringSubview(toFront: self.ConditionsTextField)
      var frame = self.view.superview?.superview!.superview!.superview!.frame
      frame!.origin.y = frame!.origin.y - 150
      
      UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
        self.view.superview?.superview!.superview!.superview!.frame = frame!
        }, completion: { finished in
      })
    }
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    if textField == self.ConditionsTextField {
      var frame = self.view.superview?.superview!.superview!.superview!.frame
      frame!.origin.y = frame!.origin.y + 150
      UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
        self.view.superview?.superview!.superview!.superview!.frame = frame!
        }, completion: { finished in
      })
    }
    textField.resignFirstResponder()
  }
  
  func setUpToolbar() {
    let spaceButton     = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    
    let toolBar                             = UIToolbar(frame: CGRect(x: 0,y: -44,width: 320,height: 44))
    toolBar.barStyle                        = UIBarStyle.default
    let barButtonDone                       = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(NewChallenge.Save))
    barButtonDone.tintColor = CHUIElements().APPColors["navigationBar"]
    let barButtonCancel                     = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NewChallenge.dismissKeyboard))
    barButtonCancel.tintColor = CHUIElements().APPColors["navigationBar"]
    toolBar.items                           = [barButtonCancel, spaceButton, barButtonDone]
    self.ConditionsTextField.inputAccessoryView = toolBar
  }
  
  
  func Save() {
    
    var enteredText:String = ConditionsTextField.text!
    enteredText = enteredText.condenseWhitespace()
    enteredText = enteredText.trimmingCharacters(
      in: CharacterSet.whitespacesAndNewlines
    )
    
    
    guard enteredText != "" else {
      alertWithMessage("Name should not be blank", type: .Warning)
//      CHPush().alertPush("Name should not be blank", type: "Warning")
      return
    }
    if Int(enteredText) != nil  {
      alertWithMessage("Wrong symbols", type: .Warning)
//      CHPush().alertPush("Wrong symbols", type: "Warning")
      return
    }
    
    if !enteredText.isChallengeName() {
      alertWithMessage("Wrong symbols", type: .Warning)
//      CHPush().alertPush("Wrong symbols", type: "Warning")
      return
    }
    
    if enteredText.characters.count > 40 {
      alertWithMessage("Entered Name is too long", type: .Warning)
//      CHPush().alertPush("Entered name is too long", type: "Warning")
      return
    }
    
    if ConditionsTextField.text!.isValidConditions() {
      self.selectedTitle = ConditionsTextField.text!
    } else {
      alertWithMessage("Wrong name format", type: .Warning)
//      CHPush().alertPush("Wrong name format", type: "Warning")
    }
    
    var days:String = self.daysTextField.text!.replacingOccurrences(of: " Days", with: "")
    days = days.replacingOccurrences(of: " Day", with: "")
    
    
    let num = Int(days)
    if num != nil {
      self.selectedDayCount = Int(days)!
    } else {
      self.selectedDayCount = 21
      daysTextField.text = "21 Days"
      alertWithMessage("Wrong day format", type: .Warning)
//      CHPush().alertPush("Wrong day format", type: "Warning")
    }
   
    hideKeyboard()
  }
  
  func hideKeyboard() {
    self.view.endEditing(true)
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
    return true
  }
  
  func dismissKeyboard() {
    if self.ConditionsTextField != nil {
    self.ConditionsTextField.resignFirstResponder()
      view.endEditing(true)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  func alertWithMessage(_ message:String, type:CHBanners.CHBannerTypes) {
    Async.main {
      let banner = CHBanners(withTarget: self.view, andType: type)
      banner.showBannerForViewControllerAnimated(true, message: message)
    }
  }

}
