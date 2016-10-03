//
//  WakeUpViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/18/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import SwiftyJSON

class WakeUpViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
  
  
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var descView: UIView!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var acceptButton: UIButton!
  @IBOutlet weak var declineButton: UIButton!
  @IBOutlet weak var plusOneDay: UIButton!
  @IBOutlet weak var minusOneDay: UIButton!
  @IBOutlet weak var minusTime: UIButton!
  @IBOutlet weak var plusTime: UIButton!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var timeField: UITextField!
  var datePicker:UIDatePicker! = nil
  var dateInt:Int = 0
  var initialTime = 21600
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    datePicker = UIDatePicker() // Although you probably have an IBOutlet
    datePicker.datePickerMode = UIDatePickerMode.Time
    datePicker.backgroundColor = UIColor.lightGrayColor()
    datePicker.tintColor = CHUIElements().APPColors["navigationBar"]
    
    let curredntDateInSec = CHUIElements().getCurretnTime()
    
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Hour, .Minute, .Second], fromDate: NSDate(timeIntervalSince1970: Double(curredntDateInSec)))
    let hour = comp.hour
    let minute = comp.minute
    
    let newTime = (curredntDateInSec - (hour * 60 * 60) - (minute * 60) - comp.second)  + (30 * 60 * 60)
    self.dateInt = newTime
    let dateFormatter = NSDateFormatter()
    
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    dateFormatter.dateFormat = "hh:mm a"
    
    let date = NSDate(timeIntervalSince1970: Double(newTime))
    let strDate = dateFormatter.stringFromDate(date)
    
    
    self.timeField.text = strDate
    self.timeField.resignFirstResponder()
    
    
    
//    datePicker.addTarget(self, action: #selector(WakeUpViewController.valueChangedInDateField(_:)), forControlEvents: .ValueChanged)
    
    
    let spaceButton     = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    
    let toolBar                             = UIToolbar(frame: CGRectMake(0,0,self.view.frame.size.width,44))
    toolBar.barStyle                        = UIBarStyle.Default
    let barButtonDone                       = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(WakeUpViewController.valueChangedInDateField))
    barButtonDone.tintColor = CHUIElements().APPColors["navigationBar"]
    toolBar.items                           = [spaceButton, barButtonDone]
//    self.timeField.inputAccessoryView = toolBar
    
    timeField.inputAccessoryView = toolBar;
    timeField.inputView = datePicker;
    timeField.delegate  = self
//    datePicker.addSubview()
//    timeField.inputView =
    
    // Do any additional setup after loading the view.
  }
  
  func valueChangedInDateField(sender:AnyObject) {
    let dateFormatter = NSDateFormatter()
    
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    dateFormatter.dateFormat = "hh:mm a"
    let strDate = dateFormatter.stringFromDate(datePicker.date)
    
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Hour, .Minute, .Second], fromDate: datePicker.date)
    let hour = comp.hour
    let minute = comp.minute
    
    self.timeField.text = strDate
    self.timeField.resignFirstResponder()
    
    self.dateInt = Int(datePicker.date.timeIntervalSince1970) - comp.second
    
    if dateInt <= CHUIElements().getCurretnTime() {
      dateInt = dateInt + CHSettings().daysToSec(1)
    }
    
  }
  
  @IBAction func closeView(sender: AnyObject) {
    self.dismissViewControllerAnimated(true) { 
      CHPush().localPush("refreshIcarousel", object: [])
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func plusOneDayAction(sender: AnyObject) {
    var days:String = (dayLabel.text?.stringByReplacingOccurrencesOfString(" Days", withString: ""))!
    days = (days.stringByReplacingOccurrencesOfString(" Day", withString: ""))
    
    let currentValue:Int = Int(days)!
    if currentValue == 100 {
      return
    }
    
    let newValue = currentValue + 1
    
    if newValue == 1 {
      dayLabel.text = "\(newValue) Day"
    } else {
      dayLabel.text = "\(newValue) Days"
    }
    
   dayLabel.adjustsFontSizeToFitWidth = true
  }
  
  @IBAction func minusOneDayAction(sender: AnyObject) {
    var days:String = (dayLabel.text?.stringByReplacingOccurrencesOfString(" Days", withString: ""))!
    days = (days.stringByReplacingOccurrencesOfString(" Day", withString: ""))
    
    let currentValue:Int = Int(days)!
    if currentValue == 1 {
      return
    }
    
    let newValue = currentValue - 1
    
    if newValue == 1 {
      dayLabel.text = "\(newValue) Day"
    } else {
      dayLabel.text = "\(newValue) Days"
    }
    dayLabel.adjustsFontSizeToFitWidth = true
    
  }
  
  @IBAction func plusTimeAction(sender: AnyObject) {
  }
  
  @IBAction func minusTimeAction(sender: AnyObject) {
    
  }
  
  
  
  
  
  
  func sendAction() {
    var days:String = (dayLabel.text?.stringByReplacingOccurrencesOfString(" Days", withString: ""))!
    days = (days.stringByReplacingOccurrencesOfString(" Day", withString: ""))
    
    let currentValue:Int = Int(days)!
    
    let duration = CHSettings().daysToSec(currentValue)
    
    
    var array:[Int] = []
    
    for i:Int in 0...currentValue {
      array.append(self.dateInt + CHSettings().daysToSec(i))
    }
    
    ////print(array)
    
    let params:[String:String] = [
      "name": "Wake Up At \(timeField.text! as String)",
      "type": CHSettings().self.wakeUpIds,
      "description": "Wake Up At \(timeField.text! as String)",
      "details": "\(array)",
      "duration": "\(duration)"
    ]
    
    CHRequests().createSelfImprovementChallengeAndSendIt(params, completitionHandler: { (json, status) in
      self.finisher(status)
    })
    
  }
  
  
  func finisher(result:Bool) {
    if result {
      CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
        if result {
          CHWakeUpper().setUpWakeUp()
          self.alertWithMessage("Challenge Created", type: .Success)
          self.backtoMain()
        }
      })
      
    } else {
      self.alertWithMessage("Can`t create challenge", type: .Warning)
//      CHPush().alertPush("Can`t create challenge", type: "Warning")
    }
  }
  
  @IBAction func sendtoFriendAction(sender:AnyObject) {
    self.open()
  }
  
  @IBAction func confirm(sender:AnyObject) {
    self.sendAction()
    self.close()
  }
  
  @IBAction func decline(sender:AnyObject) {
    self.close()
  }
  
  func open() {
    self.addButton.hidden = true
    self.descView.hidden = false
  }
  
  func close() {
    self.addButton.hidden = false
    self.descView.hidden = true
  }
  
  func backtoMain() {
    Async.main{
//      self.performSegueWithIdentifier("backtoMain", sender: nil)
//
//      self.showModal()
      self.dismissViewControllerAnimated(true) {
        CHPush().localPush("wakeUpCreated", object: [])
        CHPush().localPush("refreshIcarousel", object: [])
        
      }
    }
  }
  
  func showModal() {
    let mainStoryboard: UIStoryboard          = UIStoryboard(name: "Main",bundle: nil)
    let WakeUpInfoViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("WakeUpInfoViewController")
    WakeUpInfoViewController.modalPresentationStyle = .OverCurrentContext
    presentViewController(WakeUpInfoViewController, animated: true, completion: nil)
  }
  
  func alertWithMessage(message:String, type:CHBanners.CHBannerTypes) {
    Async.main {
      let banner = CHBanners(withTarget: self.view, andType: type)
      banner.showBannerForViewControllerAnimated(true, message: message)
    }
  }
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
