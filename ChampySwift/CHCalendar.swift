//
//  CHCalendar.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/30/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit

class CHCalendar: NSObject {

  func getLocalNtificatorTimesForSelfImprovement(numberOfDays:Int = 21, notifTimeInHours:Int = 12) -> [Int] {
    var array:[Int] = []
    
    for i:Int in 0...numberOfDays {
      
      let dateSec = CHUIElements().getCurretnTime()
      let date = NSDate(timeIntervalSince1970: Double(dateSec))
      
      
      let calendar = NSCalendar.currentCalendar()
      let comp = calendar.components([.Hour, .Minute, .Second], fromDate: date)
      let hour = comp.hour
      let minute = comp.minute
      let second = comp.second
      
      let clearDate = dateSec - hour - minute - second + (notifTimeInHours * 60 * 60)
      array.append(clearDate + CHSettings().daysToSec(i))
    }
    
    return array
  }
  
  
  func getLocalNotificatorTimesByCreatedtime(createdTime:Double, numberOfDays:Int = 21, notifTimeInHours:Int = 12) -> [Int] {
    var array:[Int] = []
    
    for i:Int in 0...numberOfDays {
      
      let dateSec = Int(createdTime)
      let date = NSDate(timeIntervalSince1970: Double(dateSec))
      
      
      let calendar = NSCalendar.currentCalendar()
      let comp = calendar.components([.Hour, .Minute, .Second], fromDate: date)
      let hour = comp.hour
      let minute = comp.minute
      let second = comp.second
      
      let clearDate = dateSec - (hour * 60 * 60) - (minute * 60) - second + (notifTimeInHours * 60 * 60)
      array.append(clearDate + CHSettings().daysToSec(i))
    }
    
    return array
  }
  
}
