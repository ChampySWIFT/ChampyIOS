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
  
  var APIurl:String   = "http://46.101.213.24:3007/v1"
  var token:String    = ""
  var canPerform:Bool = true
  
  override init() {
    if !IJReachability.isConnectedToNetwork() {
      canPerform = false
      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    } else {
      
      self.token = CHSession().getToken()
    }
    
  }
  
  func createUser(params:[String:String], completitionHandler:(json:JSON, status:Bool) -> ()){
    if !canPerform {
      return
    }
    let url:String = "\(APIurl)/users"
    
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.POST(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          self.reloginUser(params["facebookId"]!, completitionHandler: { (responseJSON, status) in
            if status {
              completitionHandler(json: responseJSON["data"], status: true)
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
  
  func reloginUser(facebookId:String, completitionHandler:(responseJSON:JSON, status:Bool) -> ()) {
    if !canPerform {
      return
    }
    let url = "\(APIurl)/users/me?token=\(CHSession().getTokenWithFaceBookId(facebookId))"
    let operationQueue = NSOperationQueue()
    print(url)
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
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
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/photo?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: [ "photo": Upload(data: UIImageJPEGRepresentation(image, 70)!, fileName: "photo.jpg", mimeType: "multipart/form-data")])
      opt.onFinish = { response in
        let json = JSON(data: response.data)
        print(json)
        if let err = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        completitionHandler(result: true, json: json)
        
      }
      operationQueue.addOperation(opt)
    } catch let error {
      completitionHandler(result: false, json: nil)
      
    }
    
  }
  
  func updateUserProfile(userId:String, params:[String:String], completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
      return
    }
    let url = "\(self.APIurl)/users/\(userId)?token=\(self.token)"
    
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
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
      return
    }
    ///v1/users/:id/profile-options?token=:token
    let url = "\(self.APIurl)/users/\(userId)/profile-options?token=\(self.token)"
    
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.PUT(url, parameters: params)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
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
      return
    }
    let url = "\(self.APIurl)/users/\(userId)?token=\(self.token)"
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
      return
    }
    let url = "\(self.APIurl)/users?token=\(self.token)"
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        print(json)
//        CHPush().localPush("localReload", object: [])
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
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends?token=\(self.token)"
    print(url)
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.GET(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        print(json)
        //        CHPush().localPush("localReload", object: [])
        NSUserDefaults.standardUserDefaults().setObject("\(json["data"])", forKey: "friendsList(\(userId))")
        completitionHandler(result: true, json: json)
      }
      operationQueue.addOperation(opt)
    } catch {
      completitionHandler(result: true, json: nil)
    }
  }
  
  func sendFriendRequest(userId:String, friendId:String, completitionHandler:(result:Bool, json:JSON)->()) {
    if !canPerform {
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
        print(json)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        print(json)
        CHPush().localPush("pendingReload", object: [])
        CHPush().localPush("friendsReload", object: [])
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
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends/\(friendId)?token=\(self.token)"
    print(url)
    let operationQueue = NSOperationQueue()
    do {
      let opt = try HTTP.PUT(url)
      opt.onFinish = { response in
        let json             = JSON(data: response.data)
        print(json)
        if let _ = response.error {
          completitionHandler(result: false, json: json)
          return
        }
        print(json)
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
      return
    }
    let url = "\(self.APIurl)/users/\(userId)/friends/\(friendId)?token=\(self.token)"
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
        print(json)
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
  
}
