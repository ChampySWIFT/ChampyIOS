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
  
  var view: UIView!
  var width:CGFloat = 0.0
  var opened:Bool = false
  @IBOutlet var mainContent: UIView!
  
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
  var initialNameLevel:CGRect! = nil
  var initialLevelFrame:CGRect! = nil
  var initialScoreFrame:CGRect! = nil
  
  var initialPlusFrame :CGRect! = nil
  var initialMinusFrame:CGRect! = nil
  
  var points = 0
  var inProgressChallenges = 0
  var wins = 0
  var status = "other"
  var userObject:JSON! = nil
  
  func animateScoreBorders() {
    firstScoreIndicator.rotateScoreViewToZero()
    firstScoreIndicator.rotateView(1.0)
    firstScoreIndicator.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        self.firstScoreLabel.hidden = false
        self.firstScoreIndicator.fillScoreBorder(1.0)
        self.firstContainer.bringSubviewToFront(self.firstScoreLabel)
        self.firstScoreLabel.method   = UILabelCountingMethodLinear
        self.firstScoreLabel.format   = "%d";
        self.firstMiniIcon.hidden = false
        self.firstScoreLabel.countFrom(0, to: Float(self.inProgressChallenges))
      }
    }
    
    secondScoreIndicator.rotateScoreViewToZero()
    secondScoreIndicator.rotateView(1.0)
    secondScoreIndicator.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        self.secondScoreLabel.hidden = false
        self.secondScoreIndicator.fillScoreBorder(1.0)
        self.secondContainer.bringSubviewToFront(self.secondScoreLabel)
        self.secondScoreLabel.method   = UILabelCountingMethodLinear
        self.secondScoreLabel.format   = "%d";
        self.secondMiniIcon.hidden = false
        self.secondScoreLabel.countFrom(0, to: Float(self.wins))
      }
    }
    
    thirdScoreIndicator.rotateScoreViewToZero()
    thirdScoreIndicator.rotateView(1.0)
    thirdScoreIndicator.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        self.thirdScoreLabel.hidden = false
        self.thirdScoreIndicator.fillScoreBorder(1.0)
        self.thirdContainer.bringSubviewToFront(self.thirdScoreLabel)
        self.thirdScoreLabel.method   = UILabelCountingMethodLinear
        self.thirdScoreLabel.format   = "%d";
        self.thirdScoreIcon.hidden = false
        self.thirdScoreLabel.countFrom(0, to: Float(self.points))
      }
    }
    
    
  }
  
  func cleareScoreborder() {
    for item in thirdContainer.subviews {
      if item.layer.valueForKey("type") != nil {
        if item.layer.valueForKey("type") as! String == "inner" {
          item.removeFromSuperview()
        }
      }
    }
    
    for item:UIView in secondContainer.subviews {
      if item.layer.valueForKey("type") != nil {
        if item.layer.valueForKey("type") as! String == "inner" {
          item.removeFromSuperview()
        }
      }
    }
    
    for item:UIView in firstContainer.subviews {
      if item.layer.valueForKey("type") != nil {
        if item.layer.valueForKey("type") as! String == "inner" {
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
    view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
    // Adding custom subview on top of our view (over any custom drawing > see note below)
    addSubview(view)
  }
  
  func loadViewFromNib() -> UIView {
    let bundle = NSBundle(forClass: self.dynamicType)
    let nib    = UINib(nibName: "FriendCell", bundle: bundle)
    let view   = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
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
  
  func setUp(json:JSON) {
    
    userAvatar.layer.masksToBounds = true
    userAvatar.layer.cornerRadius  = 25.0
    
    self.width             = self.view.frame.width
    self.initialNameLevel  = self.username.frame
    self.initialLevelFrame = self.userLevel.frame
    self.initialScoreFrame = self.scoreContainer.frame
    
    
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
      self.inProgressChallenges = json["allChallengesCount"].intValue
      self.points = json["score"].intValue
      self.inProgressCount.text = json["allChallengesCount"].stringValue
      self.allCount.text        = json["score"].stringValue
      self.winsCount.text       = json["successChallenges"].stringValue
      
      self.username.adjustsFontSizeToFitWidth        = true
      self.userLevel.adjustsFontSizeToFitWidth       = true
      self.inProgressCount.adjustsFontSizeToFitWidth = true
      self.allCount.adjustsFontSizeToFitWidth        = true
      self.winsCount.adjustsFontSizeToFitWidth       = true
    }
    
    switch self.status {
    case "Other" :
      self.minusButton.hidden = true
      self.plusButton.hidden = false
      break
      
    case "Incoming" :
      self.minusButton.hidden = false
      self.plusButton.hidden = false
      break
      
    case "Outgoing" :
      self.minusButton.hidden = true
      self.plusButton.hidden = true
      break
      
    case "Friends" :
      self.minusButton.hidden = false
      self.plusButton.hidden = false
      
      self.minusButton.setImage(UIImage(named: "deleteFriend"), forState: .Normal)
      self.plusButton.setImage(UIImage(named: "challengeFriend"), forState: .Normal)
      break
    default:
      self.minusButton.hidden = true
      self.plusButton.hidden = true
      
    }
    
  }
  
  //  func open() {
  //    self.pointsContainer.hidden = true
  //    
  //    var viewFrame         = self.frame
  //    viewFrame.size.height = 200
  //    
  //    var avaFrame = userAvatar.frame
  //    avaFrame.origin.x = (self.view.frame.width / 2) - 25
  //    
  //    UIView.animateWithDuration(2.0, delay: 0, options: .CurveEaseOut, animations: {
  //      self.frame                = viewFrame
  //      self.userAvatar.frame     = avaFrame
  //      self.userAvatar.transform = CGAffineTransformMakeScale(1.2, 1.2)
  //      }, completion: { finished in
  //    })
  //    
  //    print("open")
  //  }
  //  
  //  func close() {
  //    self.pointsContainer.hidden = false
  //    
  //    var viewFrame         = self.frame
  //    viewFrame.size.height = 66
  //    
  //    var avaFrame = userAvatar.frame
  //    avaFrame.origin.x = 8
  //    
  //    UIView.animateWithDuration(2.0, delay: 0, options: .CurveEaseOut, animations: {
  //      self.frame                = viewFrame
  //      self.userAvatar.frame     = avaFrame
  //      self.userAvatar.transform = CGAffineTransformMakeScale(1.0, 1.0)
  //      }, completion: { finished in
  //    })
  //    
  //    
  //    print("close")
  //  }
  
  func open() {
    
    opened = !opened
    self.pointsContainer.hidden = true
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
    minusButtonFrame.origin.x = 15
    
    var plusButtonFrame = self.plusButton.frame
    plusButtonFrame.origin.x = self.width - 15 - 52
    
    
    UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
      self.username.textAlignment  = .Center
      self.userLevel.textAlignment = .Center
      self.userAvatar.frame        = frame
      self.userAvatar.transform    = CGAffineTransformMakeScale(1.2, 1.2)
      self.username.frame          = nameFrame
      self.userLevel.frame         = levelFrame
      }, completion: { finished in
        
        var frame = self.initialScoreFrame
        frame.origin.y = frame.origin.y - 112
        
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
          self.scoreContainer.frame = frame
          self.scoreContainer.hidden = false
          self.minusButton.frame = minusButtonFrame
          self.plusButton.frame = plusButtonFrame
          }, completion: { finished in
            self.cleareScoreborder()
            self.animateScoreBorders()
        })
    })
    
    print("open")
  }
  
  func close() {
    if !opened {
      return
    }
    
    opened = !opened
    self.pointsContainer.hidden = false
    var viewFrame = mainContent.frame
    viewFrame.size.height = 66
    self.mainContent.frame = viewFrame
    
    var frame = userAvatar.frame
    frame.origin.x = 8
    
    UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
      self.scoreContainer.frame = self.initialScoreFrame
      self.scoreContainer.hidden = true
      self.plusButton.frame = self.initialPlusFrame
      self.minusButton.frame = self.initialMinusFrame
      }, completion: { finished in
        
    })
    
    UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
      self.userAvatar.frame        = frame
      self.userAvatar.transform    = CGAffineTransformMakeScale(1.0, 1.0)
      self.username.layer.opacity = 0.0
      self.userLevel.layer.opacity = 0.0
      
      }, completion: { finished in
        self.username.frame          = self.initialNameLevel
        self.userLevel.frame         = self.initialLevelFrame
        self.username.textAlignment  = .Left
        self.userLevel.textAlignment = .Left
        UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
          self.username.layer.opacity = 1.0
          self.userLevel.layer.opacity = 1.0
          }, completion: { finished in
            
        })
        
        
    })
    
    
    
    
    print("close")
  }
  
  
  @IBAction func addAction(sender: AnyObject) {
    switch self.status {
    case "Other" :
      CHRequests().sendFriendRequest(CHSession().currentUserId, friendId: userObject["_id"].stringValue) { (result, json) in
        if result {
          Async.main {
            CHPush().alertPush("Friend Request Sent", type: "Success")
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
              self.plusButton.frame = self.initialPlusFrame
              self.minusButton.frame = self.initialMinusFrame
            
              }, completion: { finished in
                
            })
          }
        } else {
          CHPush().alertPush("Could't send request now", type: "Warning")
        }
      }
      break
      
    case "Incoming" :
      CHRequests().acceptFriendRequest(CHSession().currentUserId, friendId: userObject["_id"].stringValue, completitionHandler: { (result, json) in
        if result {
          Async.main {
            CHPush().alertPush("Friend Request Accepted", type: "Success")
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
              self.plusButton.frame = self.initialPlusFrame
              self.minusButton.frame = self.initialMinusFrame
              
              }, completion: { finished in
                
            })
          }
        } else {
          CHPush().alertPush("Could't accept request now", type: "Warning")
        }
      })
      
      break
      
    case "Friends" :
      // TODO
      break
    default:
      self.minusButton.hidden = true
      self.plusButton.hidden = true
      
    }
    
    
  }
  
  
  @IBAction func minusAction(sender: AnyObject) {
    switch self.status {
    case "Other" :
      
      
      break
      
    case "Incoming" :
      
      CHRequests().removeFriendRequest(CHSession().currentUserId, friendId: userObject["_id"].stringValue, completitionHandler: { (result, json) in
        if result {
          Async.main {
            CHPush().alertPush("Declined", type: "Success")
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
              self.plusButton.frame = self.initialPlusFrame
              self.minusButton.frame = self.initialMinusFrame
              
              }, completion: { finished in
                
            })
          }
        } else {
          CHPush().alertPush("Couldn't decline now", type: "Warning")
        }
      })
      

      
      break
      
    case "Friends" :
      CHRequests().removeFriendRequest(CHSession().currentUserId, friendId: userObject["_id"].stringValue, completitionHandler: { (result, json) in
        if result {
          Async.main {
            CHPush().alertPush("Declined", type: "Success")
            UIView.animateWithDuration(0.5, delay: 0, options: .CurveEaseOut, animations: {
              self.plusButton.frame = self.initialPlusFrame
              self.minusButton.frame = self.initialMinusFrame
              
              }, completion: { finished in
                
            })
          }
        } else {
          CHPush().alertPush("Couldn't decline now", type: "Warning")
        }
      })
      break
    default:
      self.minusButton.hidden = true
      self.plusButton.hidden = true
      
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
}
