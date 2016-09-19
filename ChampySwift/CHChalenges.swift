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
  
  
  /**
   get All Challenges
   
   @param userId logged in user's object id
   
   @return array of challenges
   */
  func getAllChallenges(userId:String) -> [JSON] {
    var result:[JSON] = []
    
    
    for (_, item): (String, JSON) in CHSession().getJSONByKey("challenges") {
      guard item["type"]["_id"].stringValue == CHSettings().duelsId else {
        continue
      }
      
      guard item["approved"].boolValue && item["active"].boolValue else {
        continue
      }
      
      if item["createdBy"].stringValue == CHSession().currentUserId || item["createdBy"] == nil {
        result.append(item)
      }
      
      
    }
    
    return result
  }
  
  /**
   get All Self Improvement Challenges
   
   @param userId logged in user's object id
   
   @return array of self improvement challenges
   */
  func getAllSelfImprovementChallenges(userId:String) -> [JSON] {
    var result:[JSON] = []
    for (_, item): (String, JSON) in CHSession().getJSONByKey("challenges") {
      guard item["type"]["_id"].stringValue == CHSettings().selfImprovementsId else {
        
        continue
      }
      
      guard item["approved"].boolValue && item["active"].boolValue else {
        continue
      }
      
      if item["createdBy"].stringValue == CHSession().currentUserId || item["createdBy"] == nil {
        result.append(item)
      }
    }
    
    return result
  }
  
  /**
   get In Progress Challenges
   
   @param userId logged in user's object id
   
   @return array of in progregress challenges
   */
  func getInProgressChallenges(userId:String) -> [JSON] {
    var result:[JSON] = []
    for (_, item): (String, JSON) in CHSession().getJSONByKey("inProgressChallenges\(userId)") {
      guard item["status"].stringValue != "finished" else {
        continue
      }
      
      guard item["status"].stringValue != "rejectedByRecipient" else {
        continue
      }
      
      guard item["status"].stringValue != "rejectedBySender" else {
        continue
      }
      
      guard item["status"].stringValue != "failedByRecipient" else {
        continue
      }
      
      guard item["status"].stringValue != "failedBySender" else {
        continue
      }
      result.append(item)
      
    }
    
    return result
  }
  
  /**
   get Win Challenges
   
   @param userId logged in user's object id
   @param value indicaor of [win, fail] => [true, false]
   
   @return array of win challenges
   */
  func getChalengeArrayByKyValueCombination(userId:String, value:Bool) -> [JSON] {
    var result:[JSON] = []
    for (_, item): (String, JSON) in CHSession().getJSONByKey("inProgressChallenges\(userId)") {
      
      switch userId {
      case item["sender"]["_id"].stringValue:
        guard item["senderSuccess"].boolValue == value else {
          continue
        }
        result.append(item)
        break
        
      case item["recipient"]["_id"].stringValue:
        guard item["recipientSuccess"].boolValue == value else {
          continue
        }
        result.append(item)
        break
      default: break
        
      }
      
    }
    
    return result
  }
  
  /**
   get Win Challenges
   
   @param userId logged in user's object id
   
   @return array of win challenges
   */
  func getWinChallenges(userId:String) -> JSON {
    return CHSession().getJSONByKey("wins\(userId)")
  }
  
  /**
   get Failed Challenges
   
   @param userId logged in user's object id
   
   @return array of failed challenges
   */
  func getFailedChallenges(userId:String) -> JSON {
    return CHSession().getJSONByKey("fails\(userId)")
  }
  
  /**
   check Duel By Owner Key
   
   @param item JSON object of the selected in progress challenge
   @param key String true or false
   
   @return CHChallengeSubType of the Duel
   */
  func checkDuelByOwnerKey(item:JSON, key:String) -> CHChallengeSubType {
    
    guard item[key].count > 0 else {
      return .startedDuel
    }
    
    guard CHUIElements().getCurretnTime() - item[key][item[key].count - 1]["at"].intValue <= 86400 else {
      return .startedDuel
    }
    
    return .checkedForToday
    
  }
  
  /**
   check Status Of the Started Duel
   
   @param item JSON object of the selected in progress challenge
   
   @return CHChallengeSubType of the Started Duel
   */
  func checkStatusOftheStartedDuel(item:JSON) -> CHChallengeSubType {
    
    switch CHSession().currentUserId {
    case item["recipient"]["_id"].stringValue:
      return self.checkDuelByOwnerKey(item, key: "recipientProgress")
    case item["sender"]["_id"].stringValue:
      return self.checkDuelByOwnerKey(item, key: "senderProgress")
    default:
      return .startedDuel
    }
    
    
  }
  
  /**
   get Self Improvement Status
   
   @param item JSON object of the selected in progress challenge
   
   @return CHChallengeSubType of Self Improvement
   */
  func getSelfImprovementStatus(item:JSON) -> CHChallengeSubType {
    let currentDate = CHUIElements().getCurretnTime()
    let borderTime = CHSettings().daysToSec(1)
    
    guard item["status"].stringValue == "started" else {
      return .startedSelfImprovement
    }
    
    guard item["senderProgress"].count > 0 else {
      if currentDate - item["created"].intValue > borderTime {
        CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
          
        })
      }
      return .startedSelfImprovement
    }
    
    let checkedDate = item["senderProgress"][item["senderProgress"].count - 1]["at"].intValue
    
    if currentDate - checkedDate <= borderTime {
      return .confirmedSelfImprovement
    }
    
    if currentDate - checkedDate > borderTime {
      CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
        
      })
    }
    
    
    
    return .startedSelfImprovement
  }
  
  /**
   get Wake Up Type
   
   @param item JSON object of the selected in progress challenge
   
   @return CHChallengeSubType of Wake Up
   */
  func getWakeUpType(item:JSON) -> CHChallengeSubType {
    
    if item["status"].stringValue == "started" {
      let endTimeBorder = CHUIElements().getCurretnTime()
      let beginTimeBorder = endTimeBorder - 30
      let challenge = item["challenge"]
      let array = CHSettings().stringToArray(challenge["details"].stringValue.stringByReplacingOccurrencesOfString("[", withString: "").stringByReplacingOccurrencesOfString("]", withString: ""))
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
  
  /**
   get Sender Or Recipiend Duel Status
   
   @param item JSON object of the selected in progress challenge
   
   @return CHChallengeSubType of sender or recipient
   */
  func getSenderOrRecipiendDuelStatus(item:JSON) -> CHChallengeSubType {
    switch CHSession().currentUserId {
    case item["sender"]["_id"].stringValue:
      return .unconfirmedDuelSender
    case item["recipient"]["_id"].stringValue:
      return .unconfirmedDuelRecipient
    default:
      return .undefined
    }
  }
  
  /**
   Get all challengeType by item
   
   @param item JSON object of the selected in progress challenge
   
   @return CHChallengeSubType
   */
  func getChallengeType(item:JSON) -> CHChallengeSubType {
    
    switch item["challenge"]["type"].stringValue {
    case CHSettings().duelsId:
      guard item["status"].stringValue != "pending" else {
        return getSenderOrRecipiendDuelStatus(item)
      }
      
      guard item["status"].stringValue != "started" else {
        return checkStatusOftheStartedDuel(item)
      }
      return .undefined
    case CHSettings().selfImprovementsId:
      return self.getSelfImprovementStatus(item)
    case CHSettings().wakeUpIds:
      return self.getWakeUpType(item)
    default:
      return .undefined
    }
  }
  
  /**
   Get all active wake-upchallenges
   
   @param userId logged in user's object id
   
   @return array of wakeupchallenges
   */
  func getAllActiveWakeUpChallenges(userId:String) -> [JSON] {
    var result:[JSON] = []
    for (_, item): (String, JSON) in CHSession().getJSONByKey("inProgressChallenges\(userId)")  {
      guard item["challenge"]["type"].stringValue == CHSettings().wakeUpIds else {
        continue
      }
      
      guard item["status"].stringValue != "finished" else {
        continue
      }
      
      guard item["status"].stringValue != "rejectedByRecipient" else {
        continue
      }
      
      guard item["status"].stringValue != "rejectedBySender" else {
        continue
      }
      
      guard item["status"].stringValue != "failedByRecipient" else {
        continue
      }
      
      guard item["status"].stringValue != "failedBySender" else {
        continue
      }
      result.append(item)
      
      
    }
    
    return result
  }
  
}
