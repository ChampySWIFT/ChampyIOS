//
//  CHChalenges.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/17/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
class CHChalenges: NSObject {
  
  enum CHChallengeSubType: String {
    case unconfirmedDuelRecipient    = "unconfirmedDuelRecipient"
    case unconfirmedDuelSender = "unconfirmedDuelSender"
    case startedSelfImprovement = "startedSelfImprovement"
    case confirmedSelfImprovement = "confirmedSelfImprovement"
    case wakeUpChallenge = "wakeUpChallenge"
    case startedDuel = "startedDuel"
    case checkedForToday = "checkedForToday"
    case checkedSelfImprovementForToday = "checkedSelfImprovementForToday"
    case timedOutWakeUp = "timedOutWakeUp"
    case waitingForNextDayWakeUp = "waitingForNextDayWakeUp"
    case undefined = "undefined"
    
  }
  
  
  func getAllChallenges(userId:String) -> [JSON] {
    var result:[JSON] = []
    if CHSession().CurrentUser.objectForKey("challenges") != nil {
      let challenges = CHUIElements().stringToJSON(CHSession().CurrentUser.stringForKey("challenges")!)
      for (_, item): (String, JSON) in challenges {
        if item["type"]["_id"].stringValue == CHSettings().duelsId && item["approved"].boolValue && item["active"].boolValue {
          if item["createdBy"] == nil {
            result.append(item)
          }
          
          if item["createdBy"].stringValue == CHSession().currentUserId {
            result.append(item)
          }
          
        }
      }
      return result
    }
    
    return []
  }
  
  func getAllSelfImprovementChallenges(userId:String) -> [JSON] {
    var result:[JSON] = []
    if CHSession().CurrentUser.objectForKey("challenges") != nil {
      let challenges = CHUIElements().stringToJSON(CHSession().CurrentUser.stringForKey("challenges")!)
      for (_, item): (String, JSON) in challenges {
        if item["type"]["_id"].stringValue == CHSettings().selfImprovementsId && item["approved"].boolValue && item["active"].boolValue {
          if item["createdBy"] == nil {
            result.append(item)
          }
          
          if item["createdBy"].stringValue == CHSession().currentUserId {
            result.append(item)
          }
        }
      }
      return result
    }
    
    return []
  }
  
  func getInProgressChallenges(userId:String) -> [JSON] {
    var result:[JSON] = []
    if CHSession().CurrentUser.objectForKey("inProgressChallenges\(userId)") != nil {
      let challenges = CHUIElements().stringToJSON(CHSession().CurrentUser.stringForKey("inProgressChallenges\(userId)")!)
      for (_, item): (String, JSON) in challenges {
        if item["status"].stringValue != "finished" {
          if item["status"].stringValue != "rejectedByRecipient" && item["status"].stringValue != "failedByRecipient" && item["status"].stringValue != "rejectedBySender" && item["status"].stringValue != "failedBySender"  {
            result.append(item)
          }
        }
      }
      return result
    }
    
    return []
  }
  
  func getWinChallenges(userId:String) -> [JSON] {
    var result:[JSON] = []
    if CHSession().CurrentUser.objectForKey("inProgressChallenges\(userId)") != nil {
      let challenges = CHUIElements().stringToJSON(CHSession().CurrentUser.stringForKey("inProgressChallenges\(userId)")!)
      for (_, item): (String, JSON) in challenges {
        if item["sender"]["_id"].stringValue == userId && item["senderSuccess"].boolValue {
          result.append(item)
        }
        
        if item["recipient"]["_id"].stringValue == userId && item["recipientSuccess"].boolValue {
          result.append(item)
        }
      }
      return result
    }
    
    return []
  }
  
  func getFailedChallenges(userId:String) -> [JSON] {
    var result:[JSON] = []
    if CHSession().CurrentUser.objectForKey("inProgressChallenges\(userId)") != nil {
      let challenges = CHUIElements().stringToJSON(CHSession().CurrentUser.stringForKey("inProgressChallenges\(userId)")!)
      for (_, item): (String, JSON) in challenges {
        if item["status"].stringValue != "finished" {
          var keyWord = ""
          if item["sender"]["_id"].stringValue == userId && item["status"].stringValue == "failedBySender" {
            result.append(item)
          }
          
          if item["recipient"]["_id"].stringValue == userId && item["status"].stringValue == "failedByRecipient" {
            result.append(item)
          }
        }
      }
      return result
    }
    
    return []
  }
  
