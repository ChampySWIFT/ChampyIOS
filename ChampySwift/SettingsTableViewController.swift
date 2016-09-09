//
//  SettingsTableViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import PresenterKit
import ALCameraViewController
import Async
import SwiftyJSON
import Fusuma

class SettingsTableViewController: UITableViewController, FusumaDelegate, UIPickerViewDelegate, UITextFieldDelegate   {
  
  @IBOutlet weak var userAvatar: UIImageView!
  @IBOutlet weak var userName: UILabel!
  @IBOutlet weak var userLevel: UILabel!
  
  @IBOutlet weak var logOutButton: UIButton!
  @IBOutlet weak var confirmationLogOutContainer: UIView!
  @IBOutlet weak var deleteButton: UIButton!
  @IBOutlet weak var confirmDeleteAccountContainer: UIView!
  
  
  @IBOutlet weak var pushNotifications: UISwitch!
  @IBOutlet weak var enwChallengeRequests: UISwitch!
  @IBOutlet weak var acceptedYourChallenge: UISwitch!
  @IBOutlet weak var challengeEnd: UISwitch!
  @IBOutlet weak var friendRequest: UISwitch!
  @IBOutlet weak var dailyLabel: UILabel!
  @IBOutlet weak var pickerView: UIView!
  @IBOutlet weak var dailyNOtificatorButton: UISwitch!
  @IBOutlet var timePickerView: UIDatePicker!
  @IBOutlet weak var inputFieldsForTime: UITextField!
  
  var isHidden = true
  var datePicker:UIDatePicker! = nil
  
