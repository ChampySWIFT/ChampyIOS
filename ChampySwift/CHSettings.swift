//
//  CHSettings.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/17/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import HealthKit

enum CHBuildType: String {
  case production     = "3007"
  case stage          = "3005"
  case development    = "3006"
  case Default        = "Default"
}

enum CHApiUrl: String {
  case remote = "http://46.101.213.24"
  case local  = "http://192.168.88.28"
}

enum CHLegalPages: String {
  case privacyUrl = "http://champyapp.com/privacy-policy.html"
  case termUrl    = "http://champyapp.com/terms.html"
}



class CHSettings: NSObject {
  fileprivate var steps = [HKQuantitySample]()
  let healthStore: HKHealthStore? = {
    if HKHealthStore.isHealthDataAvailable() {
      return HKHealthStore()
    } else {
      return nil
    }
  }()
  
  let storage: HKHealthStore? = {
    if HKHealthStore.isHealthDataAvailable() {
      return HKHealthStore()
    } else {
      return nil
    }
  }()
  
  var duelsId: String             = "567d51c48322f85870fd931b"
  var wakeUpIds: String           = "567d51c48322f85870fd931c"
  var selfImprovementsId: String  = "567d51c48322f85870fd931a"
  
  let dateFormatter = DateFormatter()
  
  
  override init() {
    if CHRequests.APIurl == "\(CHApiUrl.local.rawValue):\(3006)/v1" {
      duelsId = "58788f28c3e419a11d185fdb"
      wakeUpIds = "58788f8e50ccc97f1e96c146"
      selfImprovementsId = "58788f37c3e419a11d185fdc"
      return
    }
    
    switch CHRequests.port {
    case "3006" :
      duelsId = "5878904fba69167b3785b469"
      wakeUpIds = "587e15ec10b9dd184f09546a"
      selfImprovementsId = "587e15de10b9dd184f095469"
      break
      
    case "3007" :
      duelsId = "567d51c48322f85870fd931b"
      wakeUpIds = "567d51c48322f85870fd931c"
      selfImprovementsId = "567d51c48322f85870fd931a"
      break
    default:
      duelsId = "567d51c48322f85870fd931b"
      wakeUpIds = "567d51c48322f85870fd931c"
      selfImprovementsId = "567d51c48322f85870fd931a"
        
      break
    }
  }
  
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
  }
  
  func refreshStepCount() {
    
  }
  
}
