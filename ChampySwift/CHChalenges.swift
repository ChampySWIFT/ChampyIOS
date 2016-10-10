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
  
  let maxChallengesCount = 5
  
  
  /**
   get All Challenges
   
   @param userId logged in user's object id
   
   @return array of challenges
   */
  func getAllChallenges(_ userId:String) -> [JSON] {
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
  func getAllSelfImprovementChallenges(_ userId:String) -> [JSON] {
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
  func getInProgressChallenges(_ userId:String) -> [JSON] {
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
  
  
  
  func surrenderAllInProgressChallengesWithThisFriend(_ userId:String) {
    for item in self.getInProgressChallenges(CHSession().currentUserId) {
      if item["sender"]["_id"].stringValue == userId || item["recipient"]["_id"].stringValue == userId {
          CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
            
          })
      }
    }
  }
  
  func surrenderAllInProgressChallenges(_ completitionHandler:(_ end:Bool) -> ()) {
    for (_, item): (String, JSON) in CHSession().getJSONByKey("inProgressChallenges\(CHSession().currentUserId)") {
      
      CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
        
      })
      
    }
    
    completitionHandler(true)
  }
  
  func isThereStartedChallengesWith() -> Bool {
    
    
    
    return true
  }
  
  /**
   get Win Challenges
   
   @param userId logged in user's object id
   @param value indicaor of [win, fail] => [true, false]
   
   @return array of win challenges
   */
  func getChalengeArrayByKyValueCombination(_ userId:String, value:Bool) -> [JSON] {
    var result:[JSON] = []
    for (_, item): (String, JSON) in CHSession().getJSONByKey("inProgressChallenges\(userId)") {
      
      switch userId {
      case item["sender"]["_id"].stringValue:
        if item["senderSuccess"].boolValue == value {
          result.append(item)
          continue
        }
        break
        
      case item["recipient"]["_id"].stringValue:
        if item["recipientSuccess"].boolValue == value {
          result.append(item)
          continue
        }
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
  func getWinChallenges(_ userId:String) -> [JSON] {
    return getChalengeArrayByKyValueCombination(userId, value: true)
  }
  
  /**
   get Failed Challenges
   
   @param userId logged in user's object id
   
   @return array of failed challenges
   */
  func getFailedChallenges(_ userId:String) -> [JSON] {
    return getChalengeArrayByKyValueCombination(userId, value: false)
  }
  
  
  
  /**
   check Status Of the Started Duel
   
   @param item JSON object of the selected in progress challenge
   
   @return CHChallengeSubType of the Started Duel
   */
  func checkStatusOftheStartedDuel(_ item:JSON) -> CHChallengeSubType {
    
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
  func getSelfImprovementStatus(_ item:JSON) -> CHChallengeSubType {
    let currentDate = CHUIElements().getCurretnTime()
    let surrenderTime = CHSettings().daysToSec(2)
    let borderTime = CHSettings().daysToSec(1)
    var checkMidnight = 0
    guard item["status"].stringValue == "started" else {
      return .startedSelfImprovement
    }
    
    guard item["senderProgress"].count > 0 else {
      checkMidnight = CHSettings().getMidnightOfTheDay(item["created"].intValue)
      
      if currentDate - item["created"].intValue > surrenderTime {
        CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
          
        })
      }
      return .startedSelfImprovement
    }
    
    checkMidnight = CHSettings().getMidnightOfTheDay(item["senderProgress"][item["senderProgress"].count - 1]["at"].intValue)
    
    
    if currentDate - checkMidnight <= borderTime {
      return .confirmedSelfImprovement
    }
    
    if currentDate - checkMidnight > borderTime {
      CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
        
      })
    }
    
    
    
    return .startedSelfImprovement
  }
  
  /**
   check Duel By Owner Key
   
   @param item JSON object of the selected in progress challenge
   @param key String true or false
   
   @return CHChallengeSubType of the Duel
   */
  func checkDuelByOwnerKey(_ item:JSON, key:String) -> CHChallengeSubType {
    let currentDate = CHUIElements().getCurretnTime()
    let surrenderTime = CHSettings().daysToSec(2)
    let borderTime = CHSettings().daysToSec(1)
    var checkMidnight = 0
    
    guard item[key].count > 0 else {
      checkMidnight = CHSettings().getMidnightOfTheDay(item["created"].intValue)
      
      if currentDate - item["created"].intValue > surrenderTime {
        CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
          
        })
      }
      return .startedDuel
    }
    
    checkMidnight = CHSettings().getMidnightOfTheDay(item[key][item[key].count - 1]["at"].intValue)
    
    if currentDate - checkMidnight > surrenderTime {
      CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
        
      })
    }
    
    if (currentDate - checkMidnight < surrenderTime) && (currentDate - checkMidnight > borderTime) {
      return .startedDuel
    }
    
    return .checkedForToday
    
  }
  
  /**
   get Wake Up Type
   
   @param item JSON object of the selected in progress challenge
   
   @return CHChallengeSubType of Wake Up
   */
  func getWakeUpType(_ item:JSON) -> CHChallengeSubType {
    
    if item["status"].stringValue == "started" {
      let endTimeBorder = CHUIElements().getCurretnTime()
      let beginTimeBorder = endTimeBorder - 30
      let challenge = item["challenge"]
      let array = CHSettings().stringToArray(challenge["details"].stringValue.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "[", with: ""))
      let time:Int = Int(array[item["senderProgress"].count])!
      
      
      if endTimeBorder - time < 0 {
        return .waitingForNextDayWakeUp
      }
      
      if endTimeBorder - time > 0 && endTimeBorder - time < 30 {
        CHRequests().checkChallenge(item["_id"].stringValue, completitionHandler: { (result, json) in
          if result {
            CHPush().localPush("refreshIcarousel", object: self)
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
            CHPush().localPush("refreshIcarousel", object: self)
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
  func getSenderOrRecipiendDuelStatus(_ item:JSON) -> CHChallengeSubType {
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
  func getChallengeType(_ item:JSON) -> CHChallengeSubType {
    
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
  func getAllActiveWakeUpChallenges(_ userId:String) -> [JSON] {
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
