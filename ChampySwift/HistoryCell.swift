//
//  HistoryCell.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 6/2/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON



@IBDesignable class HistoryCell: UIView {

  
  enum CHChallengeType: String {
    case Duel    = "567d51c48322f85870fd931b"
    case SelfImprovement = "567d51c48322f85870fd931a"
    case WakeUp = "567d51c48322f85870fd931c"
  }
  
  
  var view: UIView!
  var generalItem:JSON! = nil
  var type: HistoryCell.CHChallengeType! = nil
  @IBOutlet weak var challengeIcon: UIImageView!
  @IBOutlet weak var historyTitle: UILabel!
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var nameLabel: UILabel!
  
  
  
  var initialIcoFrame:CGRect! = nil
  var initialAvaFrame:CGRect! = nil
  var initialVsFrame:CGRect! = nil
  var wasOpened:Bool = false
  var initialHistoryTitle = ""
  
  var tapped = false
  func xibSetup() {
    view                  = loadViewFromNib()
    // use bounds not frame or it'll be offset
    view.frame            = bounds
    // Make the view stretch with containing view
    view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
    // Adding custom subview on top of our view (over any custom drawing > see note below)
    addSubview(view)
  }
  
  func loadViewFromNib() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nib    = UINib(nibName: "HistoryCell", bundle: bundle)
    let view   = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    view.layer.cornerRadius = 5.0
    return view
  }
  
  
  
  
  func setUpforUnknownDuel(){
    self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
    self.avatar.layer.masksToBounds = true
    self.challengeIcon.layer.cornerRadius = self.avatar.frame.size.width / 2
    self.challengeIcon.layer.masksToBounds = true
    self.generalItem = nil
    self.challengeIcon.image = UIImage(named: "DuelColor")
    
    self.nameLabel.text = ""
    self.historyTitle.text = "Duel with Unknown User"
    self.avatar.image = UIImage(named: "noImageIcon")
    
  }
  
  func setUp(_ json:JSON = nil){
    if json != nil {
      self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
      self.avatar.layer.masksToBounds = true
      self.challengeIcon.layer.cornerRadius = self.avatar.frame.size.width / 2
      self.challengeIcon.layer.masksToBounds = true
      self.generalItem = json
     
      switch json["challenge"]["type"].stringValue {
        
      case CHSettings().selfImprovementsId :
        setUpSelfImprovement()
        self.type = .SelfImprovement
        break
      case CHSettings().wakeUpIds:
        setUpWakeUP()
        self.type = .WakeUp
        break
      case CHSettings().duelsId:
        setUpDuel()
        self.type = .Duel
        break
      default: break
        
      }
      
      self.initialHistoryTitle = self.historyTitle.text!
      
    }
  }
  
  func togge() {
  
  }
  
  
  
  func changeMyPhotoToIco() {
    switch self.type.rawValue {
    case CHSettings().duelsId :
      self.challengeIcon.image = UIImage(named: "DuelColor")
      break
    case CHSettings().wakeUpIds :
      self.challengeIcon.image = UIImage(named: "WakeUpColor")
      break
    case CHSettings().selfImprovementsId :
      self.challengeIcon.image = UIImage(named: "SelfImprovementColor")
      break
      
    default: break
    }
  
  }
  
  func changeIcoToMyPhoto() {
    CHImages().setImageForFriend(CHSession().currentUserId, imageView: self.challengeIcon)
  }
  
  func setUpWakeUP() {
    self.challengeIcon.image = UIImage(named: "WakeUpColor")
    
    self.historyTitle.text = self.generalItem["challenge"]["name"].stringValue
    if self.generalItem["challenge"]["duration"] != nil {
      let duration = self.generalItem["challenge"]["duration"].intValue
      let days = CHSettings().secToDays(duration)
      var nameString = "for \(days) days"
      if days == 1 {
        nameString = "for \(days) day"
      }
      self.nameLabel.text = nameString
    }
    return
  }
  
  func setUpDuel() {
    self.challengeIcon.image = UIImage(named: "DuelColor")
    if self.generalItem["challenge"]["name"] != nil {
      let duration = self.generalItem["challenge"]["duration"].intValue
      let days = CHSettings().secToDays(duration)
      var nameString = "\(self.generalItem["challenge"]["name"].stringValue) for \(days) days"
      if days == 1 {
        nameString = "\(self.generalItem["challenge"]["name"].stringValue) for \(days) day"
      }
      self.nameLabel.text = nameString
    }
    if self.generalItem["sender"]["_id"].stringValue == CHSession().currentUserId {
      if self.generalItem["recipient"] != nil {
        self.historyTitle.text = "Duel with \(self.generalItem["recipient"]["name"].stringValue)"
        self.historyTitle.adjustsFontSizeToFitWidth = true
        CHImages().setImageForFriend(self.generalItem["recipient"]["_id"].stringValue, imageView: self.avatar)
        return
      } else {
        self.historyTitle.text = "Duel with Unknown User"
        self.avatar.image = UIImage(named: "noImageIcon")
        return
      }
      
    }
    
    if self.generalItem["recipient"]["_id"].stringValue == CHSession().currentUserId {
      if self.generalItem["recipient"] != nil {
        self.historyTitle.text = "Duel with \(self.generalItem["sender"]["name"].stringValue)"
        
        CHImages().setImageForFriend(self.generalItem["sender"]["_id"].stringValue, imageView: self.avatar)
        return
      } else {
        self.historyTitle.text = "Duel with Unknown User"
        self.avatar.image = UIImage(named: "noImageIcon")
        return
      }
      
      
    }
    
  }
  
  func setUpSelfImprovement() {
    self.challengeIcon.image = UIImage(named: "SelfImprovementColor")
    
    self.historyTitle.text = "Self improvement" //self.generalItem["challenge"]["name"].stringValue
    
    if self.generalItem["challenge"]["duration"] != nil {
      let duration = self.generalItem["challenge"]["duration"].intValue
      let days = CHSettings().secToDays(duration)
      var nameString = "\(self.generalItem["challenge"]["name"].stringValue) for \(days) days"
      if days == 1 {
        nameString = "\(self.generalItem["challenge"]["name"].stringValue) for \(days) day"
      }
      self.nameLabel.text = nameString
    }
    
    return
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  
  

}
