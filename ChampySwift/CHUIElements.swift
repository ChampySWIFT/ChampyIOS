//
//  CHUIElements.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/25/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation
import SwiftyJSON
import Async

class CHUIElements: NSObject {
  
  
  var APPColors: [String: UIColor] = [
    "navigationBar"  : UIColor(red: 31/255.0, green: 131/255.0, blue: 134/255.0, alpha: 1),
    "Info" : UIColor(red: 249/255.0, green: 198/255.0, blue: 108/255.0, alpha: 1),
    "Warning" : UIColor(red: 255/255.0, green: 0/255.0, blue: 64/255.0, alpha: 1),
    "Success1" : UIColor(red: 30/255.0, green: 160/255.0, blue: 73/255.0, alpha: 1),
    "Success" : UIColor(red: 31/255.0, green: 131/255.0, blue: 134/255.0, alpha: 1),
    "Default" : UIColor(red: 61/255.0, green: 130/255.0, blue: 134/255.0, alpha: 1),
    "title": UIColor(red: 246/255.0, green: 201/255.0, blue: 133/255.0, alpha: 1),
    ]
  
  var bombSoundEffect: AVAudioPlayer!
  var font12:UIFont     = UIFont(name: "BebasNeueRegular", size: 12)!
  var font16:UIFont     = UIFont(name: "BebasNeueRegular", size: 16)!
  
  func vibrating() {
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
  }
  
  func getCurretnTime()->Int{
    let dt:NSDate = NSDate()
    return Int(dt.timeIntervalSince1970)
    
  }
  
  
  func playAudio() {
    Async.main{
      let coinSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("out", ofType: "wav")!)
      do{
        let audioPlayer = try AVAudioPlayer(contentsOfURL:coinSound)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
      }catch {
        print("Error getting the audio file")
      }
      
    
    }
    
    
  }
  
  func stringToJSON(jsonString:String) -> JSON {
    do {
      if let data:NSData = jsonString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false){
        if jsonString != "error" {
          let jsonResult:JSON = JSON(data: data)
          return jsonResult
        }
      }
    }
    catch let error as NSError {
      
    }
    
    return nil
  }
  
  func initAndSetUpDatePicker(interval:Int) -> UIDatePicker {
    let picker = UIDatePicker()
    picker.datePickerMode = UIDatePickerMode.Time
    picker.backgroundColor = UIColor.lightGrayColor()
    picker.tintColor = CHUIElements().APPColors["navigationBar"]
    picker.minuteInterval = interval
    
    return picker
  }
  
  func setUpDailyReminderCredentials(var status:Bool, var switcher:UISwitch, picker:UIView, label:UILabel) {
    if CHSession().CurrentUser.objectForKey("isHiddenDN") != nil {
      status = CHSession().CurrentUser.boolForKey("isHiddenDN")
    } else {
      status = true
      CHSession().CurrentUser.setBool(true, forKey: "isHiddenDN")
    }
    
    switcher.on = status
    picker.hidden  = !status
    label.hidden = status
  }
}



extension UIApplication {
  class func topViewController(base: UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(selected)
      }
    }
    if let presented = base?.presentedViewController {
      return topViewController(presented)
    }
    return base
  }
}

extension String {
  //  /^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$/u
  func isName() -> Bool {
    let regex = try! NSRegularExpression(pattern: "[QWERTYUIOPLKJHGFDSAZXCVBNMйцукенгшщзхїґєждлорпавіфячсмитьбюыЙЦУКЕНГШЩЗХЇЄЖДЛҐОРПАВИФЯЧСМІТЬБЮЫqwertyuioplkjhgfdsazxcvbnmàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$",
                                         options: [.CaseInsensitive])
    
    return regex.firstMatchInString(self.lowercaseString, options:[],
                                    range: NSMakeRange(0, utf16.count)) != nil
  }
  
  
  func isDayNumber() -> Bool {
    //    ^[0-9]{1,3}$
    let regex = try! NSRegularExpression(pattern: "^[0-9]{1,3}$",
                                         options: [.CaseInsensitive])
    
    return regex.firstMatchInString(self.lowercaseString, options:[],
                                    range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func isValidChallengeName() -> Bool {
    //  [^,.'-]+
    let regex = try! NSRegularExpression(pattern: "^[^,.'-]+", options: [.CaseInsensitive])
    
    return regex.firstMatchInString(self.lowercaseString, options:[],
                                    range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func isValidConditions() -> Bool {
    //    ^[QWERTYUIOPLKJHGFDSAZXCVBNMйцукенгшщзхїґєждлорпавіфячсмитьбюыЙЦУКЕНГШЩЗХЇЄЖДЛҐОРПАВИФЯЧСМІТЬБЮЫqwertyuioplkjhgfdsazxcvbnmàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]{1,45}$
    let regex = try! NSRegularExpression(pattern: "^[QWERTYUIOPLKJHGFDSAZXCVBNMйцукенгшщзхїґєждлорпавіфячсмитьбюыЙЦУКЕНГШЩЗХЇЄЖДЛҐОРПАВИФЯЧСМІТЬБЮЫqwertyuioplkjhgfdsazxcvbnmàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]{1,45}$",
                                         options: [.CaseInsensitive])
    
    return regex.firstMatchInString(self.lowercaseString, options:[],
                                    range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func condenseWhitespace() -> String {
    let components = self.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    return components.filter { !$0.isEmpty }.joinWithSeparator(" ")
  }
  
}
