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
import CoreMotion
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
  var manager: CMMotionManager!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    manager = CMMotionManager()
    if manager.isGyroAvailable {
      
    }
    
    manager.startGyroUpdates()
    
    let queue = OperationQueue.main
    
    if manager.isDeviceMotionAvailable {
      manager.deviceMotionUpdateInterval = 0.01
      
      manager.startDeviceMotionUpdates(to: queue, withHandler: { (data, error) in
        if (data?.userAcceleration.x)! < Double(-2.5) {
          self.dismiss(animated: true, completion: { 
            
          })
        }
        
      })
    }
    datePicker = UIDatePicker() // Although you probably have an IBOutlet
    datePicker.datePickerMode = UIDatePickerMode.time
    datePicker.backgroundColor = UIColor.lightGray
    datePicker.tintColor = CHUIElements().APPColors["navigationBar"]
    
    let curredntDateInSec = CHUIElements().getCurretnTime()
    
    let calendar = Calendar.current
    let comp = (calendar as NSCalendar).components([.hour, .minute, .second], from: Date(timeIntervalSince1970: Double(curredntDateInSec)))
    let hour = comp.hour
    let minute = comp.minute
    
    let hoursInSec = (hour! * 60 * 60)
    let minInSec = (minute! * 60)
    let newTime = (curredntDateInSec - hoursInSec - minInSec - comp.second!)  + 108000 //30*60*60
    self.dateInt = newTime
    let dateFormatter = DateFormatter()
    
    dateFormatter.timeStyle = DateFormatter.Style.short
    dateFormatter.dateFormat = "hh:mm a"
    
    let date = Date(timeIntervalSince1970: Double(newTime))
    let strDate = dateFormatter.string(from: date)
    
    
    self.timeField.text = strDate
    self.timeField.resignFirstResponder()
    
    
    
//    datePicker.addTarget(self, action: #selector(WakeUpViewController.valueChangedInDateField(_:)), forControlEvents: .ValueChanged)
    
    
    let spaceButton     = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    
    let toolBar                             = UIToolbar(frame: CGRect(x: 0,y: 0,width: self.view.frame.size.width,height: 44))
    toolBar.barStyle                        = UIBarStyle.default
    let barButtonDone                       = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(WakeUpViewController.valueChangedInDateField))
    barButtonDone.tintColor = CHUIElements().APPColors["navigationBar"]
    toolBar.items                           = [spaceButton, barButtonDone]
    timeField.inputAccessoryView = toolBar;
    timeField.inputView = datePicker;
    timeField.delegate  = self
  }
  
  func valueChangedInDateField(_ sender:AnyObject) {
    let dateFormatter = DateFormatter()
    
    dateFormatter.timeStyle = DateFormatter.Style.short
    dateFormatter.dateFormat = "hh:mm a"
    let strDate = dateFormatter.string(from: datePicker.date)
    
    let calendar = Calendar.current
    let comp = (calendar as NSCalendar).components([.hour, .minute, .second], from: datePicker.date)
    
    self.timeField.text = strDate
    self.timeField.resignFirstResponder()
    
    self.dateInt = Int(datePicker.date.timeIntervalSince1970) - comp.second!
    
    if dateInt <= CHUIElements().getCurretnTime() {
      dateInt = dateInt + CHSettings().daysToSec(1)
    }
    
  }
  
  @IBAction func closeView(_ sender: AnyObject) {
    self.dismiss(animated: true) { 
      CHPush().localPush("refreshIcarousel", object: self)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func plusOneDayAction(_ sender: AnyObject) {
    var days:String = (dayLabel.text?.replacingOccurrences(of: " Days", with: ""))!
    days = (days.replacingOccurrences(of: " Day", with: ""))
    
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
  
  @IBAction func minusOneDayAction(_ sender: AnyObject) {
    var days:String = (dayLabel.text?.replacingOccurrences(of: " Days", with: ""))!
    days = (days.replacingOccurrences(of: " Day", with: ""))
    
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
  
  @IBAction func plusTimeAction(_ sender: AnyObject) {
  }
  
  @IBAction func minusTimeAction(_ sender: AnyObject) {
    
  }
  
  
  
  
  
  
  func sendAction() {
    if CHSession().currentUserObject["inProgressChallengesCount"].intValue >= CHChalenges().maxChallengesCount {
      CHPush().alertPush("Can't create more challenges", type: "Warning")
      return
    }
    var days:String = (dayLabel.text?.replacingOccurrences(of: " Days", with: ""))!
    days = (days.replacingOccurrences(of: " Day", with: ""))
    
    let currentValue:Int = Int(days)!
    
    let duration = CHSettings().daysToSec(currentValue)
    
    
    var array:[Int] = []
    
    for i:Int in 0...currentValue {
      array.append(self.dateInt + CHSettings().daysToSec(i))
    }
    
    //////print(array)
    
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
  
  
  func finisher(_ result:Bool) {
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
  
  @IBAction func sendtoFriendAction(_ sender:AnyObject) {
    self.open()
  }
  
  @IBAction func confirm(_ sender:AnyObject) {
    self.sendAction()
    self.close()
  }
  
  @IBAction func decline(_ sender:AnyObject) {
    self.close()
  }
  
  func open() {
    self.addButton.isHidden = true
    self.descView.isHidden = false
  }
  
  func close() {
    self.addButton.isHidden = false
    self.descView.isHidden = true
  }
  
  func backtoMain() {
    Async.main{
//      self.performSegueWithIdentifier("backtoMain", sender: nil)
//
//      self.showModal()
      self.dismiss(animated: true) {
        CHPush().localPush("wakeUpCreated", object: self)
        CHPush().localPush("refreshIcarousel", object: self)
        
      }
    }
  }
  
  func showModal() {
    let mainStoryboard: UIStoryboard          = UIStoryboard(name: "Main",bundle: nil)
    let WakeUpInfoViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "WakeUpInfoViewController")
    WakeUpInfoViewController.modalPresentationStyle = .overCurrentContext
    present(WakeUpInfoViewController, animated: true, completion: nil)
  }
  
  func alertWithMessage(_ message:String, type:CHBanners.CHBannerTypes) {
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
