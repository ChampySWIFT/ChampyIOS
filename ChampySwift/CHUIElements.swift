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
  
  var borderColor = UIColor(red: 205/255.0, green: 206/255.0, blue: 210/255.0, alpha: 0.2)
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





