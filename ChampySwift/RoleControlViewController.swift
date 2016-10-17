//
//  RoleControlViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import SocketIO

class RoleControlViewController: UIViewController {
  //  var socket:SocketIOClient = SocketIOClient(socketURL: "http://192.168.1.104:3007")
  //  var socket:SocketIOClient = SocketIOClient(socketURL: "http://46.101.213.24:3007")
  var socket:SocketIOClient = SocketIOClient(socketURL: URL(string: CHRequests().SocketUrl)!)
  let appDelegate     = UIApplication.shared.delegate as! AppDelegate
  
  override func viewDidAppear(_ animated: Bool) {
    NotificationCenter.default.addObserver(self, selector: #selector(RoleControlViewController.toMainView), name: NSNotification.Name(rawValue: "toMainView"), object: nil)
    
  }
  
  
  
  override func viewDidDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "toMainView"), object: nil)
  }
  
  override func viewDidLoad() {
    //    [self.navigationController setNaviga/tionBarHidden:YES animated:animated];
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    super.viewDidLoad()
    let value = UIInterfaceOrientation.portrait.rawValue
    UIDevice.current.setValue(value, forKey: "orientation")
    let center = NotificationCenter.default
    //    setUpBehavior
    //toFriends
    center.addObserver(self, selector: #selector(RoleControlViewController.alert(_:)), name: NSNotification.Name(rawValue: "alert"), object: nil)
    center.addObserver(self, selector: #selector(RoleControlViewController.setUpBehavior), name: NSNotification.Name(rawValue: "setUpBehavior"), object: nil)
    center.addObserver(self, selector: #selector(RoleControlViewController.toFriends), name: NSNotification.Name(rawValue: "toFriends"), object: nil)
    self.navigationItem.leftBarButtonItem = nil
    
    navigationController!.navigationBar.barTintColor = CHUIElements().APPColors["navigationBar"]
    let mainStoryboard: UIStoryboard          = UIStoryboard(name: "Main",bundle: nil)
    let authViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "AuthViewController")
    authViewController.modalPresentationStyle = .overCurrentContext
    
    if !CHSession().logined {
      self.present(authViewController, animated: false, completion: {
        
      })
    } else {
      self.socket.connect()
      self.handleSocketActions()
      self.toMainView()
    }
    
    
    
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
  }
  
  func setUpBehavior() {
    toMainView()
    self.socket.connect()
    self.handleSocketActions()
  }
  
  
  func toFriends() {
    Async.main {
      self.navigationController?.performSegue(withIdentifier: "showFriends", sender: self)
    }
    
  }

  
  func toMainView() {
    Async.main {
      let mainStoryboard: UIStoryboard          = UIStoryboard(name: "Main",bundle: nil)
      let mainViewController : MainViewController = mainStoryboard.instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
      self.appDelegate.mainViewController = mainViewController
      
      self.performSegue(withIdentifier: "showChallenges", sender: self)
      
//      self.present(self.appDelegate.mainViewController, animated: false, completion: {
      
//      })
    }
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showFacebookView" {
      NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "toMainView"), object: nil)
    }
  }
  
  
  
  func handleSocketActions(){
    
    //initializing new session for the user on socket server
    self.socket.on("connect", callback: { (data, act) -> Void in
      self.socket.emit("ready", CHRequests().token)
    })
    
    self.socket.on("reconnect", callback: { (data, act) -> Void in
      
    })
    
    self.socket.on("connected") { (data, act) -> Void in
      
    }
    
    self.socket.on("Relationship:created") { (data, act) -> Void in
      CHPush().alertPush("New Friend Request", type: "Success")
      self.sendReloadNotiFriends()
    }
    
    self.socket.on("Relationship:created:removed") { (data, act) -> Void in
      CHPush().alertPush("Friend Request Cancelled", type: "Success")
      self.sendReloadNotiFriends()
    }
    
    self.socket.on("Relationship:created:accepted") { (data, act) -> Void in
      CHPush().alertPush("Friend Request Accepted", type: "Success")
      self.sendReloadNotiFriends()
    }
    
    
    
    self.socket.on("Relationship:new") { (data, act) -> Void in
      CHPush().alertPush("New Friend Request", type: "Success")
      self.sendReloadNotiFriends()
    }
    
    self.socket.on("Relationship:new:removed") { (data, act) -> Void in
      CHPush().alertPush("Friend Request Cancelled", type: "Success")
      self.sendReloadNotiFriends()
    }
    
    self.socket.on("Relationship:new:accepted") { (data, act) -> Void in
      CHPush().alertPush("Friend Request Accepted", type: "Success")
      self.sendReloadNotiFriends()
    }
    
    //    InProgressChallenge:new
    
    self.socket.on("InProgressChallenge:new") { (data, act) -> Void in
      CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
        CHPush().alertPush("You got a new Challenge", type: "Success")
        CHPush().localPush("refreshIcarousel", object: self)
      })
    }
    
    
    self.socket.on("InProgressChallenge:accepted") { (data, act) -> Void in
      CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
        if result {
          CHPush().alertPush("Your Friend Accepted your request", type: "Success")
          CHPush().localPush("refreshIcarousel", object: self)
        }
        
      })
    }
    
    self.socket.on("InProgressChallenge:failed") { (data, act) -> Void in
      CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
        if result {
          CHPush().alertPush("Failed a challenge", type: "Success")
          CHPush().localPush("refreshIcarousel", object: self)
        }
      })
    }
    
    self.socket.on("InProgressChallenge:checked") {(data, act) -> Void in
      CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
        if result {
          CHPush().alertPush("Challenge Checked", type: "Success")
          CHPush().localPush("refreshIcarousel", object: self)
        }
      })
    }
    
    self.socket.on("InProgressChallenge:recipient:checked") { (data, act) in
      let res = data as! [[String:AnyObject]]
      if res[0]["recipientSuccess"] as! Int == 0 || res[0]["senderSuccess"] as! Int == 0 {
        CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
          if result {
            CHPush().alertPush("Challenge Checked", type: "Success")
            CHPush().localPush("refreshIcarousel", object: self)
          }
        })
      }
    }
    
    self.socket.on("InProgressChallenge:sender:checked") { (data, act) in
      let res = data as! [[String:AnyObject]]
      if res[0]["recipientSuccess"] as! Int == 0 || res[0]["senderSuccess"] as! Int == 0 {
        CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
          if result {
            CHPush().alertPush("Challenge Checked", type: "Success")
            CHPush().localPush("refreshIcarousel", object: self)
          }
        })
      } 
    }
    
    
    self.socket.on("InProgressChallenge:updated") {(data, act) -> Void in
      CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
        if result {
          CHPush().alertPush("Challenge Updated", type: "Success")
          CHPush().localPush("refreshIcarousel", object: self)
        }
      })
    }
    
    self.socket.on("InProgressChallenge:won") {(data, act) -> Void in
      CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
        if result {
          CHPush().alertPush("You Won", type: "Success")
          CHPush().localPush("refreshIcarousel", object: self)
        }
      })
    }
    
    self.socket.on("InProgress:finish") { (data, act) in
      CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
        if result {
          CHPush().alertPush("You Won", type: "Success")
          CHPush().localPush("refreshIcarousel", object: self)
        }
      })
    }
    
    self.socket.onAny {_ in 
      //////print("Got event: \($0.event)")
    }
    
  }
  
  func sendReloadNotiFriends() {
    CHPush().localPush("refreshBadge", object: self)
    CHPush().localPush("pendingReload", object: self)
    CHPush().localPush("friendsReload", object: self)
    CHPush().localPush("allReload", object: self)
  }
  
  func alert(_ notif:Notification) {
    let object = (notif as NSNotification).userInfo as! [String:String]
    var type:CHBanners.CHBannerTypes! = nil
    
    let remoteType:String = object["type"]!
    
    
    switch remoteType {
    case "Warning":
      type = .Warning
      break
    case "Success":
      type = .Success
      break
    default:
      type = .Default
    }
    
    let message = object["message"]
    self.alertWithMessage(message!, type:type)
  }
  
  func alertWithMessage(_ message:String, type:CHBanners.CHBannerTypes) {
    Async.main {
      let banner = CHBanners(withTarget: (self.navigationController?.view)!, andType: type)
      banner.showBannerForViewControllerAnimated(true, message: message)
    }
  }
  
  override var shouldAutorotate : Bool {
    if UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown {
      return true
    }
    return false
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}
