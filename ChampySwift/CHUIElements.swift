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
    let dt:Date = Date()
    return Int(dt.timeIntervalSince1970)
    
  }
  
  
  func playAudio() {
    Async.main{
      let coinSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "out", ofType: "wav")!)
      do{
        let audioPlayer = try AVAudioPlayer(contentsOf:coinSound as URL)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
      }catch {
       
      }
      
    
    }
    
    
  }
  

  
  func stringToJSON(_ jsonString:String) -> JSON {
    do {
      if let data:Data = jsonString.data(using: String.Encoding.utf8, allowLossyConversion: false){
        if jsonString != "error" {
          let jsonResult:JSON = JSON(data: data)
          return jsonResult
        }
      }
    }
    catch _ as NSError {
      
    }
    
    return nil
  }
  
  func initAndSetUpDatePicker(_ interval:Int) -> UIDatePicker {
    let picker = UIDatePicker()
    picker.datePickerMode = UIDatePickerMode.time
    picker.backgroundColor = UIColor.lightGray
    picker.tintColor = CHUIElements().APPColors["navigationBar"]
    picker.minuteInterval = interval
    
    return picker
  }
  
  func setUpDailyReminderCredentials(_ status:Bool, switcher:UISwitch, picker:UIView, label:UILabel) {
    var status = status, switcher = switcher
    if CHSession().CurrentUser.object(forKey: "isHiddenDN") != nil {
      status = CHSession().CurrentUser.bool(forKey: "isHiddenDN")
    } else {
      status = true
      CHSession().CurrentUser.set(true, forKey: "isHiddenDN")
    }
    
    switcher.isOn = status
    picker.isHidden  = !status
    label.isHidden = status
  }
}



extension UIApplication {
  class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
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
                                         options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                                    range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func isChallengeName() -> Bool {
    let regex = try! NSRegularExpression(pattern: "[1234567890QWERTYUIOPLKJHGFDSAZXCVBNMйцукенгшщзхїґєждлорпавіфячсмитьбюыЙЦУКЕНГШЩЗХЇЄЖДЛҐОРПАВИФЯЧСМІТЬБЮЫqwertyuioplkjhgfdsazxcvbnmàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$",
                                         options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                            range: NSMakeRange(0, utf16.count)) != nil
  }
  
  
  func isDayNumber() -> Bool {
    //    ^[0-9]{1,3}$
    let regex = try! NSRegularExpression(pattern: "^[0-9]{1,3}$",
                                         options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                                    range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func isValidChallengeName() -> Bool {
    //  [^,.'-]+
    let regex = try! NSRegularExpression(pattern: "^[^,.'-]+", options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                                    range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func isValidConditions() -> Bool {
    //    ^[QWERTYUIOPLKJHGFDSAZXCVBNMйцукенгшщзхїґєждлорпавіфячсмитьбюыЙЦУКЕНГШЩЗХЇЄЖДЛҐОРПАВИФЯЧСМІТЬБЮЫqwertyuioplkjhgfdsazxcvbnmàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]{1,45}$
    let regex = try! NSRegularExpression(pattern: "^[1234567890QWERTYUIOPLKJHGFDSAZXCVBNMйцукенгшщзхїґєждлорпавіфячсмитьбюыЙЦУКЕНГШЩЗХЇЄЖДЛҐОРПАВИФЯЧСМІТЬБЮЫqwertyuioplkjhgfdsazxcvbnmàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]{1,45}$",
                                         options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                                    range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func condenseWhitespace() -> String {
    let components = self.components(separatedBy: CharacterSet.whitespacesAndNewlines)
    return components.filter { !$0.isEmpty }.joined(separator: " ")
  }
  
}

extension UITableViewCell {
  func noSelectionNoColorNoAccessoryNoContentView() {
    self.backgroundColor = UIColor.clear
    self.accessoryType  = .none
    self.selectionStyle = UITableViewCellSelectionStyle.none
    self.contentView.backgroundColor = UIColor.clear
    
  }
}

extension UIImageView {
  func roundCornersAndSetUpWithId(id:String, userObject:JSON = nil) {
    self.layer.masksToBounds = true
    self.layer.cornerRadius  = self.frame.size.width / 2
    if userObject["photo"] != nil {
      CHImages().setImageForFriend(id, imageView: self, userObject: userObject)
    } else {
      CHImages().setUpDefaultImageForFriend(id, imageView: self)
    }
    
  }

}


extension Array  {
  
  func adjustFontSizeToFiTWidthForObjects(value:Bool)  {
    
    for x in self {
      let t = x as! UILabel;
      t.adjustsFontSizeToFitWidth = true
    }
    
  }
}

extension JSON {
  
  func getElementFromList(key:String, value:String) -> JSON {
  
    for json:JSON in self.arrayValue {
      if json[key].stringValue == value {
          return json
      }
    }
    
    return nil
  }
  
  func userImLookinFor(key:String, value:String) -> JSON {
    let array:[[String:AnyObject]] = self.arrayObject as! [[String:AnyObject]]
    let new = array.filter({
      if let subid = $0[key] {
        return subid as! String == value
      } else {
        return false
      }
    })
    return JSON(dictionaryObject: new[0]) 
  }
  
  
  
  
  func convertUsersStringToDictionary(text:String) -> [[String:AnyObject]]? {
    if let data = text.data(using: String.Encoding.utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]]
      } catch let error as NSError {
        
      }
    }
    return nil
  }
  
  func getIntByKey(key:String) -> Int {
    if self[key].int != nil {
      return self[key].intValue
    }
    
    return 0
  }
  
  func getStringByKey(key:String) -> String {
    if self[key].string != nil {
      return self[key].stringValue
    }
    
    return ""
  }
  
  
  func getSummOffElements(keys:[String]) -> Int {
    var result = 0
    for key in keys {
      if self[key].int != nil {
        result += self[key].intValue
      }
    }
    
    
    return result
  }
  
  
  
}

