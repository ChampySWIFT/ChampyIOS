//
//  DuelViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/10/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Async


class DuelViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
  
  
  @IBOutlet weak var toLabel: UILabel!
  @IBOutlet weak var challengeView: iCarousel!
  
  @IBOutlet weak var myAvatar: UIImageView!
  @IBOutlet weak var friendsAvatar: UIImageView!
  
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var descView: UIView!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var acceptButton: UIButton!
  @IBOutlet weak var declineButton: UIButton!
  
  
  var challenges:[JSON]! = []
  var viewObjects:[NewChallenge]! = []
  var userObject:JSON! = nil
  
  
  @IBAction func closeView(_ sender: AnyObject) {
    //    self.performSegueWithIdentifier("backToMain", sender: self)
    self.dismiss(animated: true) {
      //      self.navigationController?.performSegueWithIdentifier("showFriends", sender: self)
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    CHImages().setImageForFriend(CHSession().selectedFriendId, imageView: self.friendsAvatar)
    CHImages().setUpAvatar(self.myAvatar)
    self.myAvatar.layer.opacity = 0.5
    self.friendsAvatar.layer.opacity = 0.5
    
    self.challengeView.delegate   = self
    self.challengeView.dataSource = self
    self.challengeView.type       = .linear
    
    self.myAvatar.layer.masksToBounds = true
    self.friendsAvatar.layer.masksToBounds = true
    
    self.userObject = CHUsers().getUserById(CHSession().selectedFriendId)
    
    self.toLabel.text = "DUEL WITH \(self.userObject["name"].stringValue)"
    
    CHRequests().getChallenges(CHSession().currentUserId) { (result, json) in
      self.challenges = CHChalenges().getAllChallenges(CHSession().currentUserId)
      self.challenges.insert(nil, at: 0)
      Async.main {
        var i:Int = 0
        self.viewObjects.removeAll()
        for item in self.challenges {
          let cardheight = self.view.frame.size.height - 44 - 50 - self.myAvatar.frame.size.height - 70
          
          let frame = CGRect(x:0, y:5, width:self.view.frame.size.width / 1.4, height: cardheight/*self.view.frame.size.height / 2.0*/)
          let itemView = NewChallenge(frame:frame)
          if item != nil {
            itemView.setUp(item, empty: false)
          } else {
            itemView.setUp(item, empty: true)
          }
          self.viewObjects.append(itemView)
          i = i + 1
        }
        self.challengeView.reloadData()
        self.challengeView.scrollToItem(at: 1, animated: false)
      }
    }
    
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  
  @IBAction func addAction(_ sender: AnyObject) {
    
  }
  
  func numberOfItems(in carousel: iCarousel) -> Int {
    return self.challenges.count
  }
  
  func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
    
    
    return self.viewObjects[index]
  }
  
  func carouselDidScroll(_ carousel: iCarousel) {
    //    CHPush().localPush("dismissKeyboard", object: self)
    close()
  }
  
  func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
    switch option {
    case .spacing:
      return value * 1.1
    case .wrap:
      return 0.0
    default:
      return value
    }
  }
  
  @IBAction func sendtoFriendAction(_ sender:AnyObject) {
    open()
    
  }
  
  @IBAction func confirm(_ sender:AnyObject) {
    sendAction()
    close()
  }
  
  @IBAction func decline(_ sender:AnyObject) {
    
    close()
  }
  
  func open() {
    self.addButton.isHidden = true
    self.descView.isHidden = false
  }
  
  func close() {
    self.addButton.isHidden = false
    self.descView.isHidden = true
    if self.viewObjects.count > 0 {
      self.viewObjects[0].view.endEditing(true)
    }
  }
  
  func sendAction() {
    if !CHChalenges().canISendChallengeToTheFriend(friendId: CHSession().selectedFriendId, challengeId: self.challenges[challengeView.currentItemIndex]["_id"].stringValue) {
      self.alertWithMessage("You can't duplicate challenges with your friend", type:.Warning)
      return
    }
    
    if CHSession().currentUserObject["inProgressChallengesCount"].intValue >= CHChalenges().maxChallengesCount {
      self.alertWithMessage("Can't create more challenges", type:.Warning)
      return
    }
    
    if self.userObject["inProgressChallengesCount"].intValue >= CHChalenges().maxChallengesCount {
      self.alertWithMessage("Can't send more challenges to your friend", type: .Warning)
      return
    }
    
    guard IJReachability.isConnectedToNetwork() else {
      //      CHPush().alertPush("No Internet Connection", type: "Warning")
      self.alertWithMessage("No Internet Connection", type: .Warning)
      return
    }
    
    if self.challenges.count == 0 {
      return
    }
    
    
    
    if self.challenges[challengeView.currentItemIndex] != nil {
      let params:[String:String] = [
        "recipient" : CHSession().selectedFriendId,
        "challenge" : self.challenges[challengeView.currentItemIndex]["_id"].stringValue
      ]
      
      CHRequests().createDuelInProgressChallenge(params) { (result, json) in
        if result {
          self.alertWithMessage("Sent", type: .Warning)
          //          CHPush().alertPush("Sent", type: "Success")
          CHPush().sendPushToUser(CHSession().selectedFriendId, message: "\(CHSession().currentUserName) has sent you a new duel", options: "")
          self.backtoMain()
        } else {
          self.alertWithMessage(json["error"].stringValue, type: .Warning)
          //          CHPush().alertPush(json["error"].stringValue, type: "Warning")
        }
      }
    } else {
      let view:NewChallenge = self.viewObjects[challengeView.currentItemIndex]
      
      var enteredText:String = view.ConditionsTextField.text!
      enteredText = enteredText.condenseWhitespace()
      enteredText = enteredText.trimmingCharacters(
        in: CharacterSet.whitespacesAndNewlines
      )
      
      let conditions:String = enteredText
      
      var dayNumber:String = view.daysTextField.text!.replacingOccurrences(of: " Days", with: "")
      dayNumber = dayNumber.replacingOccurrences(of: " Day", with: "")
      
      
      guard enteredText.isValidChallengeName() else{
        self.alertWithMessage("Invalid Challenge Name", type: .Warning)
        return
      }
      
      guard conditions.isValidConditions() else {
        self.alertWithMessage("Invalid Challenge Name", type: .Warning)
        //        CHPush().alertPush("Invalid Challenge Name", type: "Warning")
        return
      }
      
      guard dayNumber.isDayNumber() else {
        self.alertWithMessage("Invlid Day Count", type: .Warning)
        //        CHPush().alertPush("Invalid Day Count", type: "Warning")
        return
      }
      
      let daysec = CHSettings().daysToSec(Int(dayNumber)!)
      
      let params:[String:String] = [
        "name": conditions,
        "type": CHSettings().duelsId,
        "description": conditions,
        "details": conditions,
        "duration": "\(daysec)"
      ]
      
      CHRequests().createChallengeAndSendIt(CHSession().selectedFriendId, params: params, completitionHandler: { (json, status) in
        if status {
          CHPush().alertPush("Sent", type: "Success")
          self.backtoMain()
          CHPush().sendPushToUser(CHSession().selectedFriendId, message: "\(CHSession().currentUserName) has sent you a new duel", options: "")
        } else {
          CHPush().alertPush(json["error"].stringValue, type: "Warning")
        }
      })
      
    }
    
    
  }
  
  func backtoMain() {
    Async.main{
      self.dismiss(animated: true, completion: {
        CHPush().localPush("toMainView", object: self)
      })
    }
  }
  
  
  func alertWithMessage(_ message:String, type:CHBanners.CHBannerTypes) {
    Async.main {
      let banner = CHBanners(withTarget: self.view, andType: type)
      banner.showBannerForViewControllerAnimated(true, message: message)
    }
  }
}
