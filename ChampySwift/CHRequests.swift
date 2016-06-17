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
  
//  var APIurl:String   = "http://192.168.88.30:3007/v1"
//  var SocketUrl:String = "http://192.168.88.30 :3007"
  
  var APIurl:String = "http://46.101.213.24:3007/v1"
  var SocketUrl:String = "http://46.101.213.24:3007"
  
  var token:String    = ""
  var canPerform:Bool = true
  let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
  override init() {
    if !IJReachability.isConnectedToNetwork() {
      canPerform = false
      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    } else {
      
      self.token = CHSession().getToken()
      print(CHSession().currentUserId)
      print(self.token)
    }
    
  }
  
  func checkUser(ownerId:String, completitionHandler:(json:JSON, status:Bool) -> ()) {
    if !canPerform {
      completitionHandler(json: nil, status: false)
      return
    }
    let url = "\(self.APIurl)/users/\(ownerId)?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    print(url)
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          completitionHandler(json: json["description"], status: false)
          return
        }
        completitionHandler(json: json["data"], status: true)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(json: nil, status: false)
    }
  }
  
  func createUser(params:[String:String], completitionHandler:(json:JSON, status:Bool) -> ()){
    if !canPerform {
      completitionHandler(json: nil, status: false)
      return
    }
    let url:String = "\(APIurl)/users"
    
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          self.reloginUser(params["facebookId"]!, completitionHandler: { (responseJSON, status) in
            if status {
              completitionHandler(json: responseJSON["data"], status: true)
//              CHUsers().localCreateUser(params["facebookId"]!, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
              
            } else {
              completitionHandler(json: responseJSON["data"], status: false)
            }
          })
          return
        }
        
        CHUsers().localCreateUser(params["facebookId"]!, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
        
        CHRequests().uploadUsersPhoto(json["data"]["_id"].stringValue, image: CHRequests().getFacebookImageById(params["facebookId"]!), completitionHandler: { (result, json) in
          completitionHandler(json: json["data"], status: true)
        })
        
       
        
        
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(json: nil, status: false)
    }
  }
  
  ///v1/challenges
  func createChallengeAndSendIt(params:[String:String], completitionHandler:(json:JSON, status:Bool) -> ()){
    if !canPerform {
      completitionHandler(json: nil, status: false)
      return
    }
    let url:String = "\(APIurl)/challenges?token=\(self.token)"
    
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(json: json, status: false)
          return
        }
        
        let params:[String:String] = [
          "recipient" : CHSession().selectedFriendId,
          "challenge" : json["data"]["_id"].stringValue
        ]
        
        CHRequests().createDuelInProgressChallenge(params, completitionHandler: { (secresult, secjson) in
          completitionHandler(json: secjson, status: secresult)
        })
        
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(json: nil, status: false)
    }
  }
  
  
  
  func reloginUser(facebookId:String, completitionHandler:(responseJSON:JSON, status:Bool) -> ()) {
    if !canPerform {
      completitionHandler(responseJSON: nil, status: false)
      return
    }
    let url = "\(APIurl)/users/me?token=\(CHSession().getTokenWithFaceBookId(facebookId))"
    let operationQueue = NSOperationQueue()

    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(responseJSON: json, status: false)
          return
        }
        
        CHUsers().localCreateUser(facebookId, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
        completitionHandler(responseJSON: json["data"], status: true)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(responseJSON: nil, status: false)
    }
    
  }
  
  func uploadUsersPhoto(userId:String, image:UIImage, completitionHandler:(result:Bool, json:JSON)->()){
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/photo?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: [ "photo": Upload(data: UIImageJPEGRepresentation(image, 70)!, fileName: "photo.jpg", mimeType: "multipart/form-data")])
      opt.onFinish = { response in
        let json = JSON(data: response.data)
//        json)
        if response.error != nil {
          completitionHandler(result: false, json: json)
          return
        }
        completitionHandler(result: true, json: json)
        
      }
      operationQueue.addOperation(opt)
    } catch let _ {
      completitionHandler(result: false, json: nil)
      
    }
    
  }
  
  func updateUserProfile(userId:String, params:[String:String], completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)?token=\(self.token)"
    
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
//        json)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        CHUsers().localCreateUser(CHSession().currentUserFacebookId, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  func updateUserProfileOptions(userId:String, params:[String:String], completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    ///v1/users/:id/profile-options?token=:token
    let url = "\(self.APIurl)/users/\(userId)/profile-options?token=\(self.token)"
    
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
//        json)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        CHUsers().localCreateUser(CHSession().currentUserFacebookId, objectId: json["data"]["_id"].stringValue, name: json["data"]["name"].stringValue, userObject: json["data"])
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  
  func deleteAccount(userId:String, completitionHandler:(result:Bool, json:JSON)->()){
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)?token=\(self.token)"
    print(url)
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.DELETE(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        
        
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  func getAllUsers(completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/users?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        NSUserDefaults.standardUserDefaults().setObject("\(json["data"])", forKey: "userList")
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  func getFacebookImageById(facebookId:String) -> UIImage {
    let urlString = "http://graph.facebook.com/\(facebookId)/picture?type=large&redirect=true&width=500&height=500"
    let url = NSURL(string: urlString)
    let data = NSData(contentsOfURL: url!)
    return UIImage(data: data!)!
  }

  func getFriends(userId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        NSUserDefaults.standardUserDefaults().setObject("\(json["data"])", forKey: "friendsList(\(userId))")
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
//  challenges
  func getChallenges(userId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/challenges?token=\(self.token)"
    
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        NSUserDefaults.standardUserDefaults().setObject("\(json["data"])", forKey: "challenges")
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  func sendFriendRequest(userId:String, friendId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends?token=\(self.token)"
    let params = [
      "friend": friendId
    ]
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        
        CHPush().localPush("pendingReload", object: [])
        CHPush().localPush("friendsReload", object: [])
        CHPush().localPush("allReload", object: [])
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  func acceptFriendRequest(userId:String, friendId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    //users/:owner/friends/:friend?token=:token
    
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends/\(friendId)?token=\(self.token)"
//    url)
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.PUT(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
//        json)
        CHPush().localPush("friendsReload", object: [])
        CHPush().localPush("allReload", object: [])
        NSUserDefaults.standardUserDefaults().setObject("\(json["data"])", forKey: "friendsList(\(userId))")
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  func removeFriendRequest(userId:String, friendId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    //users/:owner/friends/:friend?token=:token
    
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends/\(friendId)?token=\(self.token)"
//    url)
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.DELETE(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
//        json)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
//        json)
        CHPush().localPush("friendsReload", object: [])
        CHPush().localPush("allReload", object: [])
        CHPush().localPush("pendingReload", object: [])
        
        NSUserDefaults.standardUserDefaults().setObject("\(json["data"])", forKey: "friendsList(\(userId))")
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  
  //  createDuelInProgressChallenge
  
  func createDuelInProgressChallenge(params:[String:String], completitionHandler:(result:Bool, json:JSON)->()) {
    //users/:owner/friends/:friend?token=:token
    
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/duel?token=\(self.token)"
    //    url)
    let operationQueue = NSOperationQueue()
    do {
      
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        var error = false
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          error = true
        }
        
        
        if !error {
          CHRequests().updateUser(json["data"])
          completitionHandler(result: true, json: json)
        }
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  func createSingleInProgressChallenge(params:[String:String], completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/single?token=\(self.token)"
    //    url)
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        CHRequests().updateUser(json["data"])
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  
  func createSelfImprovementChallengeAndSendIt(params:[String:String], completitionHandler:(json:JSON, status:Bool) -> ()){
    if !canPerform {
      completitionHandler(json: nil, status: false)
      return
    }
    let url:String = "\(APIurl)/challenges?token=\(self.token)"
    
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
       if let _ = response.error {
          completitionHandler(json: json, status: false)
          return
        }
        
        let params:[String:String] = [
          "challenge" : json["data"]["_id"].stringValue
        ]
        
        self.createSingleInProgressChallenge(params, completitionHandler: { (result, json) in
          completitionHandler(json: json, status: result)
        })
        
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(json: nil, status: false)
    }
  }
  
  
  
  func retrieveAllInProgressChallenges(userId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/history/events/0?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        NSUserDefaults.standardUserDefaults().setObject("\(json["data"])", forKey: "inProgressChallenges\(userId)")
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
 

  func joinToChallenge(challengeId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/\(challengeId)/join?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (secondresult, secondjson) in
          CHRequests().updateUser(json["data"])
          completitionHandler(result: secondresult, json: json)
        })
       
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  
  func rejectInvite(challengeId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/\(challengeId)/reject?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
          CHRequests().updateUser(json["data"])
          completitionHandler(result: result, json: json)
        })
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  
  func surrender(challengeId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/\(challengeId)/surrender?token=\(self.token)"
     let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        CHRequests().updateUser(json["data"])
        
        CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
          completitionHandler(result: result, json: json)
        })
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
///v1/in-progress-challenges/:id/check?token=:token
  
  func checkChallenge(challengeId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(self.APIurl)/in-progress-challenges/\(challengeId)/check?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          CHRequests().updateUserFromRemote({ (thirdresult, thirdjson) in
            CHPush().localPush("refreshIcarousel", object: [])
            completitionHandler(result: false, json: json)
          })
          
        } else {
          CHRequests().updateUserFromRemote({ (thirdresult, thirdjson) in
            CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, secondjson) in
              CHPush().localPush("refreshIcarousel", object: [])
              completitionHandler(result: result, json: secondjson)
            })
          })
        }
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  func updateUser(object:JSON) {
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
  
  func updateUserFromRemote(completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(APIurl)/users/me?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        
        CHRequests().updateUser(json["data"])
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: false, json: nil)
      
    }
  }
  
  func logout(ownerId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      completitionHandler(result: false, json: nil)
      return
    }
    let url = "\(APIurl)/users/\(ownerId)/logout?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.POST(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        
        CHRequests().updateUser(json["data"])
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: false, json: nil)
      
    }
  }
  
}
