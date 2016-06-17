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

  var view: UIView!
  var generalItem:JSON! = nil
  
  @IBOutlet weak var challengeIcon: UIImageView!
  @IBOutlet weak var pointLabel: UILabel!
  @IBOutlet weak var historyTitle: UILabel!
  
  var tapped = false
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
    let nib    = UINib(nibName: "HistoryCell", bundle: bundle)
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
  
  func setUp(json:JSON = nil){
    if json != nil {
      self.generalItem = json
      switch json["challenge"]["type"].stringValue {
      case CHSettings().selfImprovementsId:
        setUpSelfImprovement()
        break
      case CHSettings().wakeUpIds:
        setUpWakeUP()
        break
      case CHSettings().duelsId:
        setUpDuel()
        break
      default: break
        
      }
      
      
      
    }
  }
  
  func setUpWakeUP() {
    self.challengeIcon.image = UIImage(named: "WakeUpColor")
    
    self.historyTitle.text = self.generalItem["challenge"]["name"].stringValue
    self.pointLabel.text = "\(self.generalItem["challenge"]["points"].stringValue)"
    
    return
  }
  
  func setUpDuel() {
    self.challengeIcon.image = UIImage(named: "DuelColor")
    
    if self.generalItem["sender"]["_id"].stringValue == CHSession().currentUserId {
      self.historyTitle.text = "Duel with \(self.generalItem["recipient"]["name"].stringValue)"
      self.pointLabel.text = "\(self.generalItem["challenge"]["points"].stringValue)"
      
      return
    }
    
    if self.generalItem["recipient"]["_id"].stringValue == CHSession().currentUserId {
      self.historyTitle.text = "Duel with \(self.generalItem["sender"]["name"].stringValue)"
      self.pointLabel.text = "\(self.generalItem["challenge"]["points"].stringValue)"
      
      return
    }
    
  }
  
  func setUpSelfImprovement() {
    self.challengeIcon.image = UIImage(named: "SelfImprovementColor")
    
    self.historyTitle.text = self.generalItem["challenge"]["name"].stringValue
    self.pointLabel.text = "\(self.generalItem["challenge"]["points"].stringValue)"
    
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
