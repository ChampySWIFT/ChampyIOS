//
//  FriendCell.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/5/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Async
@IBDesignable class FriendCell: UIView {
  let appDelegate     = UIApplication.shared.delegate as! AppDelegate
  
  var view: UIView!
  var width:CGFloat = 0.0
  var opened:Bool = false
  @IBOutlet var mainContent: UIView!
  @IBOutlet weak var separator: UIView!
  
  @IBOutlet weak var plusButton: UIButton!
  @IBOutlet weak var minusButton: UIButton!
  @IBOutlet weak var userAvatar: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var userLevel: UILabel!
  @IBOutlet weak var inProgressCount: UILabel!
  @IBOutlet weak var winsCount: UILabel!
  @IBOutlet weak var allCount: UILabel!
  @IBOutlet weak var pointsCount: UIView!
  @IBOutlet weak var pointsContainer: UIView!
  
  @IBOutlet weak var confirmationVindow: UIView!
  @IBOutlet weak var firstContainer: UIView!
  @IBOutlet weak var firstScoreIndicator: ScoreBorder!
  @IBOutlet weak var firstScoreLabel: UICountingLabel!
  @IBOutlet weak var firstMiniIcon: UIImageView!
  @IBOutlet weak var secondContainer: UIView!
  @IBOutlet weak var secondScoreIndicator: ScoreBorder!
  @IBOutlet weak var secondScoreLabel: UICountingLabel!
  @IBOutlet weak var secondMiniIcon: UIImageView!
  @IBOutlet weak var thirdContainer: UIView!
  @IBOutlet weak var thirdScoreIndicator: ScoreBorder!
  @IBOutlet weak var thirdScoreLabel: UICountingLabel!
  @IBOutlet weak var thirdScoreIcon: UIImageView!
  @IBOutlet weak var scoreContainer: UIView!
  
  
  
  var minusButtonState = false
  var plusButtonState = false
  var initialNameLevel:CGRect! = nil
  var initialLevelFrame:CGRect! = nil
  var initialScoreFrame:CGRect! = nil
  
  var initialPlusFrame :CGRect! = nil
  var initialMinusFrame:CGRect! = nil
  var initialAvatarFrame:CGRect! = nil
  
  
  
  var points = 0
  var inProgressChallenges = 0
  var wins = 0
  var status = "other"
  var userObject:JSON! = nil
  
  var tapped:Bool = false
  
