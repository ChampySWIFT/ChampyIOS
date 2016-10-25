//
//  SelfImprovementViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/18/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Async

class SelfImprovementViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
  
  @IBOutlet weak var challengeView: iCarousel!
  
  
  @IBOutlet weak var addButton: UIButton!
  @IBOutlet weak var descView: UIView!
  @IBOutlet weak var descLabel: UILabel!
  @IBOutlet weak var acceptButton: UIButton!
  @IBOutlet weak var declineButton: UIButton!
  
  
  var challenges:[JSON]! = []
  var viewObjects:[NewChallenge]! = []
  var userObject:JSON! = nil
  
  
    
  
  @IBAction func closeView(_ sender: AnyObject) {
    self.dismiss(animated: true) { 
      CHPush().localPush("refreshIcarousel", object: self)
    }
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    challengeView.delegate   = self
    challengeView.dataSource = self
    challengeView.type       = .linear
    challengeView.decelerationRate = 0.0
    
    self.userObject = CHSession().currentUserObject
    self.challenges = CHChalenges().getAllChallenges(CHSession().currentUserId)
    
    self.challenges = CHChalenges().getAllSelfImprovementChallenges(CHSession().currentUserId)
    self.challenges.insert(nil, at: 0)
    Async.main {
      var i:Int = 0
      self.viewObjects.removeAll()
      for item in self.challenges {
        let cardheight = self.view.frame.size.height - 272
        
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
    self.view.bringSubview(toFront: self.challengeView)
    
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func numberOfItems(in carousel: iCarousel) -> Int {
    return self.challenges.count
  }
  
  
  func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
    return self.viewObjects[index]
  }
  
  func carouselDidScroll(_ carousel: iCarousel) {
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
  
  func sendAction() {
    if CHSession().currentUserObject["inProgressChallengesCount"].intValue >= CHChalenges().maxChallengesCount {
      self.alertWithMessage("Can't create more challenges", type: .Warning)
      return
    }
    
    guard IJReachability.isConnectedToNetwork() else {
      
      self.alertWithMessage("No Internet Connection", type: .Warning)
//      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    }
    
    if self.challenges.count == 0 {
      return
    }
    
    if self.challenges[challengeView.currentItemIndex] != nil {
      let params:[String:String] = [
        "challenge": self.challenges[challengeView.currentItemIndex]["_id"].stringValue
      ]
      //////print(self.challenges[challengeView.currentItemIndex]["_id"].stringValue)
      CHRequests().createSingleInProgressChallenge(params, completitionHandler: { (result, json) in
        self.finisher(result)
      })
    } else {
      let view:NewChallenge = self.viewObjects[challengeView.currentItemIndex]
      
      var enteredText:String = view.ConditionsTextField.text!
      enteredText = enteredText.condenseWhitespace()
      enteredText = enteredText.trimmingCharacters(
        in: CharacterSet.whitespacesAndNewlines
      )
      
      
      guard enteredText.isValidChallengeName() else{
        self.alertWithMessage("Invalid Challenge Name", type: .Warning)
        return
      }
      
      let conditions:String = enteredText
      
      var dayNumber:String = view.daysTextField.text!.replacingOccurrences(of: " Days", with: "")
      dayNumber = dayNumber.replacingOccurrences(of: " Day", with: "")
      
      //////print(dayNumber)
      guard conditions.isValidConditions() else {
        self.alertWithMessage("Invalid Challenge Name", type: .Warning)
        return
      }
      
      guard dayNumber.isDayNumber() else {
        self.alertWithMessage("Invalid Day Count", type: .Warning)
        return
      }
      
      let daysec = CHSettings().daysToSec(Int(dayNumber)!)
      let params:[String:String] = [
        "name": conditions,
        "type": CHSettings().self.selfImprovementsId,
        "description": conditions,
        "details": conditions,
        "duration": "\(daysec)"
      ]
      
      CHRequests().createSelfImprovementChallengeAndSendIt(params, completitionHandler: { (json, status) in
        self.finisher(status)
      })
      
    }
    
    
  }
  
  func backtoMain() {
    Async.main{
//      self.performSegueWithIdentifier("backtoMain", sender: nil)
      self.dismiss(animated: true, completion: {
        CHPush().localPush("refreshIcarousel", object: self)
        
      })
    }
  }
  
  
  func finisher(_ result:Bool) {
    if result {
//      CHPush().alertPush("Challenge Created", type: "Success")
      self.backtoMain()
    } else {
      self.alertWithMessage("Can`t create challenge", type: .Warning)
//      CHPush().alertPush("Can`t create challenge", type: "Warning")
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
  
  func alertWithMessage(_ message:String, type:CHBanners.CHBannerTypes) {
    Async.main {
      let banner = CHBanners(withTarget: self.view, andType: type)
      banner.showBannerForViewControllerAnimated(true, message: message)
    }
  }
  
}
