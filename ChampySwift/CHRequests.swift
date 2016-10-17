
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

class CHRequests: NSObject {
  
  var APIurl:String = "http://46.101.213.24:3007/v1"
  var SocketUrl:String = "http://46.101.213.24:3007"
  
  var privacyUrl:String = "http://46.101.213.24:3007/privacy"
  var termsUrl:String = "http://46.101.213.24:3007/terms"
//  var APIurl:String = "http://192.168.88.101:3007/v1"
//  var SocketUrl:String = "http://192.168.88.101:3007"
  
  var token:String    = ""
  var canPerform:Bool = true
  //  let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
  
  
  override init() {
    
    guard IJReachability.isConnectedToNetwork() else {
      canPerform = false
      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    }
    self.token = CHSession().getToken()
    //print(token)
  }
  
  func getTokenForTests() {
    guard IJReachability.isConnectedToNetwork() else {
      canPerform = false
      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    }
    self.token = CHSession().getToken()
  }
  
  func checkUser(_ ownerId:String, completitionHandler:@escaping (_ json:JSON, _ status:Bool) -> ()) {
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url = "\(self.APIurl)/users/\(ownerId)?token=\(self.token)"
    let operationQueue = OperationQueue()
    ////////print(url)
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        
        let json             = JSON(data: response.data)
        ////////print(json)
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
  
  func createUser(_ params:[String:String], completitionHandler:@escaping (_ json:JSON, _ status:Bool) -> ()){
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url:String = "\(APIurl)/users"
    
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
        
        CHRequests().uploadUsersPhoto(json["data"]["_id"].stringValue, image: CHRequests().getFacebookImageById(params["facebookId"]!), completitionHandler: { (result, json) in
          completitionHandler(json["data"], true)
        })
        
        
        
        
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(nil, false)
    }
  }
  
  func createChallengeAndSendIt(_ recipientId:String, params:[String:String], completitionHandler:@escaping (_ json:JSON, _ status:Bool) -> ()){
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url:String = "\(APIurl)/challenges?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(json, false)
          return
        }
        
        let params1:[String:String] = [
          "recipient" : recipientId,
          "challenge" : json["data"]["_id"].stringValue
        ]
        
        ////////print(params1)
        
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
    let url:String = "\(APIurl)/users/\(userId)/clearebadgenumber?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        ////print(json)
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
  
  func reloginUser(_ facebookId:String, completitionHandler:@escaping (_ responseJSON:JSON, _ status:Bool) -> ()) {
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url = "\(APIurl)/users/me?token=\(CHSession().getTokenWithFaceBookId(facebookId))"
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
  
  func uploadUsersPhoto(_ userId:String, image:UIImage, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()){
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/photo?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: [ "photo": Upload(data: UIImageJPEGRepresentation(image, 70)!, fileName: "photo.jpg", mimeType: "multipart/form-data")])
      opt.onFinish = { response in
        let json = JSON(data: response.data)
        
        ////////print(json)
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
  
  func updateUserProfile(_ userId:String, params:[String:String], completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        //        json)
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
  
  func updateUserProfileOptions(_ userId:String, params:[String:String], completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    ///v1/users/:id/profile-options?token=:token
    let url = "\(self.APIurl)/users/\(userId)/profile-options?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        //        json)
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
  
  func deleteAccount(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()){
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)?token=\(self.token)"
    ////////print(url)
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.DELETE(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        ////////print(json)
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
  
  func getAllUsers(_ completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users?token=\(self.token)"
//    let url = "\(self.APIurl)/users/getusersbyfacebookid?token=\(self.token)\(CHUsers().getFacebookFriendsQueryPart())"
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
  
  func getFriends(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends?token=\(self.token)"
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
  
  func getChallenges(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/challenges?token=\(self.token)"
    
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
  
  func sendFriendRequest(_ userId:String, friendId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends?token=\(self.token)"
    let params = [
      "friend": friendId
    ]
    let operationQueue = OperationQueue()
    
    ////////print(params)
    ////////print(url)
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
  
  func acceptFriendRequest(_ userId:String, friendId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    //users/:owner/friends/:friend?token=:token
    
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends/\(friendId)?token=\(self.token)"
    //    url)
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.PUT(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        //////print(json)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        //        json)
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
  
  func removeFriendRequest(_ userId:String, friendId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    //users/:owner/friends/:friend?token=:token
    
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends/\(friendId)?token=\(self.token)"
    //    url)
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.DELETE(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        //////print(json)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        //        json)
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
  
  func createDuelInProgressChallenge(_ params:[String:String], completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    //users/:owner/friends/:friend?token=:token
    
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/duel?token=\(self.token)"
    //    url)
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
  
  func createSingleInProgressChallenge(_ params:[String:String], completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/single?token=\(self.token)"
    //    url)
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
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
      completitionHandler(true, nil)
    }
  }
  
  func createSelfImprovementChallengeAndSendIt(_ params:[String:String], completitionHandler:@escaping (_ json:JSON, _ status:Bool) -> ()){
    if !canPerform {
      completitionHandler(nil, false)
      return
    }
    let url:String = "\(APIurl)/challenges?token=\(self.token)"
    
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
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
  
  func retrieveAllInProgressChallenges(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/history/events/0?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
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
  
  
  func retrieveWins(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/history/wins/0?token=\(self.token)"
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
  
  func retrieveFails(_ userId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/history/fails/0?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        ////print(json)
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
  
  func joinToChallenge(_ challengeId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/\(challengeId)/join?token=\(self.token)"
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
  
  func rejectInvite(_ challengeId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/\(challengeId)/reject?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(false, json)
          return
        }
        CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
          CHRequests().updateUser(json["data"])
          completitionHandler(result, json)
        })
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(true, nil)
    }
  }
  
  func surrender(_ challengeId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/\(challengeId)/surrender?token=\(self.token)"
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
  
  func checkChallenge(_ challengeId:String, completitionHandler:@escaping (_ result:Bool, _ json:JSON)->()) {
    if !canPerform {
      completitionHandler(false, nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/\(challengeId)/check?token=\(self.token)"
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
    let url = "\(APIurl)/users/me?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        ////////print(json)
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
    let url = "\(APIurl)/users/\(ownerId)/logout?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        ////////print(json)
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
    let url = "\(APIurl)/users/surrender?token=\(self.token)"
    let operationQueue = OperationQueue()
    do {
      let opt = try HTTP.POST(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        ////print(json)
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
