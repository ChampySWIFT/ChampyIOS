//
//  CHWakeUpper.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/27/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class CHWakeUpper: NSObject {
  
  func schduleReminder() {
    let calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    var dateFire=Date()
    
    var fireComponents=(calendar as NSCalendar).components([.day, .month, .year, .hour, .minute] , from:dateFire)
    
    fireComponents.hour = 12
    fireComponents.minute = 00
    
    
    dateFire = calendar.date(from: fireComponents)!
    
    let localNotification = UILocalNotification()
    localNotification.fireDate = dateFire
    localNotification.alertBody = "Hey! Looks like you still have some challenges for today."
    localNotification.repeatInterval = .day
    localNotification.soundName   = UILocalNotificationDefaultSoundName //"out.wav"
    UIApplication.shared.scheduleLocalNotification(localNotification)
  }
  
  func setUpWakeUp() -> Bool  {
    self.cleareScheduledNotifications()
    let generalArray = CHChalenges().getInProgressChallenges(CHSession().currentUserId)
    
    if generalArray.count > 0 {
      schduleReminder()
    }
    
    for item in CHChalenges().getAllActiveWakeUpChallenges(CHSession().currentUserId) {
      guard item["challenge"]["type"].stringValue == CHSettings().wakeUpIds else {
        continue
      }
      self.setUpWakeUpArray(CHSettings().stringToArray(item["challenge"]["details"].stringValue.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")))
    }
    
    return true
  }
  
  func setUpWakeUpArray(_ array:[String]) {
    for timeItem in array {
      if Int(timeItem) >= CHUIElements().getCurretnTime() {
        self.setUpScheduledLocalNotification("Wake up", alertBody: "Wake up & check your challenge list", timeInterval: Double(timeItem)!, type: "WakeUp")
      }
    }
  }
  
  func setUpScheduledLocalNotification(_ alertAction:String, alertBody:String, timeInterval:Double, type:String, wakeUpId:String = "") {
    let localNotification:UILocalNotification = UILocalNotification()
    localNotification.alertAction = alertAction 
    localNotification.alertBody   = alertBody
    localNotification.userInfo    = [
      "type": type,
      "wakeUpId": wakeUpId
    ]
    localNotification.fireDate    = Date(timeIntervalSince1970: timeInterval)
    localNotification.soundName   = "out.wav"
    UIApplication.shared.scheduleLocalNotification(localNotification)
  }
  
  func cleareScheduledNotifications() {
    let   app:UIApplication = UIApplication.shared
    for oneEvent in app.scheduledLocalNotifications! {
      let notification = oneEvent as UILocalNotification
      app.cancelLocalNotification(notification)
    }
  }
  
}
