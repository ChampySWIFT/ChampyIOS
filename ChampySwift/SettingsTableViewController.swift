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

class SettingsTableViewController: UITableViewController, FusumaDelegate {
  
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
    
    print(params)
    
    CHRequests().updateUserProfileOptions(CHSession().currentUserId, params: params) { (result, json) in
      if result {}
    }
  }
  
  
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
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
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
    self.logOutButton.hidden = true
    self.confirmationLogOutContainer.hidden = false
    
    self.deleteButton.hidden = false
    self.confirmDeleteAccountContainer.hidden = true
    
  }
  
  
  @IBAction func acceptLogOutAction(sender: AnyObject) {
    self.logOutButton.hidden = false
    self.confirmationLogOutContainer.hidden = true
    
    CHRequests().logout(CHSession().currentUserId) { (result, json) in
      if result {
        Async.main {
          CHSession().clearSession()
          let mainStoryboard: UIStoryboard                 = UIStoryboard(name: "Main",bundle: nil)
          let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
          self.presentViewController(roleControlViewController, type: .push, animated: false)
        }
      }
    }
    
    
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
  
  
  
  
  @IBAction func acceptDeleteAccount(sender: AnyObject) {
    self.deleteButton.hidden = false
    self.confirmDeleteAccountContainer.hidden = true
    CHRequests().deleteAccount(CHSession().currentUserId) { (result, json) in
      if result {
        Async.main {
          CHSession().clearSession()
          let mainStoryboard: UIStoryboard          = UIStoryboard(name: "Main",bundle: nil)
          let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
          self.presentViewController(roleControlViewController, type: .push, animated: false)
        }
      }
    }
  }
  
  func fusumaImageSelected(image: UIImage) {
    
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

  // Return the image but called after is dismissed.
  func fusumaDismissedWithImage(image: UIImage) {
    
    print("Called just after FusumaViewController is dismissed.")
  }
  
  // When camera roll is not authorized, this method is called.
  func fusumaCameraRollUnauthorized() {
    
    print("Camera roll unauthorized")
  }
  
  @IBAction func upoadPhotoAction(sender: AnyObject) {
    guard IJReachability.isConnectedToNetwork() else {
      CHPush().alertPush("No internet connection", type: "Warning")
      return
    }
    let fusuma = FusumaViewController()
    fusuma.delegate = self
    self.presentViewController(fusuma, animated: true, completion: nil)
//    var cameraViewController:CameraViewController! = nil
//    
//    cameraViewController = CameraViewController(croppingEnabled: true, allowsLibraryAccess: true) { [weak self] image, asset in
//      if image != nil {
//        let banner = CHBanners(withTarget: (self!.navigationController?.view)!, andType: .Info)
//        Async.main {
//          banner.showBannerForViewControllerAnimatedWithReturning(true, message: "Uploading Profile Photo, please wait...")
//        }
//        
//        CHRequests().uploadUsersPhoto(CHSession().currentUserId, image: image!, completitionHandler: { (result, json) in
//          if result {
//            Async.main {
//              banner.changeText("Uploaded")
//              banner.changeType(.Success)
//              banner.dismissView(true)
//              CHImages().setUpAvatar(self!.userAvatar)
//              CHPush().updateImageOnSettings(image!)
//              self!.userAvatar.image = image
//              
//            }
//          } else {
//            banner.changeText("Uploaded")
//            banner.changeType(.Warning)
//            banner.dismissView(true)
//          }
//        })
//      }
//      
//      cameraViewController.dismissViewControllerAnimated(true, completion: { 
//        cameraViewController.view.removeFromSuperview()
//      })
//      self!.dismissViewControllerAnimated(true, completion: nil)
      
//    }
    
//    presentViewController(cameraViewController, animated: true, completion: nil)
  }
  
  
  @IBAction func aboutPage(sender: AnyObject) {
    if let requestUrl = NSURL(string: "http://champyapp.com") {
      UIApplication.sharedApplication().openURL(requestUrl)
    }
  }
  
  @IBAction func privacyPolicAction(sender: AnyObject) {
    if let requestUrl = NSURL(string: "http://champyapp.com/privacy.html") {
      UIApplication.sharedApplication().openURL(requestUrl)
    }
  }
  
  @IBAction func enUserAgreementAction(sender: AnyObject) {
    if let requestUrl = NSURL(string: "http://champyapp.com/Terms.html") {
      UIApplication.sharedApplication().openURL(requestUrl)
    }
  }
  
  
}