  // MARK: - Override lifecycle methods
  override func viewDidLoad() {
    super.viewDidLoad()
    let userObject:JSON            = CHSession().currentUserObject
    userAvatar.layer.masksToBounds = true
    userAvatar.layer.cornerRadius  = 50.0
    userName.text                  = CHSession().currentUserName
    
    self.friendRequest.on         = userObject["profileOptions"]["friendRequests"].boolValue
    self.challengeEnd.on          = userObject["profileOptions"]["challengeEnd"].boolValue
    self.acceptedYourChallenge.on = userObject["profileOptions"]["acceptedYourChallenge"].boolValue
    self.enwChallengeRequests.on  = userObject["profileOptions"]["newChallengeRequests"].boolValue
    self.pushNotifications.on     = userObject["profileOptions"]["pushNotifications"].boolValue
    CHImages().setUpAvatar(userAvatar)
    
    
    CHUIElements().setUpDailyReminderCredentials(self.isHidden, switcher: self.dailyNOtificatorButton, picker: self.pickerView, label: self.dailyLabel)
    datePicker = CHUIElements().initAndSetUpDatePicker(30)
    
    
    let spaceButton     = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
    
    let toolBar                             = UIToolbar(frame: CGRectMake(0,0,self.view.frame.size.width,44))
    toolBar.barStyle                        = UIBarStyle.Default
    let barButtonDone                       = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: #selector(SettingsTableViewController.valueChangedInDateField))
    barButtonDone.tintColor = CHUIElements().APPColors["navigationBar"]
    toolBar.items                           = [spaceButton, barButtonDone]
    
    self.inputFieldsForTime.inputAccessoryView = toolBar;
    self.inputFieldsForTime.inputView = datePicker;
    self.inputFieldsForTime.delegate  = self
    var minuteString = ""
    let minutes:Int = CHSession().getIntByKey("minsDN")
    print(minutes)
    if minutes == 0 {
      self.inputFieldsForTime.text = "\(CHSession().getIntByKey("hoursDN")):00"
    } else {
      self.inputFieldsForTime.text = "\(CHSession().getIntByKey("hoursDN")):\(minutes)"
    }
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - IBACtion methods
  @IBAction func changeName(sender: AnyObject) {
    
    let forgot = UIAlertController(title: "Would you like to change your name?", message: "Please enter your name", preferredStyle: UIAlertControllerStyle.Alert)
    
    forgot.addTextFieldWithConfigurationHandler(
      {(textField: UITextField!) in
        textField.placeholder = "Enter your name"
    })
    
    let action = UIAlertAction(title: "Change", style: UIAlertActionStyle.Default, handler: {[weak self]  (paramAction:UIAlertAction!) in
      self!.view.endEditing(true)
      if let textFields      = forgot.textFields{
        let theTextFields      = textFields as [UITextField]
        var enteredText:String = theTextFields[0].text!
        enteredText = enteredText.condenseWhitespace()
        enteredText = enteredText.stringByTrimmingCharactersInSet(
          NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        guard enteredText != "" else {
          CHPush().alertPush("Name should not be blank", type: "Warning")
          return
        }
        if Int(enteredText) != nil  {
          CHPush().alertPush("Wrong symbols", type: "Warning")
          return
        }
        
        if !enteredText.isName() {
          CHPush().alertPush("Wrong symbols", type: "Warning")
          return
        }
        
        if enteredText.characters.count > 40 {
          CHPush().alertPush("Entered name is too long", type: "Warning")
          return
        }
        
        CHRequests().updateUserProfile(CHSession().currentUserId, params: ["name": enteredText], completitionHandler: { (result, json) in
          if result {
            Async.main{
              self!.userName.text = CHSession().currentUserName
            }
          }
        })
        
      }
      
      
      })
    
    let Cancle = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
    forgot.addAction(Cancle)
    forgot.addAction(action)
    
    presentViewController(forgot, animated: true, completion: nil)
  }
  
  @IBAction func logOutAction(sender: AnyObject) {
    if !IJReachability.isConnectedToNetwork()  {
      let a = CHRequests()
      return
    }
    self.logOutButton.hidden = true
    self.confirmationLogOutContainer.hidden = false
    
    self.deleteButton.hidden = false
    self.confirmDeleteAccountContainer.hidden = true
    
  }
  
  @IBAction func acceptLogOutAction(sender: AnyObject) {
    self.logOutButton.hidden = false
    self.confirmationLogOutContainer.hidden = true
    
    //    CHPush().unSubscribeUserFrom(CHSession().currentUserId)
    CHSession().clearSession({ (result) in
      if result {
        Async.main {
          let mainStoryboard: UIStoryboard                 = UIStoryboard(name: "Main",bundle: nil)
          let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
          self.presentViewController(roleControlViewController, type: .push, animated: false)
        }
      }
    })
    
  }
  
  @IBAction func declineLogOutAction(sender: AnyObject) {
    self.logOutButton.hidden = false
    self.confirmationLogOutContainer.hidden = true
    
  }
  
  @IBAction func deleteAccountAction(sender: AnyObject) {
    self.deleteButton.hidden = true
    self.confirmDeleteAccountContainer.hidden = false
    
    self.logOutButton.hidden = false
    self.confirmationLogOutContainer.hidden = true
    
  }
  
  @IBAction func dismissDeleteAccount(sender: AnyObject) {
    self.deleteButton.hidden = false
    self.confirmDeleteAccountContainer.hidden = true
    
    
    
  }
  
  @IBAction func switchedSwitcher(sender: UISwitch!) {
    
    if !IJReachability.isConnectedToNetwork() {
      sender.on = !sender.on
    }
    
    let params = [
      "friendRequests": "\(self.friendRequest.on)",
      "challengeEnd": "\(self.challengeEnd.on)",
      "acceptedYourChallenge": "\(self.acceptedYourChallenge.on)",
      "newChallengeRequests": "\(self.enwChallengeRequests.on)",
      "pushNotifications": "\(self.pushNotifications.on)"
    ]
    
    CHRequests().updateUserProfileOptions(CHSession().currentUserId, params: params) { (result, json) in if result {} }
  }
  
  @IBAction func acceptDeleteAccount(sender: AnyObject) {
    self.deleteButton.hidden = false
    self.confirmDeleteAccountContainer.hidden = true
    CHRequests().surrenderAll(CHSession().currentUserId) { (result, json) in
      if result {
        
        CHRequests().deleteAccount(CHSession().currentUserId) { (result, json) in
          if result {
            CHSession().clearSession({ (result) in
              if result {
                Async.main {
                  let mainStoryboard: UIStoryboard                 = UIStoryboard(name: "Main",bundle: nil)
                  let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
                  self.presentViewController(roleControlViewController, type: .push, animated: false)
                }
              }
            })
          }
        }
        
      }
    }
    
    
  }
  
  @IBAction func triggerDailyNtificator(sender: AnyObject) {
    
    isHidden = dailyNOtificatorButton.on
    
    self.pickerView.hidden = !isHidden
    self.dailyLabel.hidden = isHidden
    CHSession().CurrentUser.setBool(isHidden, forKey: "isHiddenDN")
    
  }
  
  @IBAction func upoadPhotoAction(sender: AnyObject) {
    guard IJReachability.isConnectedToNetwork() else {
      CHPush().alertPush("No internet connection", type: "Warning")
      return
    }
    let fusuma = FusumaViewController()
    fusuma.delegate = self
    self.presentViewController(fusuma, animated: true, completion: nil)
    
  }
  
  @IBAction func aboutPage(sender: AnyObject) {
    if let requestUrl = NSURL(string: "http://champyapp.com") {
      UIApplication.sharedApplication().openURL(requestUrl)
    }
  }
  
  @IBAction func privacyPolicAction(sender: AnyObject) {
    if let requestUrl = NSURL(string: CHRequests().privacyUrl) {
      UIApplication.sharedApplication().openURL(requestUrl)
    }
  }
  
  @IBAction func enUserAgreementAction(sender: AnyObject) {
    if let requestUrl = NSURL(string: CHRequests().termsUrl) {
      UIApplication.sharedApplication().openURL(requestUrl)
    }
  }
  
  // MARK: - Other functions methods
  func fusumaImageSelected(image: UIImage) {
    if IJReachability.isConnectedToNetwork() == false {
      return
    } else {
      
      let banner = CHBanners(withTarget: (self.navigationController?.view)!, andType: .Info)
      Async.main {
        banner.showBannerForViewControllerAnimatedWithReturning(true, message: "Uploading Profile Photo, please wait...")
      }
      
      CHRequests().uploadUsersPhoto(CHSession().currentUserId, image: image, completitionHandler: { (result, json) in
        if result {
          Async.main {
            banner.changeText("Uploaded")
            banner.changeType(.Success)
            banner.dismissView(true)
            //          CHImages().setUpAvatar(self.userAvatar)
            CHPush().updateImageOnSettings(image)
            self.userAvatar.image = image
            
          }
        } else {
          banner.changeText("Uploaded")
          banner.changeType(.Warning)
          banner.dismissView(true)
        }
      })
    }
    
  }
  
  func fusumaDismissedWithImage(image: UIImage) {
    
  }
  
  func fusumaCameraRollUnauthorized() {
    
  }
  
  func valueChangedInDateField() {
    let dateFormatter = NSDateFormatter()
    
    dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
    dateFormatter.dateFormat = "HH:mm"
    let strDate = dateFormatter.stringFromDate(datePicker.date)
    
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Hour, .Minute, .Second], fromDate: datePicker.date)
    let hour = comp.hour
    let minute = comp.minute
    
    self.inputFieldsForTime.text = strDate
    
    inputFieldsForTime.resignFirstResponder()
    
    CHSession().CurrentUser.setInteger(hour, forKey: "hoursDN")
    CHSession().CurrentUser.setInteger(minute, forKey: "minsDN")
    
  }
  
  
}