  //86400
  func checkStatusOftheStartedDuel(item:JSON) -> CHChallengeSubType {
    if item["recipient"]["_id"].stringValue == CHSession().currentUserId {
      if item["recipientProgress"].count > 0  {
        let progressArray = item["recipientProgress"]
        let progressObject = progressArray[progressArray.count - 1]
        let currentDate = Int(NSDate().timeIntervalSince1970)
        let checkedDate = progressObject["at"].intValue
        
        if currentDate - checkedDate <= 86400 {
          return .checkedForToday
        }
        
        return .startedDuel
      }
      
      return .startedDuel
    }
    
    if item["sender"]["_id"].stringValue == CHSession().currentUserId {
      if item["senderProgress"].count > 0  {
        let progressArray = item["senderProgress"]
        let progressObject = progressArray[progressArray.count - 1]
        let currentDate = Int(NSDate().timeIntervalSince1970)
        let checkedDate = progressObject["at"].intValue
        
        if currentDate - checkedDate <= 86400 {
          return .checkedForToday
        }
        
        return .startedDuel
      }
      
      return .startedDuel
    }
    
    return .startedDuel
  }
  
  func getSelfImprovementStatus(item:JSON) -> CHChallengeSubType {
    let currentDate = CHUIElements().getCurretnTime()
    if item["status"].stringValue == "started" {
      if item["senderProgress"].count > 0  {
        let progressArray = item["senderProgress"]
        let progressObject = progressArray[progressArray.count - 1]
        let checkedDate = progressObject["at"].intValue
        
        
        
        if currentDate - checkedDate <= CHSettings().daysToSec(1) {
          return .confirmedSelfImprovement
        }
        
        if currentDate - checkedDate > CHSettings().daysToSec(1) {
          CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
            
          })
        }
        
        
        
        return .startedSelfImprovement
      } else {
        let checkedDate = item["created"].intValue
        
        if currentDate - checkedDate > CHSettings().daysToSec(1) {
          CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
            
          })
        }
        
      }
      
      return .startedSelfImprovement
    }
    
    return .startedSelfImprovement
  }
  
  func getWakeUpType(item:JSON) -> CHChallengeSubType {
    
    if item["status"].stringValue == "started" {
      let endTimeBorder = CHUIElements().getCurretnTime()
      let beginTimeBorder = endTimeBorder - 30
      let challenge = item["challenge"]
      let array = CHWakeUpper().stringToArray(challenge["details"].stringValue.stringByReplacingOccurrencesOfString("[", withString: "").stringByReplacingOccurrencesOfString("]", withString: ""))
      let time:Int = Int(array[item["senderProgress"].count])!
      
      
      if endTimeBorder - time < 0 {
        return .waitingForNextDayWakeUp
      }
      
      if endTimeBorder - time > 0 && endTimeBorder - time < 30 {
        CHRequests().checkChallenge(item["_id"].stringValue, completitionHandler: { (result, json) in
          if result {
            CHPush().localPush("refreshIcarousel", object: [])
            CHUIElements().playAudio()
            CHPush().alertPush("wake up challenge completed for today", type: "Success")
          }
        })
        return .waitingForNextDayWakeUp
      }
      
      if endTimeBorder - time > 30 {
        CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
          if result {
            CHPush().alertPush("failed a wake up challenge", type: "Success")
            CHPush().localPush("refreshIcarousel", object: [])
          }
          
        })
        return .timedOutWakeUp
      }
      
      
      
    }
    
    return .wakeUpChallenge
  }
  
  
  func getChallengeType(item:JSON) -> CHChallengeSubType {
    if item["challenge"]["type"].stringValue == CHSettings().duelsId {
      if item["status"].stringValue == "pending" {
        
        if item["sender"]["_id"].stringValue == CHSession().currentUserId {
          return .unconfirmedDuelSender
        }
        
        if item["recipient"]["_id"].stringValue == CHSession().currentUserId {
          return .unconfirmedDuelRecipient
        }
      }
      
      if item["status"].stringValue == "started" {
        return checkStatusOftheStartedDuel(item)
      }
      
    }
    
    if item["challenge"]["type"].stringValue == CHSettings().selfImprovementsId  {
      return getSelfImprovementStatus(item)
    }
    
    if item["challenge"]["type"].stringValue == CHSettings().wakeUpIds && item["status"].stringValue == "started" {
      return self.getWakeUpType(item)
    }
    
    return .undefined
  }
  
  
  
  
  func getAllActiveWakeUpChallenges(userId:String) -> [JSON] {
    var result:[JSON] = []
    if CHSession().CurrentUser.objectForKey("inProgressChallenges\(userId)") != nil {
      let challenges = CHUIElements().stringToJSON(CHSession().CurrentUser.stringForKey("inProgressChallenges\(userId)")!)
      for (_, item): (String, JSON) in challenges {
        if item["challenge"]["type"].stringValue == CHSettings().wakeUpIds {
          if item["status"].stringValue != "finished" {
            if item["status"].stringValue != "rejectedByRecipient" && item["status"].stringValue != "failedByRecipient" && item["status"].stringValue != "rejectedBySender" && item["status"].stringValue != "failedBySender"  {
              result.append(item)
            }
          }
        }
      }
      return result
    }
    
    return []
  }
  
}
