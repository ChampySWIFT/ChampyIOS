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
    
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
  }
  
  func setUpWakeUp()  {
    
    self.cleareScheduledNotifications()
    let generalArray = CHChalenges().getInProgressChallenges(CHSession().currentUserId)
    
    if generalArray.count > 0 {
      let innerArray = CHCalendar().getLocalNotificatorTimesByCreatedtime(Double(CHUIElements().getCurretnTime()), numberOfDays: 21, notifTimeInHours: 12)
      schduleReminder()
    }
    
    for item in CHChalenges().getAllActiveWakeUpChallenges(CHSession().currentUserId) {
      if  item["challenge"]["type"].stringValue == CHSettings().wakeUpIds {
        let array = self.stringToArray(item["challenge"]["details"].stringValue.stringByReplacingOccurrencesOfString("[", withString: "").stringByReplacingOccurrencesOfString("]", withString: ""))
        print("\(array)")
        self.setUpWakeUp(array)
      }
    }
    
    
  }
  
  
  
  func setUpWakeUp(array:[String]) {
    for timeItem in array {
      if Int(timeItem) >= CHUIElements().getCurretnTime() {
        self.setUpScheduledLocalNotification("Wake up", alertBody: "Wake up & check your challenge list", timeInterval: Double(timeItem)!, type: "WakeUp")
      }
    }
  }
  
  func stringToArray(stringObject:String)->[String]{
    var str = stringObject
    str = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(0), end: str.endIndex.advancedBy(0)))
    let resultArray = str.componentsSeparatedByString(", ")
    return resultArray
  }
  
  func setUpScheduledLocalNotification(alertAction:String, alertBody:String, timeInterval:Double, type:String, wakeUpId:String = "") {
    let localNotification:UILocalNotification = UILocalNotification()
    localNotification.alertAction = alertAction
    localNotification.alertBody   = alertBody
    localNotification.userInfo    = [
      "type": type,
      "wakeUpId": wakeUpId
    ]
//    localNotification.category = "type"
//    localNotification.identifi
    localNotification.fireDate    = NSDate(timeIntervalSince1970: timeInterval)
    localNotification.soundName   = "out.caf" //UILocalNotificationDefaultSoundName;
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
  }
  
  
  func example() {
    let localNotification:UILocalNotification = UILocalNotification()
    localNotification.alertAction = "sd"
    localNotification.alertBody   = "asd"
    localNotification.userInfo    = [
      "type": "asd",
      "wakeUpId": "asd"
    ]
    localNotification.fireDate    = NSDate(timeIntervalSince1970: Double(CHUIElements().getCurretnTime() + 5))
    localNotification.soundName   = "out.caf" //UILocalNotificationDefaultSoundName;
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
  }
  
  func setUpNotifForSelfImprovementChallenge(alertAction:String, alertBody:String, timeInterval:Double, type:String, wakeUpId:String = "") {
    let localNotification:UILocalNotification = UILocalNotification()
    localNotification.alertAction = alertAction
    localNotification.alertBody   = alertBody
    localNotification.userInfo    = [
      "type": type,
      "wakeUpId": wakeUpId
    ]
    localNotification.fireDate    = NSDate(timeIntervalSince1970: timeInterval)
    localNotification.soundName   = "out.caf" //UILocalNotificationDefaultSoundName;
    UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
  }
  
  func setUpNotifForDuelChallenge(alertAction:String, alertBody:String, timeInterval:Double, type:String, wakeUpId:String = "") {
    let localNotification:UILocalNotification = UILocalNotification()
    localNotification.alertAction = alertAction
    localNotification.alertBody   = alertBody
    localNotification.userInfo    = [
      "type": type,
      "wakeUpId": wakeUpId
    ]
    localNotification.fireDate    = NSDate(timeIntervalSince1970: timeInterval)
    localNotification.soundName   = UILocalNotificationDefaultSoundName;
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
