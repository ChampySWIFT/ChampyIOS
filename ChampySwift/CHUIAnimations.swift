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
  func rotateView(_ withDuration:Double) {
    self.transform = CGAffineTransform(rotationAngle: (0 * CGFloat(M_PI)) / 180.0)
    UIView.animate(withDuration: withDuration, animations: {
      self.transform = CGAffineTransform(rotationAngle: (180 * CGFloat(M_PI)) / 180.0)
    })
  }
  
  func rotateScoreViewToZero(){
    
  }
  
  func fillScoreBorder(_ withDuration:Double) {
    
    let view    = self as! ScoreBorder
    let newView = UIView(frame: view.frame)
    
    newView.frame              = CGRect(x: newView.frame.origin.x + 3, y: newView.frame.origin.y + 2, width: newView.frame.width, height: newView.frame.height)
    newView.backgroundColor    = UIColor.white
    newView.layer.cornerRadius = view.frame.width / 2
    newView.layer.opacity      = 0.50
    newView.layer.setValue("inner", forKey: "type")
    newView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    self.superview!.addSubview(newView)
    self.superview?.sendSubview(toBack: newView)
    UIView.animate(withDuration: withDuration , animations: {
      newView.transform = CGAffineTransform(scaleX: 0.782, y: 0.782)
    })
    
    
  }
  
  func oval2Path() -> UIBezierPath {
    let oval2Path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 2, height: 2))
    return oval2Path
  }
  
}

extension UILabel {
  func countdownFrom(_ from:Int, to:Int) {
    
  }
  
}


