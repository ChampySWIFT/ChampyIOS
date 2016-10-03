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
  
  func stringToArray(stringObject:String)->[String]{
    var str = stringObject
    str = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(0), end: str.endIndex.advancedBy(0)))
    let resultArray = str.componentsSeparatedByString(", ")
    return resultArray
  }
  
  func getMidnightOfTheDay(dateInSec:Int) -> Int {
    let date = NSDate(timeIntervalSince1970: Double(dateInSec))
    let dateFormatter = NSDateFormatter()
    let calendar = NSCalendar.currentCalendar()
    let comp = calendar.components([.Hour, .Minute, .Second], fromDate: date)
    let hour = comp.hour
    let minute = comp.minute
    let sec = comp.second
    
    print(dateInSec)
    print(hour)
    print(minute)
    print(sec)
    
    
    
    return dateInSec - Int(hour * 60 * 60) - Int(minute * 60) - sec
  }
  
  func facebookFriendsStringToArray(stringObject:String)->[String]{
    var fullName: String = stringObject
    fullName = fullName.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    fullName = fullName.stringByReplacingOccurrencesOfString("[", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    fullName = fullName.stringByReplacingOccurrencesOfString("]", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    let fullNameArr = fullName.componentsSeparatedByString(", ")
    return fullNameArr
    
//    let str = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(0), end: str.endIndex.advancedBy(0)))
//    let resultArray = str.componentsSeparatedByString(", ")
//    return resultArray
  }
}
