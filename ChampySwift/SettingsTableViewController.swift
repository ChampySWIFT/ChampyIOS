//
//  SettingsTableViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import SwiftyJSON
import Fusuma

class SettingsTableViewController: UITableViewController, FusumaDelegate, UIPickerViewDelegate, UITextFieldDelegate   {
  public func fusumaVideoCompleted(withFileURL fileURL: URL) {
    
  }

  @IBOutlet weak var progressBar: RPCircularProgress!
  
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
    
    self.friendRequest.isOn         = userObject["profileOptions"]["friendRequests"].boolValue
    self.challengeEnd.isOn          = userObject["profileOptions"]["challengeEnd"].boolValue
    self.acceptedYourChallenge.isOn = userObject["profileOptions"]["acceptedYourChallenge"].boolValue
    self.enwChallengeRequests.isOn  = userObject["profileOptions"]["newChallengeRequests"].boolValue
    self.pushNotifications.isOn     = userObject["profileOptions"]["pushNotifications"].boolValue
    CHImages().setUpAvatar(userAvatar)
    
    
    
    CHUIElements().setUpDailyReminderCredentials(self.isHidden, switcher: self.dailyNOtificatorButton, picker: self.pickerView, label: self.dailyLabel)
    datePicker = CHUIElements().initAndSetUpDatePicker(30)
    
    
    let spaceButton     = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    
    let toolBar                             = UIToolbar(frame: CGRect(x: 0,y: 0,width: self.view.frame.size.width,height: 44))
    toolBar.barStyle                        = UIBarStyle.default
    let barButtonDone                       = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(SettingsTableViewController.valueChangedInDateField))
    barButtonDone.tintColor = CHUIElements().APPColors["navigationBar"]
    toolBar.items                           = [spaceButton, barButtonDone]
    
    self.inputFieldsForTime.inputAccessoryView = toolBar;
    self.inputFieldsForTime.inputView = datePicker;
    self.inputFieldsForTime.delegate  = self
    
    if CHSession().getIntByKey("minsDN") == 0 {
      self.inputFieldsForTime.text = "\(CHSession().getIntByKey("hoursDN")):00"
    } else {
      self.inputFieldsForTime.text = "\(CHSession().getIntByKey("hoursDN")):\(CHSession().getIntByKey("minsDN"))"
    }
    
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    if textField == self.inputFieldsForTime {
      self.initChoosing()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - IBACtion methods
  @IBAction func changeName(_ sender: AnyObject) {
    
    let forgot = UIAlertController(title: "Would you like to change your name?", message: "Please enter your name", preferredStyle: UIAlertControllerStyle.alert)
    
    forgot.addTextField(
      configurationHandler: {(textField: UITextField!) in
        textField.placeholder = "Enter your name"
    })
    
    let action = UIAlertAction(title: "Change", style: UIAlertActionStyle.default, handler: {[weak self]  (paramAction:UIAlertAction!) in
      self!.view.endEditing(true)
      if let textFields      = forgot.textFields{
        let theTextFields      = textFields as [UITextField]
        var enteredText:String = theTextFields[0].text!
        enteredText = enteredText.condenseWhitespace()
        enteredText = enteredText.trimmingCharacters(
          in: CharacterSet.whitespacesAndNewlines
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
    
    let Cancle = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
    forgot.addAction(Cancle)
    forgot.addAction(action)
    
    present(forgot, animated: true, completion: nil)
  }
  
  @IBAction func logOutAction(_ sender: AnyObject) {
    if !IJReachability.isConnectedToNetwork()  {
      _ = CHRequests()
      return
    }
    self.logOutButton.isHidden = true
    self.confirmationLogOutContainer.isHidden = false
    
    self.deleteButton.isHidden = false
    self.confirmDeleteAccountContainer.isHidden = true
    
  }
  
  @IBAction func acceptLogOutAction(_ sender: AnyObject) {
    self.logOutButton.isHidden = false
    self.confirmationLogOutContainer.isHidden = true
    
    //    CHPush().unSubscribeUserFrom(CHSession().currentUserId)
    CHSession().clearSession({ (result) in
      if result {
        Async.main {
          self.navigationController?.performSegue(withIdentifier: "showRoleControllerFromNavigation", sender: self)
        }
      }
    })
    
  }
  
  @IBAction func declineLogOutAction(_ sender: AnyObject) {
    self.logOutButton.isHidden = false
    self.confirmationLogOutContainer.isHidden = true
    
  }
  
  @IBAction func deleteAccountAction(_ sender: AnyObject) {
    self.deleteButton.isHidden = true
    self.confirmDeleteAccountContainer.isHidden = false
    
    self.logOutButton.isHidden = false
    self.confirmationLogOutContainer.isHidden = true
    
  }
  
  @IBAction func dismissDeleteAccount(_ sender: AnyObject) {
    self.deleteButton.isHidden = false
    self.confirmDeleteAccountContainer.isHidden = true
    
    
    
  }
  
  @IBAction func switchedSwitcher(_ sender: UISwitch!) {
    
    if !IJReachability.isConnectedToNetwork() {
      sender.isOn = !sender.isOn
    }
    
    let params = [
      "friendRequests": "\(self.friendRequest.isOn)",
      "challengeEnd": "\(self.challengeEnd.isOn)",
      "acceptedYourChallenge": "\(self.acceptedYourChallenge.isOn)",
      "newChallengeRequests": "\(self.enwChallengeRequests.isOn)",
      "pushNotifications": "\(self.pushNotifications.isOn)"
    ]
    
    CHRequests().updateUserProfileOptions(CHSession().currentUserId, params: params) { (result, json) in if result {} }
  }
  
  @IBAction func acceptDeleteAccount(_ sender: AnyObject) {
    self.deleteButton.isHidden = false
    self.confirmDeleteAccountContainer.isHidden = true
    CHChalenges().surrenderAllInProgressChallenges { (end) in
      if end {
        CHRequests().deleteAccount(CHSession().currentUserId) { (result, json) in
          if result {
            CHSession().clearSession({ (result) in
              if result {
                Async.main {
                  self.navigationController?.performSegue(withIdentifier: "showRoleControllerFromNavigation", sender: self)
                }
              }
            })
          }
        }
      }
    }
    
    
    
  }
  
  @IBAction func triggerDailyNtificator(_ sender: AnyObject) {
    
    isHidden = dailyNOtificatorButton.isOn
    
    self.pickerView.isHidden = !isHidden
    self.dailyLabel.isHidden = isHidden
    CHSession().CurrentUser.set(isHidden, forKey: "isHiddenDN")
    
  }
  
  @IBAction func upoadPhotoAction(_ sender: AnyObject) {
    guard IJReachability.isConnectedToNetwork() else {
      CHPush().alertPush("No internet connection", type: "Warning")
      return
    }
    let fusuma = FusumaViewController()
    fusuma.delegate = self
    fusumaTintColor = CHUIElements().APPColors["Info"]!
    fusumaBackgroundColor = CHUIElements().APPColors["navigationBar"]!
    fusumaCropImage = true
    fusumaTintIcons = true
    
    self.present(fusuma, animated: true, completion: nil)
    
  }
  
  @IBAction func aboutPage(_ sender: AnyObject) {
    if let requestUrl = URL(string: "http://champyapp.com") {
      UIApplication.shared.openURL(requestUrl)
    }
  }
  
  @IBAction func privacyPolicAction(_ sender: AnyObject) {
    if let requestUrl = URL(string: CHRequests().privacyUrl) {
      UIApplication.shared.openURL(requestUrl)
    }
  }
  
  @IBAction func enUserAgreementAction(_ sender: AnyObject) {
    if let requestUrl = URL(string: CHRequests().termsUrl) {
      UIApplication.shared.openURL(requestUrl)
    }
  }
  
  func imageRotatedByDegrees(oldImage: UIImage, deg degrees: CGFloat) -> UIImage {
    //Calculate the size of the rotated view's containing box for our drawing space
    let rotatedViewBox: UIView = UIView(frame: CGRect(x: 0, y: 0, width: oldImage.size.width, height: oldImage.size.height))
    let t: CGAffineTransform = CGAffineTransform(rotationAngle: degrees * CGFloat(M_PI / 180))
    rotatedViewBox.transform = t
    let rotatedSize: CGSize = rotatedViewBox.frame.size
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize)
    let bitmap: CGContext = UIGraphicsGetCurrentContext()!
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
    //Rotate the image context
    bitmap.rotate(by: (degrees * CGFloat(M_PI / 180)))
    //Now, draw the rotated/scaled image into the context
    bitmap.scaleBy(x: 1.0, y: -1.0)
    
    bitmap.draw(oldImage.cgImage!, in: CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height))
//    CGContextDrawImage(bitmap, CGRect(x: -oldImage.size.width / 2, y: -oldImage.size.height / 2, width: oldImage.size.width, height: oldImage.size.height), oldImage.cgImage)
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
  }
  
  // MARK: - Other functions methods
  func fusumaImageSelected(_ image: UIImage) {
    var transform = CGAffineTransform.identity
    CHPush().updateImageOnSettings(image)
    self.userAvatar.image = image
    var newImage = image
    switch image.imageOrientation {
    case .down:
      print("down")
      break
    case .leftMirrored:
      print("leftMirrored")
      transform = transform.translatedBy(x: image.size.width, y: image.size.height);
      transform = transform.rotated(by: CGFloat(M_PI));
      break;
    case .rightMirrored:
      print("rightMirrored")
      transform = transform.translatedBy(x: image.size.width, y: image.size.height);
      transform = transform.rotated(by: CGFloat(M_PI));
//      image.imageRotatedByDegrees(degrees: 90, flip: false)
      break;
    case .left:
      print("left")
      break
      
    case .right:
      transform = transform.translatedBy(x: image.size.width, y: image.size.height);
      transform = transform.rotated(by: CGFloat(M_PI));
//      image.imageRotatedByDegrees(degrees: 90, flip: false)

//      newImage = self.imageRotatedByDegrees(oldImage: image, deg: 90)
      newImage = image.fixOrientation(img: image)
      print("right")
      break
    case .up:
      print("up")
      break
    default:
      print("default")
      break
    }
    
    if IJReachability.isConnectedToNetwork() == false {
      return
    } else {
      
      let banner = CHBanners(withTarget: (self.navigationController?.view)!, andType: .Info)
      Async.main {
        banner.showBannerForViewControllerAnimatedWithReturning(true, message: "Uploading Profile Photo, please wait...")
      }
      CHRequests().uploadUsersPhoto(CHSession().currentUserId, image: newImage, bar: self.progressBar, completitionHandler: { (result, json) in
        if result {
          Async.main {
            banner.changeText("Uploaded")
            banner.changeType(.Success)
            banner.dismissView(true)
            //          CHImages().setUpAvatar(self.userAvatar)
            CHPush().updateImageOnSettings(image)
            CHPush().localPush("updatePhotoOnCards", object: self)
            self.userAvatar.image = image
            
          }
        } else {
          CHImages().setUpAvatar(self.userAvatar)
          banner.changeText("")
          banner.changeType(.Warning)
          banner.dismissView(true)
        }
      })
      
      
    }
    
  }
  
  func fusumaDismissedWithImage(_ image: UIImage) {
    
  }
  
  func fusumaCameraRollUnauthorized() {
    
  }
  
  
  
  func valueChangedInDateField() {
    let dateFormatter = DateFormatter()
    
    dateFormatter.timeStyle = DateFormatter.Style.short
    dateFormatter.dateFormat = "HH:mm"
    let strDate = dateFormatter.string(from: datePicker.date)
    
    let calendar = Calendar.current
    let comp = (calendar as NSCalendar).components([.hour, .minute, .second], from: datePicker.date)
    let hour = comp.hour
    let minute = comp.minute
    
    self.inputFieldsForTime.text = strDate
    
    inputFieldsForTime.resignFirstResponder()
    
    CHSession().CurrentUser.set(hour, forKey: "hoursDN")
    CHSession().CurrentUser.set(minute, forKey: "minsDN")
    
  }
  
  func initChoosing() {
    let calendar:NSCalendar = NSCalendar.current as NSCalendar
    var components = calendar.components([.hour, .minute, .second], from: NSDate() as Date)
    components.hour = 12
    components.minute = 0
    components.second = 0
    datePicker.setDate(calendar.date(from: components)!, animated: true)
    let dateFormatter = DateFormatter()
    
    dateFormatter.timeStyle = DateFormatter.Style.short
    dateFormatter.dateFormat = "HH:mm"
    let strDate = dateFormatter.string(from: datePicker.date)
    self.inputFieldsForTime.text = strDate
  }
  
  
}

extension Double {
  func toRadians() -> CGFloat {
    return CGFloat(self * .pi / 180.0)
  }
}

extension UIImage {
  
  func fixOrientation(img:UIImage) -> UIImage {
    
    if (img.imageOrientation == UIImageOrientation.up) {
      return img;
    }
    
    UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
    let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
    img.draw(in: rect)
    
    let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext();
    return normalizedImage;
    
  }
  
  
  func rotated(by degrees: Double) -> UIImage? {
    guard let cgImage = self.cgImage else { return nil }
    
    let transform = CGAffineTransform(rotationAngle: degrees.toRadians())
    var rect = CGRect(origin: .zero, size: self.size).applying(transform)
    rect.origin = .zero
    
    if #available(iOS 10.0, *) {
      let renderer = UIGraphicsImageRenderer(size: rect.size)
      return renderer.image { renderContext in
        renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
        renderContext.cgContext.rotate(by: degrees.toRadians())
        renderContext.cgContext.scaleBy(x: 1.0, y: -1.0)
        
        let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
        renderContext.cgContext.draw(cgImage, in: drawRect)
      }
    } else {
      return self
      // Fallback on earlier versions
    }
    
  }
}
