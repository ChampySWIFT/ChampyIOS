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
  @IBOutlet weak var pointLabel: UILabel!
  @IBOutlet weak var historyTitle: UILabel!
  @IBOutlet weak var avatar: UIImageView!
  @IBOutlet weak var challengeIcoTopConstrait: NSLayoutConstraint!
  @IBOutlet weak var challengeIcoLeftConstrait: NSLayoutConstraint!
  @IBOutlet weak var avatarTopConstrait: NSLayoutConstraint!
  @IBOutlet weak var avatarLeadingToLeftConstrait: NSLayoutConstraint!
  @IBOutlet weak var avatarTrailingToRight: NSLayoutConstraint!
  @IBOutlet weak var partnerName: UILabel!
  @IBOutlet weak var myNameNonDuel: UILabel!
  @IBOutlet weak var myName: UILabel!
  @IBOutlet weak var vsLabel: UILabel!
  @IBOutlet weak var containerView: UIView!
  
  @IBOutlet weak var scoreView: UIView!
  
  
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
  
  override init(frame: CGRect) {
    // 1. setup any properties here
    // 2. call super.init(frame:)
    super.init(frame: frame)
    // 3. Setup view from .xib file
    xibSetup()
    
    
    
  }
  
  func setUp(_ json:JSON = nil){
    if json != nil {
      wasOpened = false
      self.myName.adjustsFontSizeToFitWidth = true
      self.partnerName.adjustsFontSizeToFitWidth = true
      self.avatar.layer.cornerRadius = self.avatar.frame.size.width / 2
      self.avatar.layer.masksToBounds = true
      self.challengeIcon.layer.cornerRadius = self.avatar.frame.size.width / 2
      self.challengeIcon.layer.masksToBounds = true
      self.initialVsFrame = self.vsLabel.frame
      self.partnerName.layer.opacity = 0.0
      self.myName.layer.opacity = 0.0
      self.myNameNonDuel.layer.opacity = 0.0
      self.vsLabel.layer.opacity = 0.0
      self.generalItem = json
      self.myNameNonDuel.text = CHSession().currentUserName
      
      switch json["challenge"]["type"].stringValue {
      case CHChallengeType.SelfImprovement.rawValue :
        setUpSelfImprovement()
        self.type = .SelfImprovement
        self.vsLabel.text = ""
        break
      case CHChallengeType.WakeUp.rawValue:
        setUpWakeUP()
        self.type = .WakeUp
        self.vsLabel.text = ""
        break
      case CHChallengeType.Duel.rawValue:
        setUpDuel()
        self.type = .Duel
        self.vsLabel.text = "VS"
        break
      default: break
        
      }
      
      self.initialHistoryTitle = self.historyTitle.text!
      
    }
  }
  
  func togge() {
  
  }
  
  
  func open() {
    
//    if tapped {
//      return
//    }
//    
//    CHBanners().setTimeout(1.0) {
//      self.tapped = false
//    }
//    
//    tapped = true
    
    
    
    initialIcoFrame = challengeIcon.frame
    initialAvaFrame = avatar.frame
    
    wasOpened = true
    self.historyTitle.text = self.generalItem["challenge"]["name"].stringValue
    
    if self.type == .Duel {
      self.changeIcoToMyPhoto()
      self.animateDuel(170.0, completitionHandler: { (status) in })
      
    } else {
      changeIcoToMyPhoto()
      changeMotherHeight(170.0) { (status) in
        self.animateVsLabelDown()
        self.moveAvatarToAbsoluteCenter()
        self.showNameForNonDuel()
      }
    }
    
    
   
  }
  
  func close() {
//    if tapped {
//      return
//    }
//    
//    CHBanners().setTimeout(1.0) {
//      self.tapped = false
//    }
//    tapped = true
    
    
    if wasOpened == true {
      
      self.historyTitle.text = self.initialHistoryTitle
      if self.type == .Duel {
        
        
        changeMyPhotoToIco()
        
        changeMotherHeight(80, completitionHandler: { (status) in
          
        })
        movePhotoToLeftFromCenter(self.challengeIcon)
        movePhotoToRightFromCenter(self.avatar, completitionHandler: { (status) in
         
        })
        hideNames()
        animateVsLabelUp()
        wasOpened = false
      } else {
        self.changeMyPhotoToIco()
        self.moveAvatarFromAbsoluteCenterToInitialPosition()
        changeMotherHeight(80, completitionHandler: { (status) in
          self.animateVsLabelUp()
          self.hideNameForNonDuel()
          
        })
      }
      
      
    }
  }
  
  func showNameForNonDuel() {
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      self.myNameNonDuel.layer.opacity = 1.0
      
      }, completion: { finished in
        
    })
  }
  
  func hideNameForNonDuel() {
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      self.myNameNonDuel.layer.opacity = 0.0
      
      }, completion: { finished in
        
    })
  }
  
  func moveAvatarToAbsoluteCenter() {
    
    var frame = self.challengeIcon.frame
    frame.origin.x = (self.view.frame.size.width / 2) - (self.challengeIcon.frame.size.width / 2)
    frame.origin.y = 60.0
    
    
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      self.challengeIcon.frame = frame
      }, completion: { finished in
        
    })
  }
  
  func moveAvatarFromAbsoluteCenterToInitialPosition() {
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      self.challengeIcon.frame = self.initialIcoFrame
      }, completion: { finished in
        
    })
  }
  
  
  func showNames() {
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      self.partnerName.layer.opacity = 1.0
      self.myName.layer.opacity = 1.0
      }, completion: { finished in
        
    })
    
  }
  
  func hideNames() {
    self.partnerName.layer.opacity = 0.0
    self.myName.layer.opacity = 0.0
  }
  
  
  func animateVsLabelDown() {
    var frame = self.vsLabel.frame
    frame.origin.y =  80
    
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
      self.vsLabel.frame = frame
      self.vsLabel.layer.opacity = 1.0
      }, completion: { finished in
        //        self.vsLabel.frame = frame
        
    })
    
    UIView.animate(withDuration: 0.6, delay: 0.0, options: .curveEaseOut, animations: {
      self.scoreView.layer.opacity = 0.0
      }, completion: { finished in
        //        self.vsLabel.frame = frame
        
    })
  }
  
  func animateVsLabelUp() {
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
      self.vsLabel.frame = self.initialVsFrame
      self.vsLabel.layer.opacity = 0.0
      }, completion: { finished in
        
    })
    
    
    UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
      self.scoreView.layer.opacity = 1.0
      }, completion: { finished in
        
    })
  }
  
  func movePhotoToCenterFromRight(_ image:UIImageView) {
    
    var frame = self.avatar.frame
    frame.origin.y =  60
    frame.origin.x = self.view.frame.size.width - 50 - self.avatar.frame.size.width
    
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      self.avatar.frame = frame
      }, completion: { finished in
        
        
        
    })
  }
  
  
  func movePhotoToRightFromCenter(_ image:UIImageView, completitionHandler:@escaping (_ status:Bool) -> ()) {
    
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      self.avatar.frame  = self.initialAvaFrame
      }, completion: { finished in
        
        completitionHandler(true)
    })
  }
  
  func movePhotoToCenterFromLeft(_ image:UIImageView, completitionHandler:@escaping (_ status:Bool) -> ()) {
    
    var frame = self.challengeIcon.frame
    frame.origin.y =  60
    frame.origin.x =  50
   
    
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
      self.challengeIcon.frame = frame
      }, completion: { finished in
        completitionHandler(true)
    })
  }
  
  
  
  
  func movePhotoToLeftFromCenter(_ image:UIImageView) {
    
    UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
       image.frame = self.initialIcoFrame
      }, completion: { finished in
    })
  }
  
  
  func changeMotherHeight(_ height:CGFloat, completitionHandler:@escaping (_ status:Bool) -> ()) {
    var frame = self.view.frame
    frame.size.height = height
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
      self.view.frame = frame
      }, completion: { finished in
        completitionHandler(true)
    })
    
    
  
  }
  
  func animateDuel(_ height:CGFloat, completitionHandler:@escaping (_ status:Bool) -> ()) {
    var frame = self.view.frame
    frame.size.height = height
    
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
      self.view.frame = frame
      }, completion: { finished in
        var frame1 = self.challengeIcon.frame
        frame1.origin.y =  60
        frame1.origin.x =  50
        
        var frame2 = self.avatar.frame
        frame2.origin.y =  60
        frame2.origin.x = self.view.frame.size.width - 50 - self.avatar.frame.size.width
        
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: {
          self.challengeIcon.frame = frame1
          }, completion: { finished in
        })
        
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
          self.avatar.frame = frame2
          }, completion: { finished in
            completitionHandler(true)
        })
        
        self.showNames()
        self.animateVsLabelDown()
        
    })
    
    
    
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
    self.pointLabel.text = "\(self.generalItem["challenge"]["points"].stringValue)"
    
    self.myName.text = CHSession().currentUserName
    self.partnerName.text = "CHAMPY"
    return
  }
  
  func setUpDuel() {
    self.challengeIcon.image = UIImage(named: "DuelColor")
    self.myName.text = CHSession().currentUserName
    
    if self.generalItem["sender"]["_id"].stringValue == CHSession().currentUserId {
      if self.generalItem["recipient"] != nil {
        self.historyTitle.text = "Duel with \(self.generalItem["recipient"]["name"].stringValue)"
        self.pointLabel.text = "\(self.generalItem["challenge"]["points"].stringValue)"
        
        CHImages().setImageForFriend(self.generalItem["recipient"]["_id"].stringValue, imageView: self.avatar)
        self.partnerName.text = self.generalItem["recipient"]["name"].stringValue
        return
      } else {
        self.historyTitle.text = "Duel with Unknown User"
        self.pointLabel.text = "\(self.generalItem["challenge"]["points"].stringValue)"
        self.avatar.image = UIImage(named: "noImageIcon")
        self.partnerName.text = "Unknown User"
        return
      }
      
    }
    
    if self.generalItem["recipient"]["_id"].stringValue == CHSession().currentUserId {
      if self.generalItem["recipient"] != nil {
        self.historyTitle.text = "Duel with \(self.generalItem["sender"]["name"].stringValue)"
        self.pointLabel.text = "\(self.generalItem["challenge"]["points"].stringValue)"
        
        CHImages().setImageForFriend(self.generalItem["sender"]["_id"].stringValue, imageView: self.avatar)
        self.partnerName.text = self.generalItem["sender"]["name"].stringValue
        return
      } else {
        self.historyTitle.text = "Duel with Unknown User"
        self.pointLabel.text = "\(self.generalItem["challenge"]["points"].stringValue)"
        self.avatar.image = UIImage(named: "noImageIcon")
        self.partnerName.text = "Unknown User"
        return
      }
      
      
    }
    
  }
  
  func setUpSelfImprovement() {
    self.challengeIcon.image = UIImage(named: "SelfImprovementColor")
    
    self.historyTitle.text = self.generalItem["challenge"]["name"].stringValue
    self.pointLabel.text = "\(self.generalItem["challenge"]["points"].stringValue)"
    
    self.myName.text = CHSession().currentUserName
    self.partnerName.text = "CHAMPY"
    return
  }
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
  
  
  func addScrollBorder(_ frame:CGRect) {
    var borderFrame = frame
    borderFrame.origin.x = borderFrame.origin.x - 2
    borderFrame.origin.y = borderFrame.origin.y - 2
    
    borderFrame.size.width = borderFrame.size.width  + 4
    borderFrame.size.height = borderFrame.size.height + 4
    
    let scrollBorder = ScoreBorder(frame: frame)
    
    self.containerView.addSubview(scrollBorder)
    scrollBorder.rotateScoreViewToZero()
    scrollBorder.rotateView(1.0)
    scrollBorder.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        
        
        
      }
    }
  }
  
  

}
