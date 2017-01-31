
//
//  CHRequests.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftHTTP
import SwiftyJSON
import Async




class CHRequests: NSObject {
  //Api URL without the port
  static var apinetwork:String = CHApiUrl.remote.rawValue
  
  //Api port
  static var port:String = CHBuildType.development.rawValue
  
  //The full API url
  static var APIurl:String = "\(apinetwork):\(port)/v1"
  
  //API URL for socket connection
  static var SocketUrl:String = "\(apinetwork):\(port)"
  
  // privacy URL for webViews
  static var privacyUrl:String = CHLegalPages.privacyUrl.rawValue
  
  // terms and conditions URL
  static var termsUrl:String = CHLegalPages.privacyUrl.rawValue
  
  // acccess token parameter
  var token:String    = ""
  
  //additional checker for checking the status of the internet connection
  var canPerform:Bool = true
  
  //calss initialization, setting up the access token
  override init() {
    guard IJReachability.isConnectedToNetwork() else {
      canPerform = false
      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    }
    self.token = CHSession().getToken()
    
  }
  
  // getting token fot est classes
  func getTokenForTests() {
    guard IJReachability.isConnectedToNetwork() else {
      canPerform = false
      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    }
    self.token = CHSession().getToken()
  }
  
  //This method allows to retrieve user profile by token
  func checkUser(_ ownerId:String, completitionHandler:@escaping (_ json:JSON, _ status:Bool) -> ()) {
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(ownerId)?token=\(self.token)"
    let operationQueue = OperationQueue()
    
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(json["description"], false)
          return
        }
        completitionHandler(json["data"], true)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(nil, false)
    }
  }
  
  //  This method allows to create new user profile
  //  facebookId	String User facebook ID
  //
  //  name	String User given name
  //
  //  email optional	String User email
  func createUser(_ params:[String:String], completitionHandler:@escaping (_ json:JSON, _ status:Bool) -> ()){
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url:String = "\(CHRequests.APIurl)/users"
    print(url)
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          self.reloginUser(params["facebookId"]!, completitionHandler: { (responseJSON, status) in
            if status {
              completitionHandler(responseJSON["data"], true)
              //              CHUsers().localCreateUser(params["facebookId"]!, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
              
            } else {
              completitionHandler(responseJSON["data"], false)
            }
          })
          return
        }
         CHUsers().localCreateUser(params["facebookId"]!, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
        CHPush().subscribeForNotifications()
        
        CHRequests().uploadUsersPhoto(json["data"]["_id"].stringValue, image: CHRequests().getFacebookImageById(params["facebookId"]!), completitionHandler: { (result, json) in
          completitionHandler(json["data"], true)
        })
        
        
        
        
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(nil, false)
    }
  }
  
  //  token	String
  //  Access token
  //
  //  name	String
  //  Challenge name
  //
  //  type	String
  //  ID of challenge type
  //
  //  description	String
  //  challenge description
  //
  //  details	String
  //  details
  //
  //  duration	Number
  //  duration
  func createChallengeAndSendIt(_ recipientId:String, params:[String:String], completitionHandler:@escaping (_ json:JSON, _ status:Bool) -> ()){
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url:String = "\(CHRequests.APIurl)/challenges?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          completitionHandler(json, false)
          return
        }
        
        let params1:[String:String] = [
          "recipient" : recipientId,
          "challenge" : json["data"]["_id"].stringValue
        ]
        
        
        self.createDuelInProgressChallenge(params1, completitionHandler: { (secresult, secjson) in
          completitionHandler(secjson, secresult)
        })
        
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(nil, false)
    }
  }
  
  
  func cleareBadgeNumber(_ userId:String, completitionHandler:@escaping (_ json:JSON, _ status:Bool) -> ()){
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url:String = "\(CHRequests.APIurl)/users/\(userId)/clearebadgenumber?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        ////   
        if let _ = response.error {
          completitionHandler(json, false)
          return
        }
        UIApplication.shared.applicationIconBadgeNumber = json["data"]["badge"].intValue
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(nil, false)
    }
  }
  
  //  This method allows to retrieve user profile by token
  //  token	String
  //  Access token
  func reloginUser(_ facebookId:String, completitionHandler:@escaping (_ responseJSON:JSON, _ status:Bool) -> ()) {
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url = "\(CHRequests.APIurl)/users/me?token=\(CHSession().getTokenWithFaceBookId(facebookId))"
    let operationQueue = OperationQueue()
    
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(json, false)
          return
        }
        
        CHUsers().localCreateUser(facebookId, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
        completitionHandler(json["data"], true)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(nil, false)
    }
    
  }
  
  //  This method allows to update user profile photo by ID
  //  id	String
  //  User profile ID
  //
  //  token	String
  //  Access token
  //
  //  photo	File
  //  Image photo
  func uploadUsersPhoto(_ userId:String, image:UIImage, bar:RPCircularProgress! = nil, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()){
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)/photo?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: ["photo": Upload(data: UIImageJPEGRepresentation(image, 50)!, fileName: "photo.jpg", mimeType: "multipart/form-data")])
      CHBanners().setTimeout(30, block: {
        if !opt.isFinished {
          opt.cancel()
          CHPush().alertPush("Failed to Upload Photo", type: "Warning")
          completitionHandler(false, nil)
        }
        
      })
      
      opt.onFinish = { response in
        let json = JSON(data: response.data)
           
        if response.error != nil {
          completitionHandler(false, json)
          return
        }
        CHRequests().updateUser(json["data"])
        completitionHandler(true, json)
        
      }
      operationQueue.addOperation(opt)
    } catch _ {
      completitionHandler(false, nil)
      
    }
    
  }
  
  //  This method allows to update user profile by ID
  //  id	String
  //  User profile ID
  //
  //  token	String
  //  Access token
  //
  //  name	String
  //  User given name
  //
  //  email	String
  //  User email
  func updateUserProfile(_ userId:String, params:[String:String], completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
           
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        CHUsers().localCreateUser(CHSession().currentUserFacebookId, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  
  func clearSession(_ userId:String, token:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)?token=\(token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: ["APNIdentifier" : "none"])
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
           
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        CHUsers().localCreateUser(CHSession().currentUserFacebookId, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to update user profile options by ID
  //  id	String
  //  User profile ID
  //
  //  token	String
  //  Access token
  //
  //  joinedChampy	Boolean
  //  Notify user when someone joined Champy
  //
  //  friendRequests	Boolean
  //  Notify user new friend requests
  //
  //  challengeEnd	Boolean
  //  Notify user when challenge end
  //
  //  challengesForToday	Boolean
  //  Notify user about challenges for today
  //
  //  reminderTime	Number
  //  Reminder time challenges for today
  //
  //  challengeConfirmation	Boolean
  //  Notify user when he must check or approve challenge
  //
  //  acceptedYourChallenge	Boolean
  //  Notify user when someone accepted his challenge
  //
  //  newChallengeRequests	Boolean
  //  Notify user when someone assign to him challenge
  //
  //  pushNotifications	Boolean
  //  General flag for turn off notifications
  func updateUserProfileOptions(_ userId:String, params:[String:String], completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    
    let url = "\(CHRequests.APIurl)/users/\(userId)/profile-options?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        CHUsers().localCreateUser(CHSession().currentUserFacebookId, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to remove user profile by ID
  //  token	String
  //  Access token
  func deleteAccount(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()){
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.DELETE(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        
        
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to retrieve list of registered user profiles
  //  token	String
  //  Access token
  func getAllUsers(_ completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/getusersbyfacebookid?token=\(self.token)\(CHUsers().getFacebookFriendsQueryPart())"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        
        UserDefaults.standard.set("\(json["data"])", forKey: "userList")
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  func getFacebookImageById(_ facebookId:String) -> UIImage {
    if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
      return UIImage(named: "center")!
    } else {
      return UIImage(data: try! Data(contentsOf: URL(string: "http://graph.facebook.com/\(facebookId)/picture?type=large&redirect=true&width=500&height=500")!))!
    }
  }
  
  //  This method allows to retrieve relationships list of registered user
  //  owner	String
  //  Profile owner unique ID
  //
  //  token	String
  //  Access token
  func getFriends(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)/friends?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        
        
        UserDefaults.standard.set("\(json["data"])", forKey: "friendsList(\(userId))")
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to get all Challenges
  //  token	String
  //  Access token
  func getChallenges(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/challenges?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        UserDefaults.standard.set("\(json["data"])", forKey: "challenges")
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to create new relationship between profile owner and his friendowner	String
  //  Profile owner unique ID
  //
  //  friend	String
  //  Profile friend unique ID
  //
  //  token	String
  //  Access token
  func sendFriendRequest(_ userId:String, friendId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)/friends?token=\(self.token)"
    let params = [
      "friend": friendId
    ]
    let operationQueue = OperationQueue()
    
    
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        
        CHPush().localPush("pendingReload", object: self)
        CHPush().localPush("friendsReload", object: self)
        CHPush().localPush("allReload", object: self)
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to accept friend request
  //  owner	String
  //  Profile owner unique ID
  //
  //  friend	String
  //  Profile friend unique ID
  //
  //  token	String
  //  Access token
  func acceptFriendRequest(_ userId:String, friendId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)/friends/\(friendId)?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.PUT(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        CHPush().localPush("friendsReload", object: self)
        CHPush().localPush("allReload", object: self)
        
        UserDefaults.standard.set("\(json["data"])", forKey: "friendsList(\(userId))")
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to remove specific relationship between profile owner and his friend by unique ID
  //  owner	String
  //  Profile owner unique ID
  //
  //  friend	String
  //  Profile friend unique ID
  //
  //  token	String
  //  Access token
  func removeFriendRequest(_ userId:String, friendId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)/friends/\(friendId)?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.DELETE(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        CHPush().localPush("friendsReload", object: self)
        CHPush().localPush("allReload", object: self)
        CHPush().localPush("pendingReload", object: self)
        
        
        UserDefaults.standard.set("\(json["data"])", forKey: "friendsList(\(userId))")
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to create duel InProgressChallenge
  //  token	String
  //  Access token
  //
  //  recipient	String
  //  User ID
  //
  //  challenge	String
  //  Challenge ID
  func createDuelInProgressChallenge(_ params:[String:String], completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/in-progress-challenges/duel?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        var error = false
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          error = true
        }
        
        
        if !error {
          self.updateUser(json["data"])
          completitionHandler(true, json)
        }
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to create single InProgressChallenge
  //  token	String
  //  Access token
  //
  //  challenge	String
  //  Challenge ID
  func createSingleInProgressChallenge(_ params:[String:String], completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/in-progress-challenges/single?token=\(self.token)"
    let operationQueue = OperationQueue()
    print(params)
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        CHRequests().updateUser(json["data"])
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to create self improvement Challenge
  func createSelfImprovementChallengeAndSendIt(_ params:[String:String], completitionHandler:@escaping (_ json:JSON, _ status:Bool) -> ()){
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url:String = "\(CHRequests.APIurl)/challenges?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      print(params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          completitionHandler(json, false)
          return
        }
        
        let params:[String:String] = [
          "challenge" : json["data"]["_id"].stringValue
        ]
        
        self.createSingleInProgressChallenge(params, completitionHandler: { (result, json) in
          completitionHandler(json, result)
        })
        
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(nil, false)
    }
  }
  
  //  This method allows to get InProgressChallenge by ID
  //  token	String
  //  Access token
  //
  //  id	String
  //  InProgressChallenge ID
  func retrieveAllInProgressChallenges(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)/history/events/0?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        
        
        UserDefaults.standard.set("\(json["data"])", forKey: "inProgressChallenges\(userId)")
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to retrieve won in progress challenges by user ID after updated time
  //  id	String
  //  User unique ID
  //
  //  updated	String
  //  Updated unix-time
  //
  //  token	String
  //  Access token
  func retrieveWins(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)/history/wins/0?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }

        UserDefaults.standard.set("\(json["data"])", forKey: "wins\(userId)")
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to retrieve failed in progress challenges by user ID after updated time
  //  id	String
  //  User unique ID
  //
  //  updated	String
  //  Updated unix-time
  //
  //  token	String
  //  Access token
  func retrieveFails(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(userId)/history/fails/0?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        
        UserDefaults.standard.set("\(json["data"])", forKey: "fails\(userId)")
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to join to challenge
  //  token	String
  //  Access token
  //
  //  id	String
  //  InProgressChallenge ID
  func joinToChallenge(_ challengeId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/in-progress-challenges/\(challengeId)/join?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (secondresult, secondjson) in
          CHRequests().updateUser(json["data"])
          completitionHandler(secondresult, json)
        })
        
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to Surrender
  //  token	String
  //  Access token
  //
  //  id	String
  //  InProgressChallenge ID
  func surrender(_ challengeId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/in-progress-challenges/\(challengeId)/surrender?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        CHRequests().updateUser(json["data"])
        
        CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
          completitionHandler(result, json)
        })
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to reject invite
  //  token	String
  //  Access token
  //
  //  id	String
  //  InProgressChallenge ID
  func rejectInvite(_ challengeId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/in-progress-challenges/\(challengeId)/reject?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          CHRequests().updateUserFromRemote({ (thirdresult, thirdjson) in
            CHPush().localPush("refreshIcarousel", object: self)
            completitionHandler(false, json)
          })
          
        } else {
          CHRequests().updateUserFromRemote({ (thirdresult, thirdjson) in
            CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, secondjson) in
              CHPush().localPush("refreshIcarousel", object: self)
              completitionHandler(result, secondjson)
            })
          })
        }
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  //  This method allows to Check Challenge
  //  token	String
  //  Access token
  //
  //  id	String
  //  InProgressChallenge ID
  func checkChallenge(_ challengeId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/in-progress-challenges/\(challengeId)/check?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
          if let _ = response.error {
          CHRequests().updateUserFromRemote({ (thirdresult, thirdjson) in
            CHPush().localPush("refreshIcarousel", object: self)
            completitionHandler(false, json)
          })
          
        } else {
          CHRequests().updateUserFromRemote({ (thirdresult, thirdjson) in
            CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, secondjson) in
              CHPush().localPush("refreshIcarousel", object: self)
              completitionHandler(result, secondjson)
            })
          })
        }
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  
  func updateUser(_ object:JSON) {
    if !canPerform {
      return
    }
    
    if object["_id"].stringValue == CHSession().currentUserId {
      CHSession().updateUserObject(object)
      return
    }
    
    if object["sender"]["_id"].stringValue == CHSession().currentUserId {
      CHSession().updateUserObject(object["sender"])
      return
    }
    
    if object["recipient"]["_id"].stringValue == CHSession().currentUserId {
      CHSession().updateUserObject(object["recipient"])
      return
    }
  }
  
  func updateUserFromRemote(_ completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/me?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        
        CHRequests().updateUser(json["data"])
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(false, nil)
      
    }
  }
  
  func logout(_ ownerId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/\(ownerId)/logout?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        
        CHRequests().updateUser(json["data"])
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(false, nil)
      
    }
  }
  
  func surrenderAll(_ ownerId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/users/surrender?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(false, nil)
      
    }
  }
  
  func leaveFeedback(_ params:[String:String], completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(CHRequests.APIurl)/feedback?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        completitionHandler(true, json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(false, nil)
      
    }
  }
  
  func convertStringToDictionary(_ text: String) -> [String:AnyObject]? {
    var res: [String:AnyObject]?
    if let data = text.data(using: String.Encoding.utf8) {
      do {
        res = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
      } catch _ {
        
      }
    }
    return res
  }
  
}
