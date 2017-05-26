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
    
    private var segments:[Int] = [1, 4, 11, 21]
    private var currentDay:Int = 4
    private var inProgressSegmentIndicator:Int = 0
    
    var frames : [CGRect] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setUp() {
        var stepper = 0
        var startCoordx: CGFloat = 0.0
        var frame :CGRect = CGRect(x: 20.0 , y: 0, width: CGFloat (segments[stepper]) * (labelWith + 10) + 10, height: self.frame.height)
        for stepper in 0..<segments.count {
            if stepper > 0 {
                frame = CGRect(x:startCoordx + 10.0, y: 0, width: CGFloat (segments[stepper] - segments[stepper - 1]) * (labelWith + 10) + 10, height: self.frame.height)
            }
            var border = StreakDayLabel.streakBorder(frame: frame)
            startCoordx = frame.origin.x + frame.width
            
            self.frames.append(frame)
            self.addSubview(border)
        }
        
        
        for i:Int in 0..<dayNumber {
            var gap:CGFloat = 10.0
            let dayLabelCaption = i+1
            
            if segments.index(of: i) != nil {
                gap = 25.0
                stepper = stepper + 1
            }            
            
            let labelFrame = CGRect(x: 30.0 + CGFloat(i) * (labelWith + 10.0) + CGFloat (stepper) * 20.0 , y: (self.frame.size.height - labelWith) * 0.5, width: labelWith, height: labelWith)
            
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
        }
        
        self.contentSize = CGSize(width: 21.0 * (self.labelWith + 10) + CGFloat (self.segments.count) * 20.0 + 30.0, height: self.frame.size.height)
        self.setUpStreakTopLabels()
    }
    
    
    func setUpStreakTopLabels(){
        for i in 0..<self.frames.count {
            let frame = self.frames[i]
            let label = UILabel(frame: CGRect(x: frame.origin.x , y: 5, width: frame.width, height: 10))
            label.text = "Streak \(i + 1)"
            label.textColor = .black
            
            if i < self.inProgressSegmentIndicator {
                label.textColor = .green
            }
            
            label.textAlignment = .center
            label.font = UIFont(name: "Arial", size: 8.0)
            self.addSubview(label)
            
            /*
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
             */
            //            starterCoord = item.frame.origin.x 
            
            //            i = i + 1
            //        }
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
        
        self.textAlignment = .center
        
        self.layer.cornerRadius = self.frame.width / 2
        self.layer.masksToBounds = true

        return self
    }
    
    
    
    
    class func streakBorder(frame:CGRect) -> UIView {
        let border = UIView(frame: frame)
        border.backgroundColor = .white
        border.layer.cornerRadius = 8
        border.layer.masksToBounds = true
        return border
    }
}

extension StreakDayLabel {
    
    func addDoneFlag() {
        let imageView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        imageView.image = UIImage(named: "completeCopy") 
        self.addSubview(imageView)
        
        /*  let frame = self.frame
         
         let label = UILabel(frame: CGRect(x:self.frame.width - 20.0, y: 0.0, width: 10.0, height: 10.0))
         label.text = "ok"
         label.textColor = .green
         label.font = UIFont(name: "Arial", size: 8.0)
         label.textAlignment = .right
         self.addSubview(label)
         */
    }
    
    func addCurrentDayLabelFlag() {
        
        self.textColor = .green
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.green.cgColor
        self.backgroundColor = .white
    }
    
    
    func addPendingDayLabelFlag() {
        self.textColor = .black
        self.backgroundColor = UIColor(colorLiteralRed: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
    }
}









