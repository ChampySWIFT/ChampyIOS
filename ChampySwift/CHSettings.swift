//
//  CHSettings.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/17/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit

class CHSettings: NSObject {
  let duelsId: String  = "567d51c48322f85870fd931b"
  let wakeUpIds: String  = "567d51c48322f85870fd931c"
  let selfImprovementsId: String = "567d51c48322f85870fd931a"
  let dateFormatter = NSDateFormatter()
  
  func clearViewArray(array:[UIView]) {
    for item in array {
      item.removeFromSuperview()
    }
  }
  
  func daysToSec(days:Int) -> Int {
    return days * 24 * 60 * 60
  }
  
  func secToDays(sec:Int) -> Int {
    return sec / 24 / 60 / 60
  }
  
  func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
  }
  
  func timeStringFromUnixTime(unixTime: Double) -> String {
    let date = NSDate(timeIntervalSince1970: unixTime)
    
    // Returns date formatted as 12 hour time.
    dateFormatter.dateFormat = "hh:mm a"
    return dateFormatter.stringFromDate(date)
  }
  
  func dayStringFromTime(unixTime: Double) -> String {
    let date = NSDate(timeIntervalSince1970: unixTime)
    dateFormatter.locale = NSLocale(localeIdentifier: NSLocale.currentLocale().localeIdentifier)
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.stringFromDate(date)
  }
  
}
