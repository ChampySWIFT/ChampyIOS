//
//  CHWakeUpper.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/27/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON

class CHWakeUpper: NSObject {
  
  func schduleReminder() {
    let calendar: NSCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
    var dateFire=NSDate()
    
    let fireComponents=calendar.components([.Day, .Month, .Year, .Hour, .Minute] , fromDate:dateFire)
    
    fireComponents.hour = 12
    fireComponents.minute = 00
    
    
    dateFire = calendar.dateFromComponents(fireComponents)!
    
    let localNotification = UILocalNotification()
    localNotification.fireDate = dateFire
    localNotification.alertBody = "Hey! Looks like you still have some challenges for today."
    localNotification.repeatInterval = .Day
    localNotification.soundName   = UILocalNotificationDefaultSoundName //"out.wav"
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
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
      self.setUpWakeUpArray(CHSettings().stringToArray(item["challenge"]["details"].stringValue.stringByReplacingOccurrencesOfString("[", withString: "").stringByReplacingOccurrencesOfString("]", withString: "")))
    }
    
    return true
  }
  
  func setUpWakeUpArray(array:[String]) {
    for timeItem in array {
      if Int(timeItem) >= CHUIElements().getCurretnTime() {
        self.setUpScheduledLocalNotification("Wake up", alertBody: "Wake up & check your challenge list", timeInterval: Double(timeItem)!, type: "WakeUp")
      }
    }
  }
  
  func setUpScheduledLocalNotification(alertAction:String, alertBody:String, timeInterval:Double, type:String, wakeUpId:String = "") {
    let localNotification:UILocalNotification = UILocalNotification()
    localNotification.alertAction = alertAction 
    localNotification.alertBody   = alertBody
    localNotification.userInfo    = [
      "type": type,
      "wakeUpId": wakeUpId
    ]
    localNotification.fireDate    = NSDate(timeIntervalSince1970: timeInterval)
    localNotification.soundName   = "out.wav"
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
  }
  
  func cleareScheduledNotifications() {
    let   app:UIApplication = UIApplication.sharedApplication()
    for oneEvent in app.scheduledLocalNotifications! {
      let notification = oneEvent as UILocalNotification
      app.cancelLocalNotification(notification)
    }
  }
  
}