  func animateScoreBorders() {
    firstScoreIndicator.rotateScoreViewToZero()
    firstScoreIndicator.rotateView(1.0)
    firstScoreIndicator.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        self.firstScoreLabel.adjustsFontSizeToFitWidth = true
        self.firstScoreLabel.isHidden = false
        self.firstScoreIndicator.fillScoreBorder(0.5)
        self.firstContainer.bringSubview(toFront: self.firstScoreLabel)
        self.firstScoreLabel.method   = UILabelCountingMethodLinear
        self.firstScoreLabel.format   = "%d";
        self.firstMiniIcon.isHidden
          = false
        //        self.firstScoreLabel.animationDuration = 0.5
        self.firstScoreLabel.count(from: 0, to: Float(self.inProgressChallenges), withDuration: 0.5)
        
      }
    }
    
    secondScoreIndicator.rotateScoreViewToZero()
    secondScoreIndicator.rotateView(1.0)
    secondScoreIndicator.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        self.secondScoreLabel.adjustsFontSizeToFitWidth = true
        self.secondScoreLabel.isHidden = false
        self.secondScoreIndicator.fillScoreBorder(0.5)
        self.secondContainer.bringSubview(toFront: self.secondScoreLabel)
        self.secondScoreLabel.method   = UILabelCountingMethodLinear
        self.secondScoreLabel.format   = "%d";
        self.secondMiniIcon.isHidden = false
        self.secondScoreLabel.count(from: 0, to: Float(self.wins), withDuration: 0.5)
        //        self.secondScoreLabel.countFrom(0, to: Float(self.wins))
      }
    }
    
    thirdScoreIndicator.rotateScoreViewToZero()
    thirdScoreIndicator.rotateView(1.0)
    thirdScoreIndicator.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        self.thirdScoreLabel.adjustsFontSizeToFitWidth = true
        self.thirdScoreLabel.isHidden = false
        self.thirdScoreIndicator.fillScoreBorder(0.5)
        self.thirdContainer.bringSubview(toFront: self.thirdScoreLabel)
        self.thirdScoreLabel.method   = UILabelCountingMethodLinear
        self.thirdScoreLabel.format   = "%d";
        self.thirdScoreIcon.isHidden = false
        self.thirdScoreLabel.count(from: 0, to: Float(self.points), withDuration: 0.5)
      }
    }
    
    
  }
  
  func cleareScoreborder() {
    for item in thirdContainer.subviews {
      if item.layer.value(forKey: "type") != nil {
        if item.layer.value(forKey: "type") as! String == "inner" {
          item.removeFromSuperview()
        }
      }
    }
    
    for item:UIView in secondContainer.subviews {
      if item.layer.value(forKey: "type") != nil {
        if item.layer.value(forKey: "type") as! String == "inner" {
          item.removeFromSuperview()
        }
      }
    }
    
    for item:UIView in firstContainer.subviews {
      if item.layer.value(forKey: "type") != nil {
        if item.layer.value(forKey: "type") as! String == "inner" {
          item.removeFromSuperview()
        }
      }
    }
  }
  
  func xibSetup() {
    view                  = loadViewFromNib()
    // use bounds not frame or it'll be offset
    view.frame            = bounds
    // Make the view stretch with containing view
    view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
    // Adding custom subview on top of our view (over any custom drawing > see note below)
    addSubview(view)
    CHImages().setImageForMiniIconInProgress(imageView: self.firstMiniIcon)
    CHImages().setImageForMiniIconWins(imageView: self.secondMiniIcon)
    CHImages().setImageForMiniIconTotal(imageView: self.thirdScoreIcon)
  }
  
  func loadViewFromNib() -> UIView {
    let bundle = Bundle(for: type(of: self))
    let nib    = UINib(nibName: "FriendCell", bundle: bundle)
    let view   = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
    view.layer.cornerRadius = 5.0
    return view
  }
  
  override init(frame: CGRect) {
    // 1. setup any properties here
    // 2. call super.init(frame:)
    super.init(frame: frame)
    // 3. Setup view from .xib file
    
    xibSetup()
    
  }
  
  func setUp(_ json:JSON) {
    
    userAvatar.layer.masksToBounds = true
    userAvatar.layer.cornerRadius  = 25.0
    
    self.width             = self.view.frame.width
    self.initialNameLevel  = self.username.frame
    self.initialLevelFrame = self.userLevel.frame
    self.initialScoreFrame = self.scoreContainer.frame
    self.initialAvatarFrame = self.userAvatar.frame
    self.confirmationVindow.isHidden = true
    self.initialPlusFrame  = self.plusButton.frame
    self.initialPlusFrame.origin.x = self.width
    
    self.plusButton.frame = self.initialPlusFrame
    
    self.initialMinusFrame = self.minusButton.frame
    
    
    if json != nil {
      userObject = json
      CHImages().setImageForFriend(json["_id"].stringValue, imageView: self.userAvatar)
      self.username.text        = json["name"].stringValue
      self.userLevel.text       = "Level \(json["level"]["number"].stringValue) Champy"
      
      self.wins = json["successChallenges"].intValue
      self.inProgressChallenges = json["inProgressChallengesCount"].intValue
      self.points = json["inProgressChallengesCount"].intValue + json["allChallengesCount"].intValue
      
      
      self.inProgressCount.text = json["inProgressChallengesCount"].stringValue
      self.allCount.text        = "\(self.points)"
      self.winsCount.text       = json["successChallenges"].stringValue
      
      self.username.adjustsFontSizeToFitWidth        = true
      self.userLevel.adjustsFontSizeToFitWidth       = true
      self.inProgressCount.adjustsFontSizeToFitWidth = true
      self.allCount.adjustsFontSizeToFitWidth        = true
      self.winsCount.adjustsFontSizeToFitWidth       = true
    }
    
    switch self.status {
    case "Other" :
      minusButtonState = true
      plusButtonState = false
      break
      
    case "Incoming" :
      minusButtonState = false
      plusButtonState = false
      break
      
    case "Outgoing" :
      minusButtonState = false
      plusButtonState = true
      break
      
    case "Friends" :
      minusButtonState = false
      plusButtonState = false
      
      self.minusButton.setImage(#imageLiteral(resourceName: "deleteFriend"), for: .normal)
      self.plusButton.setImage(#imageLiteral(resourceName: "challengeFriend"), for: .normal)
      break
    default:
      minusButtonState = true
      plusButtonState = true
      
    }
    
    self.minusButton.isHidden = minusButtonState
    self.plusButton.isHidden = plusButtonState
    
    
  }
  
  
  func open() {
    ////print(self.userObject)
    self.tapped = true
    self.setTimeout(1.0) { 
      self.tapped = false
    }
    
    opened = !opened
    self.pointsContainer.isHidden = true
    closeConfirmationWindow()
    cleareScoreborder()
    var viewFrame         = mainContent.frame
    viewFrame.size.height = 220
    //    self.mainContent.frame = viewFrame
    
    var frame      = userAvatar.frame
    frame.origin.x = (self.width / 2) - 25
    
    var nameFrame        = self.username.frame
    nameFrame.origin.x   = 0
    nameFrame.size.width = self.width
    nameFrame.origin.y   = userAvatar.frame.height + 20
    
    var levelFrame        = self.userLevel.frame
    levelFrame.origin.x   = 0
    levelFrame.size.width = self.width
    levelFrame.origin.y   = nameFrame.origin.y + nameFrame.height + 5
    
    var minusButtonFrame = self.minusButton.frame
    minusButtonFrame.origin.x = 23
    
    var plusButtonFrame = self.plusButton.frame
    plusButtonFrame.origin.x = self.width - 15 - 62
    
    var separatorFrame = separator.frame
    separatorFrame.origin.y = 219
    
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
      self.username.textAlignment  = .center
      self.userLevel.textAlignment = .center
      self.userAvatar.frame        = frame
      self.username.frame          = nameFrame
      self.userLevel.frame         = levelFrame
      self.separator.frame = separatorFrame
      }, completion: { finished in
        
        
        
    })
    
    var frame1 = self.initialScoreFrame
    frame1?.origin.y = (frame1?.origin.y)! - 112
    
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
      self.scoreContainer.frame = frame1!
      self.scoreContainer.isHidden = false
      self.minusButton.frame = minusButtonFrame
      self.plusButton.frame = plusButtonFrame
      }, completion: { finished in
        
    })
    self.cleareScoreborder()
    self.animateScoreBorders()
    ////////print("open")
  }
  
  func close() {
    if !opened {
      return
    }
    
    opened = !opened
    self.pointsContainer.isHidden = false
    closeConfirmationWindow()
    var viewFrame = mainContent.frame
    viewFrame.size.height = 66
    self.mainContent.frame = viewFrame
    
    var frame = userAvatar.frame
    frame.origin.x = 8
    
    var separatorFrame = separator.frame
    separatorFrame.origin.y = 65
    
    
    UIView.animate(withDuration: 0.7, delay: 0, options: .curveEaseOut, animations: {
      self.separator.frame = separatorFrame
      self.scoreContainer.frame = self.initialScoreFrame
      self.scoreContainer.isHidden = true
      self.plusButton.frame = self.initialPlusFrame
      self.minusButton.frame = self.initialMinusFrame
      }, completion: { finished in
        
    })
    
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
      self.userAvatar.frame        = frame
      //      self.userAvatar.transform    = CGAffineTransformMakeScale(1.0, 1.0)
      self.username.layer.opacity = 0.0
      self.userLevel.layer.opacity = 0.0
      
      }, completion: { finished in
        self.username.frame          = self.initialNameLevel
        self.userLevel.frame         = self.initialLevelFrame
        self.username.textAlignment  = .left
        self.userLevel.textAlignment = .left
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
          self.username.layer.opacity = 1.0
          self.userLevel.layer.opacity = 1.0
          }, completion: { finished in
            
        })
        
        
    })
    
    
    
    
    ////////print("close")
  }
  
  func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
  }
  
  @IBAction func addAction(_ sender: AnyObject) {
    
    if !tapped {
      
      self.tapped = true
      switch self.status {
      case "Other" :
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
          self.plusButton.frame = self.initialPlusFrame
          self.minusButton.frame = self.initialMinusFrame
          
          }, completion: { finished in
            
        })
        CHRequests().sendFriendRequest(CHSession().currentUserId, friendId: userObject["_id"].stringValue) { (result, json) in
          ////print(json)
          if result {
            ////print(json)
            Async.main {
              self.tapped = false
              CHPush().sendPushToUser(self.userObject["_id"].stringValue, message: "New Friend Request From \(CHSession().currentUserName)", options: "")
            }
          } else {
            CHPush().alertPush("Could't send request now", type: "Warning")
            self.tapped = false
          }
        }
        break
        
      case "Incoming" :
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
          self.plusButton.frame = self.initialPlusFrame
          self.minusButton.frame = self.initialMinusFrame
          
          }, completion: { finished in
            
        })
        CHRequests().acceptFriendRequest(CHSession().currentUserId, friendId: userObject["_id"].stringValue, completitionHandler: { (result, json) in
          if result {
            Async.main {
              self.tapped = false
              CHPush().sendPushToUser(self.userObject["_id"].stringValue, message: "\(CHSession().currentUserName) has accepted your request", options: "")
            }
          } else {
            self.tapped = false
            CHPush().alertPush("Could't accept request now", type: "Warning")
          }
        })
        
        break
        
      case "Friends" :
        self.tapped = false
        CHSession().setSelectedFriend(self.userObject["_id"].stringValue)
        CHPush().localPush("openDuelView", object: self
        )
        break
      default:
        self.tapped = false
    
        self.minusButton.isHidden = true
        self.plusButton.isHidden = true
        
      }
    }
    
    
    
    
  }
  
  @IBAction func minusAction(_ sender: AnyObject) {
    
    if !tapped {
      
      self.tapped = true
      switch self.status {
      case "Other" :
        
        
        break
      case "Outgoing" :
        openConfirmationWindow()
        break
      case "Incoming" :
        openConfirmationWindow()
        break
        
      case "Friends" :
        openConfirmationWindow()
        break
      default:
        self.tapped = false
        self.minusButton.isHidden = true
        self.plusButton.isHidden = true
        
      }
    }
    
    
  }
  
  
  @IBAction func declineDeleting(_ sender: AnyObject) {
    closeConfirmationWindow()
  }
  
  func closeConfirmationWindow() {
    self.confirmationVindow.isHidden = true
    self.minusButton.isHidden = minusButtonState
    self.plusButton.isHidden = plusButtonState
    self.scoreContainer.isHidden = false
    self.tapped = false
    self.userAvatar.isHidden = false
    self.username.isHidden = false
  }
  
  func openConfirmationWindow() {
    
    
    self.confirmationVindow.isHidden = false
    self.minusButton.isHidden = true
    self.plusButton.isHidden = true
    self.pointsCount.bringSubview(toFront: self.confirmationVindow)
    self.scoreContainer.isHidden = true
    self.userAvatar.isHidden = true
    self.username.isHidden = true
  }
  
  @IBAction func acceptDeleting(_ sender: AnyObject) {
    UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
      self.plusButton.frame = self.initialPlusFrame
      self.minusButton.frame = self.initialMinusFrame
      
      }, completion: { finished in
        
    })
    Async.background {
      CHChalenges().surrenderAllInProgressChallengesWithThisFriend(self.userObject["_id"].stringValue)
    }
    CHRequests().removeFriendRequest(CHSession().currentUserId, friendId: self.userObject["_id"].stringValue, completitionHandler: { (result, json) in
      if result {
        Async.main {
          self.tapped = false
          self.confirmationVindow.isHidden = true
        }
      } else {
        self.tapped = false
        CHPush().alertPush("Couldn't decline now", type: "Warning")
      }
    })
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
}
