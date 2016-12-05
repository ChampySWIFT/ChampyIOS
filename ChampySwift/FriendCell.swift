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
  
  @IBOutlet weak var mainContent: UIView!
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
  
  let appDelegate     = UIApplication.shared.delegate as! AppDelegate
  var atIndexPath:IndexPath! = nil
  var fromTableView:UITableView! = nil
  weak var view: UIView!
  var width:CGFloat = 0.0,
  initialNameLevel:CGRect! = nil,
  initialLevelFrame:CGRect! = nil,
  initialScoreFrame:CGRect! = nil,
  initialPlusFrame :CGRect! = nil,
  initialMinusFrame:CGRect! = nil,
  initialAvatarFrame:CGRect! = nil,
  tapped:Bool = false,
  opened:Bool = false,
  minusButtonState = false,
  plusButtonState = false,
  points = 0,
  inProgressChallenges = 0,
  wins = 0,
  status = "other",
  userObject:JSON! = nil
  
  
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
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  func animateScoreBorders() {
    firstScoreIndicator.rotateScoreBorderOnFriends(scoreLabel: self.firstScoreLabel, in: self.firstContainer, with: self.firstMiniIcon, with: self.inProgressChallenges)
    secondScoreIndicator.rotateScoreBorderOnFriends(scoreLabel: self.secondScoreLabel, in: self.secondContainer, with: self.secondMiniIcon, with: self.wins)
    thirdScoreIndicator.rotateScoreBorderOnFriends(scoreLabel: self.thirdScoreLabel, in: self.thirdContainer, with: self.thirdScoreIcon, with: self.points)
  }
  
  func cleareScoreborder() {
    thirdContainer.cleareScoreContainer()
    secondContainer.cleareScoreContainer()
    firstContainer.cleareScoreContainer()
  }
  
  func setUpImage() {
    self.userAvatar.roundCornersAndSetUpWithId(id: userObject["_id"].stringValue, userObject: userObject)
  }
  
  
  func setUp(_ json:JSON) {
    
    self.width             = self.view.frame.width
    self.initialNameLevel  = self.username.frame
    self.initialLevelFrame = self.userLevel.frame
    self.initialScoreFrame = self.scoreContainer.frame
    self.initialAvatarFrame = self.userAvatar.frame
    self.initialPlusFrame  = self.plusButton.frame
   self.initialMinusFrame = self.minusButton.frame
    self.confirmationVindow.isHidden = true
   
    self.initialPlusFrame.origin.x = self.width
    self.plusButton.frame = self.initialPlusFrame
    
    
    if json != nil {
      userObject = json
     self.username.text        = json.getStringByKey(key: "name")
      self.userLevel.text       = "Level \(json["level"].getStringByKey(key: "number")) Champy"
      
      self.wins = json["successChallenges"].intValue
      self.inProgressChallenges = json["inProgressChallengesCount"].intValue
      self.points = json.getSummOffElements(keys: ["inProgressChallengesCount", "allChallengesCount"])
      
      
      self.inProgressCount.text = json["inProgressChallengesCount"].stringValue
      self.allCount.text        = "\(self.points)"
      self.winsCount.text       = json["successChallenges"].stringValue
      
      
      [username, userLevel, inProgressCount, allCount, winsCount].adjustFontSizeToFiTWidthForObjects(value: true)
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
  
  func triggerTapped(value:Bool){
    self.tapped = false
  }
  
  func open() {
    self.tapped = true
    
    self.setTimeout(1.2) {
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
      if self.scoreContainer != nil && self.minusButton != nil && self.plusButton != nil {
        self.scoreContainer.frame = frame1!
        self.scoreContainer.isHidden = false
        self.minusButton.frame = minusButtonFrame
        self.plusButton.frame = plusButtonFrame
      }
    }, completion: { finished in
      
    })
    self.cleareScoreborder()
    self.animateScoreBorders()
    
    
  }
  
  func close() {
    if !opened {
      return
    }
    
    opened = !opened
    self.pointsContainer.isHidden = false
    closeConfirmationWindow()
    var viewFrame = mainContent.frame
    viewFrame.size.height = 80
    self.mainContent.frame = viewFrame
    
    var frame = userAvatar.frame
    frame.origin.x = 8
    
    var separatorFrame = separator.frame
    separatorFrame.origin.y = 79
    
    
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
    
    
    
    
    
  }
  
  func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
  }
  
  @IBAction func addAction(_ sender: AnyObject) {
    if tapped { return }
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
          if result {
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
              CHPush().localPush("refreshBadge", object: self)
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
        if CHSession().currentUserObject["inProgressChallengesCount"].intValue >= CHChalenges().maxChallengesCount {
          CHPush().alertPush("Can't create more challenges", type: "Warning")
          return
        }
        
        if self.userObject["inProgressChallengesCount"].intValue >= CHChalenges().maxChallengesCount {
          CHPush().alertPush("Can't send more challenges to your friend", type: "Warning")
          return
        }
        CHSession().setSelectedFriend(self.userObject["_id"].stringValue)
        CHPush().localPush("openDuelView", object: self)
        break
      default:
        self.tapped = false
    
        self.minusButton.isHidden = true
        self.plusButton.isHidden = true
        
      }
    }
    
    
    
    
  }
  
  @IBAction func minusAction(_ sender: AnyObject) {
    if tapped { return }
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
          CHPush().localPush("refreshBadge", object: self)
          self.tapped = false
          self.confirmationVindow.isHidden = true
        }
      } else {
        self.tapped = false
        CHPush().alertPush("Couldn't decline now", type: "Warning")
      }
    })
  }
  
  
  
  
}

extension ScoreBorder {
  func rotateScoreBorderOnFriends(scoreLabel:UICountingLabel, in container:UIView, with miniIcon:UIImageView, with value:Int) {
    self.rotateScoreViewToZero()
    self.rotateView(1.0)
    self.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.isHidden = false
        self.fillScoreBorder(0.5)
        container.bringSubview(toFront: scoreLabel)
        scoreLabel.method   = UILabelCountingMethodLinear
        scoreLabel.format   = "%d";
        miniIcon.isHidden = false
        scoreLabel.count(from: 0, to: Float(value), withDuration: 0.5)
      }
    }

  }
  
  
  
}

extension UIView {
  func cleareScoreContainer() {
    for item in self.subviews {
      if item.layer.value(forKey: "type") != nil {
        if item.layer.value(forKey: "type") as! String == "inner" {
          item.removeFromSuperview()
        }
      }
    }
  }
}

