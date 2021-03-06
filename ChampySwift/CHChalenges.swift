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
    case startedDuelStepCounter = "startedDuelStepCounter"
    case checkedForToday = "checkedForToday"
    case checkedForTodayStepCounter = "checkedForTodayStepCounter"
    case checkedSelfImprovementForToday = "checkedSelfImprovementForToday"
    case timedOutWakeUp = "timedOutWakeUp"
    case waitingForNextDayWakeUp = "waitingForNextDayWakeUp"
    case undefined = "undefined"
    case customStepCountingStarted = "customStepCountingStarted"
    case customStepCountingInProgress = "customStepCountingInProgress"
    case customStepCountingDone = "customStepCountingDone"
  }
  
  let maxChallengesCount = 30
  
  
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
  
  func getSelfImprovementStepCountingChallenges() -> [JSON] {
    var result:[JSON] = []
    let challenges = getAllSelfImprovementChallenges(CHSession().currentUserId)
    for item in challenges {
      if item["description"].stringValue == "customStepCounting" {
        result.append(item)
      }
    }
    
    
    return result
  }
  
  func isPossibleToCreateStepCountingSelfImprovementChallenge(numberOfDays:Int, numberOfSteps:Int) -> Bool {
    for item in getSelfImprovementStepCountingChallenges() {
      if item["details"].intValue == numberOfSteps && item["duration"].intValue == numberOfDays {
        return false
      }
    }
    
    
    return true
  }
  
  /**
   get All Self Improvement Challenges
   
   @param userId logged in user's object id
   
   @return array of self improvement challenges
   */
  func getAllSelfImprovementChallenges(_ userId:String, withStepCounting:Bool = true) -> [JSON] {
    var result:[JSON] = []
    for (_, item): (String, JSON) in CHSession().getJSONByKey("challenges") {
      guard item["type"]["_id"].stringValue == CHSettings().selfImprovementsId else {
        continue
      }
      
      guard item["approved"].boolValue && item["active"].boolValue else {
        continue
      }
      
      if item["description"].stringValue == "customStepCounting" && !withStepCounting {
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
  
  
  func canISendChallengeToTheFriend(friendId:String, challengeId:String) -> Bool {
    for item in self.getInProgressChallenges(CHSession().currentUserId) {
      if item["challenge"]["_id"].stringValue != challengeId {
        continue
      }
      if item["sender"]["_id"].stringValue == friendId || item["recipient"]["_id"].stringValue == friendId {
        if item["status"].stringValue == "pending" || item["status"].stringValue == "started" {
          return false
        }
      }
    }
    
    return true
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
    return CHSession().getJSONByKey("fails\(userId)").arrayValue
//    return getChalengeArrayByKyValueCombination(userId, value: false)
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
    if item["challenge"]["description"].stringValue == "customStepCounting" {
      return checkStepCountingTime(item: item)
//      return checkTime(item: item)
    } else {
      return checkTime(item: item)
    }
  }
  
  func checkStepCountingTime(item:JSON, key:String = "senderProgress") -> CHChallengeSubType {
    let currentDate = CHUIElements().getCurretnTime()
    let day = CHSettings().daysToSec(1)
    let currentMidnight = CHSettings().getMidnightOfTheDay(currentDate) //1479772801 + day//
    
    var lastCheck = item["created"].intValue
    
    if item[key].count == 0 {
      if currentMidnight - lastCheck > 0 && currentMidnight - lastCheck > day {
        CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
          
        })
      }
      return .customStepCountingStarted
    }
    
    
    if item[key].count > 0 {
      lastCheck = item[key][item[key].count - 1]["at"].intValue
    }
    
    if currentMidnight - lastCheck < 0 && currentMidnight - lastCheck > -1 * day {
      return .customStepCountingInProgress
    }
    
    if currentMidnight - lastCheck > 0 && currentMidnight - lastCheck < day {
      return .customStepCountingStarted
    }
    
    if currentMidnight - lastCheck > 0 && currentMidnight - lastCheck > day {
      CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
        
      })
    }
    return .customStepCountingStarted
  }
  
  func checkTime(item:JSON, key:String = "senderProgress") -> CHChallengeSubType {
    let currentDate = CHUIElements().getCurretnTime()
    let day = CHSettings().daysToSec(1)
    let currentMidnight = CHSettings().getMidnightOfTheDay(currentDate) //1479772801 + day//
    
    var lastCheck = item["created"].intValue
    
    if item[key].count == 0 {
      if currentMidnight - lastCheck > 0 && currentMidnight - lastCheck > day {
        CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
          
        })
      }
      return .startedSelfImprovement
    }
    
    
    if item[key].count > 0 {
      lastCheck = item[key][item[key].count - 1]["at"].intValue
    }
    
    if currentMidnight - lastCheck < 0 && currentMidnight - lastCheck > -1 * day {
      return .confirmedSelfImprovement
    }
    
    if currentMidnight - lastCheck > 0 && currentMidnight - lastCheck < day {
      return .startedSelfImprovement
    }
    
    if currentMidnight - lastCheck > 0 && currentMidnight - lastCheck > day {
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
      if item["challenge"]["description"].stringValue == "customStepCountingDuel" {
        return .startedDuelStepCounter
      } else {
        return .startedDuel
      }
    }
    
    checkMidnight = CHSettings().getMidnightOfTheDay(item[key][item[key].count - 1]["at"].intValue)
    
    if currentDate - checkMidnight > surrenderTime {
      CHRequests().surrender(item["_id"].stringValue, completitionHandler: { (result, json) in
        
      })
    }
    
    if (currentDate - checkMidnight < surrenderTime) && (currentDate - checkMidnight > borderTime) {
      if item["challenge"]["description"].stringValue == "customStepCountingDuel" {
        return .startedDuelStepCounter
      } else {
        return .startedDuel
      }
    }
    
    if item["challenge"]["description"].stringValue == "customStepCountingDuel" {
      return .checkedForTodayStepCounter
    } else {
      return .checkedForToday
    }
    
    
  }
  
  /**
   get Wake Up Type
   
   @param item JSON object of the selected in progress challenge
   
   @return CHChallengeSubType of Wake Up
   */
  func getWakeUpType(_ item:JSON) -> CHChallengeSubType {
    
    if item["status"].stringValue == "started" {
      let endTimeBorder = CHUIElements().getCurretnTime()
      let challenge = item["challenge"]
      let array = CHSettings().stringToArray(challenge["details"].stringValue.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "[", with: ""))
      let time:Int = Int(array[item["senderProgress"].count])!
      
      let gap = 300
      
      if endTimeBorder - time < 0 {
        return .waitingForNextDayWakeUp
      }
      
      if endTimeBorder - time > 0 && endTimeBorder - time < gap {
        CHRequests().checkChallenge(item["_id"].stringValue, completitionHandler: { (result, json) in
          if result {
            CHPush().localPush("refreshIcarousel", object: self)
            CHUIElements().playAudio()
            CHPush().alertPush("wake up challenge completed for today", type: "Success")
          }
        })
        return .waitingForNextDayWakeUp
      }
      
      if endTimeBorder - time > gap {
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
