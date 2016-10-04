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
  
  let dateFormatter = DateFormatter()
  
  func clearViewArray(_ array:[UIView]) {
    for item in array {
      item.removeFromSuperview()
    }
  }
  
  func daysToSec(_ days:Int) -> Int {
    return days * 24 * 60 * 60
  }
  
  func secToDays(_ sec:Int) -> Int {
    return sec / 24 / 60 / 60
  }
  
  func secondsToHoursMinutesSeconds (_ seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
  }
  
  func stringToArray(_ stringObject:String)->[String]{
    var str = stringObject
    str = str.substring(with: (str.characters.index(str.startIndex, offsetBy: 0) ..< str.characters.index(str.endIndex, offsetBy: 0)))
    let resultArray = str.components(separatedBy: ", ")
    return resultArray
  }
  
  func getMidnightOfTheDay(_ dateInSec:Int) -> Int {
    let date = Date(timeIntervalSince1970: Double(dateInSec))
    let dateFormatter = DateFormatter()
    let calendar = Calendar.current
    let comp = (calendar as NSCalendar).components([.hour, .minute, .second], from: date)
    let hour = comp.hour
    let minute = comp.minute
    let sec = comp.second
    
    
    
    let minuteMinSec = Int(minute! * 60) - sec!
    return dateInSec - Int(hour! * 3600 ) - minuteMinSec
  }
  
  func facebookFriendsStringToArray(_ stringObject:String)->[String]{
    var fullName: String = stringObject
    fullName = fullName.replacingOccurrences(of: "\"", with: "", options: NSString.CompareOptions.literal, range: nil)
    fullName = fullName.replacingOccurrences(of: "[", with: "", options: NSString.CompareOptions.literal, range: nil)
    fullName = fullName.replacingOccurrences(of: "]", with: "", options: NSString.CompareOptions.literal, range: nil)
    let fullNameArr = fullName.components(separatedBy: ", ")
    return fullNameArr
    
//    let str = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(0), end: str.endIndex.advancedBy(0)))
//    let resultArray = str.componentsSeparatedByString(", ")
//    return resultArray
  }
}
