//
//  ChallengesTableViewCell.swift
//  Champy
//
//  Created by Azinec Development on 3/17/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON


class OngoingChallengeTableViewCell: UITableViewCell {
  @IBOutlet weak var containerView:UIView!
  @IBOutlet weak var streaksHeaderLabel: UILabel!
  @IBOutlet weak var dayHeaderLabel: UILabel!
  
  //ongoing challenge cart
  @IBOutlet weak var challengeNameOngoingCart: UILabel!
  @IBOutlet weak var streakValueOngoingCart: UILabel!
  @IBOutlet weak var dayValueOngoingCart: UILabel!
  
  @IBOutlet weak var percentLabelOngoingCart: UILabel!
  @IBOutlet weak var percentAllViewOngoingCart: UIView!
  @IBOutlet weak var percentDoneViewOngoingCart: UIView!
  @IBOutlet weak var percentWidthConstraiOngoingCart: NSLayoutConstraint!
  @IBOutlet weak var percentAllWidhtOngoingCart: NSLayoutConstraint!
  
  @IBOutlet weak var separatorView: UIView!
  //Step counter Challenge
  @IBOutlet weak var stepCounterLabel: UILabel!
  
  //incoming cart
  @IBOutlet weak var incomingChallengeDetails: UILabel!
  
  
  //outgoing cart
  @IBOutlet weak var outgoingChallengeDetails: UILabel!
  
  
  
  var challengeType:ChallengeCartType = .ongoingCart
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  func setUpCart(challengeDetails:JSON = nil, color:Int = 0, width:CGFloat = 0.0)  {
    
    let colorIndex = color //Int(arc4random_uniform(7))+1
    
//    Colors(colorId: "color\(colorIndex)").refresh(view: self.containerView, colorId: colorIndex, width: width)
    
//    self.containerView.backgroundColor = cartColors[colorIndex]
    
    switch challengeType {
      
    case .ongoingCart:
      self.setUpOngoingCart()
      
    case .stepCounterCard:
      self.setUpStepCounterCart()
      
    case .outgoingCart:
      self.setUpOutgoingCart()
      
    case .incomingCart:
      self.setUpIncomingCart()
      
    default:
      break
    }
  }
  
  
  @IBAction func cancelOutgoingChallenge(_ sender: Any) {
    CHPush().alertPush("cancelled", type: "Info")
  }
  
  @IBAction func acceptIncomingChallenge(_ sender: Any) {
    CHPush().alertPush("accepted", type: "Info")
  }
  
  @IBAction func declineIncomingChallenge(_ sender: Any) {
    CHPush().alertPush("declined", type: "Info")
  }
  
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

extension OngoingChallengeTableViewCell {
  func setUpIncomingCart(challengeDetails:JSON = nil) {
    
  }
  
  func setUpOutgoingCart(challengeDetails:JSON = nil) {
    
  }
  
  
  func setUpOngoingCart(challengeDetails:JSON = nil) {
//    self.challengeNameOngoingCart.sizeToFit()
//    self.streaksHeaderLabel.sizeToFit()
//    self.dayHeaderLabel.sizeToFit()
    let streakNumber = Int(arc4random_uniform(100))
    let dayNumber = Int(arc4random_uniform(100))
    let percentage = Int(arc4random_uniform(100))
    
    streakValueOngoingCart.text = String(streakNumber)
    dayValueOngoingCart.text = String(dayNumber)
    percentToWidth(percent: percentage)
  }
  
  func setUpStepCounterCart(challengeDetails:JSON = nil) {
    let stepNumber = Int(arc4random_uniform(50000))
    let percentage = Int(arc4random_uniform(100))
    
    stepCounterLabel.text = String(stepNumber)
    percentToWidth(percent: percentage)
  }
  
  func percentToWidth(percent:Int) {
    percentLabelOngoingCart.text = "\(percent)% complete"
    percentWidthConstraiOngoingCart.constant =  (percentAllWidhtOngoingCart.constant / 100.0) * CGFloat(percent)
  }
}

