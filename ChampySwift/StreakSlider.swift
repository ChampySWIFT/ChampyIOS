//
//  StreakSlider.swift
//  Champy
//
//  Created by Azinec Development on 3/20/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class StreakSlider: UIScrollView{
  
  private var dayNumber = 21
  let labelWith:CGFloat = 40.0
  
  //default value =
  private var segments:[Int] = [1, 4, 11, 21]
  private var currentDay:Int = 4
  private var inProgressSegmentIndicator:Int = 0
  
  
  var borders:[UIView] = []

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  
  func setUp() {
    var stepper = 0
    var gap:CGFloat = 10.0
    
    for i:Int in 0..<dayNumber {
      let dayLabelCaption = i+1
      
      if segments.index(of: dayLabelCaption) != nil {
        gap = 20.0
        stepper = stepper + 1
        let border = StreakDayLabel.streakBorder(frame: CGRect(x: 10.0 + CGFloat(i) * (labelWith + gap)  + labelWith + CGFloat(gap / 2), y: 5, width: 1.0, height: self.frame.height-10))
        self.borders.append(border)
        self.addSubview(border)
      }
      
      let labelFrame = CGRect(x: 10.0 + CGFloat(i) * (labelWith + gap)  , y: (self.frame.size.height - labelWith) * 0.5, width: labelWith, height: labelWith)
      let dayLabel = StreakDayLabel(frame: labelFrame)
      
      if dayLabelCaption < self.currentDay {
        dayLabel.addDoneFlag()
      }
      
      if dayLabelCaption == self.currentDay {
        dayLabel.addCurrentDayLabelFlag()
        self.inProgressSegmentIndicator = stepper
      }
      
      if dayLabelCaption > self.currentDay {
        dayLabel.addPendingDayLabelFlag()
      }
      
      dayLabel.caption = "\(dayLabelCaption)"
      
      self.addSubview(dayLabel.getLabel())
      
//      if stepper >= segments.count {return}
      
      
    }
    
    self.contentSize = CGSize(width: 21.0 * (labelWith + gap) + 10.0, height: self.frame.size.height)
    self.setUpStreakTopLabels()
  }
  
  func setUpStreakTopLabels(){
    
    var i = 1
    var starterCoord:CGFloat = 0.0
    for item in self.borders {
      let label = UILabel(frame: CGRect(x: starterCoord, y:0, width: item.frame.origin.x - starterCoord, height: 10.0))
      label.text = "Streak \(i)"
      label.textColor = .black
      label.textAlignment = .center
      label.font = UIFont(name: "Arial", size: 8.0)
      self.addSubview(label)
      
      let statusLabel = UILabel(frame: CGRect(x: starterCoord, y:60, width: item.frame.origin.x - starterCoord, height: 10.0))
      
      if i == 1 {
//        statusLabel.text = "ok"
//        statusLabel.textColor = .green
        
      } else if i == self.inProgressSegmentIndicator + 1 {
        statusLabel.text = "In Progress"
        statusLabel.textColor = .black
      } else {
        statusLabel.textColor = .clear
      }
      
      statusLabel.textAlignment = .center
      statusLabel.font = UIFont(name: "Arial", size: 8.0)
      self.addSubview(statusLabel)
      
      starterCoord = item.frame.origin.x
      
      i = i + 1
      
    }
  }
  
  func setDayNumber(numberOfDays:Int = 21) {
    self.dayNumber = numberOfDays
  }
  
  func setCurrentDay(day:Int = 4) {
    self.currentDay = day
  }
  
}


class StreakDayLabel :UILabel {

  var selected: Bool = false
  var completed: Bool = false
  var caption: String = ""
  
  
  override init(frame: CGRect) {
    super.init(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func getLabel() -> UILabel {
    self.text = caption
    self.backgroundColor =  .clear
    self.textAlignment = .center
    return self
  }
  
  
  
  
  class func streakBorder(frame:CGRect) -> UIView {
    let border = UIView(frame: frame)
    border.backgroundColor = .gray
    return border
  }
  
  
}

extension StreakDayLabel {
  
  func addDoneFlag() {
    let frame = self.frame
    
    let label = UILabel(frame: CGRect(x:self.frame.width - 20.0, y: 0.0, width: 10.0, height: 10.0))
    label.text = "ok"
    label.textColor = .green
    label.font = UIFont(name: "Arial", size: 8.0)
    label.textAlignment = .right
    self.addSubview(label)
    
  }
  
  func addCurrentDayLabelFlag() {
  
    self.textColor = .green
    
  }
  
  func addPendingDayLabelFlag() {
    
    self.textColor = .black
    
  }
}









