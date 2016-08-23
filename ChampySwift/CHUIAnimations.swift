//
//  CHUIAnimations.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/25/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit

class CHUIAnimations: NSObject {
  
  
}

extension UIView {
  func rotateView(withDuration:Double) {
    self.transform = CGAffineTransformMakeRotation((0 * CGFloat(M_PI)) / 180.0)
    UIView.animateWithDuration(withDuration, animations: {
      self.transform = CGAffineTransformMakeRotation((180 * CGFloat(M_PI)) / 180.0)
    })
  }
  
  func rotateScoreViewToZero(){
    
  }
  
  func fillScoreBorder(withDuration:Double) {
    
    let view    = self as! ScoreBorder
    let newView = UIView(frame: view.frame)
    
    newView.frame              = CGRectMake(newView.frame.origin.x + 3, newView.frame.origin.y + 2, newView.frame.width, newView.frame.height)
    newView.backgroundColor    = UIColor.whiteColor()
    newView.layer.cornerRadius = view.frame.width / 2
    newView.layer.opacity      = 0.50
    newView.layer.setValue("inner", forKey: "type")
    newView.transform = CGAffineTransformMakeScale(0.001, 0.001)
    self.superview!.addSubview(newView)
    self.superview?.sendSubviewToBack(newView)
    UIView.animateWithDuration(withDuration , animations: {
      newView.transform = CGAffineTransformMakeScale(0.782, 0.782)
    })
    
    
  }
  
  func oval2Path() -> UIBezierPath {
    let oval2Path = UIBezierPath(ovalInRect: CGRectMake(0, 0, 2, 2))
    return oval2Path
  }
  
}

extension UILabel {
  func countdownFrom(from:Int, to:Int) {
    
  }
  
}


