//
//  FriendCell.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/5/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit

@IBDesignable class FriendCell: UIView {
  
  var view: UIView!
  var width:CGFloat = 0.0
  
  @IBOutlet var mainContent: UIView!
  
  @IBOutlet weak var userAvatar: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var userLevel: UILabel!
  @IBOutlet weak var inProgressCount: UILabel!
  @IBOutlet weak var winsCount: UILabel!
  @IBOutlet weak var pointsCount: UIView!
  @IBOutlet weak var pointsContainer: UIView!
  
  
  
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
  
  func setUp() {
    userAvatar.layer.masksToBounds = true
    userAvatar.layer.cornerRadius = 25.0
    
    self.width = self.view.frame.width
    
    
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
    self.pointsContainer.hidden = true
    
    var viewFrame = mainContent.frame
    viewFrame.size.height = 200
//    self.mainContent.frame = viewFrame
    
    var frame = userAvatar.frame
    frame.origin.x = (self.width / 2) - 25
    
    UIView.animateWithDuration(2.0, delay: 0, options: .CurveEaseOut, animations: {
      self.userAvatar.frame     = frame
      self.userAvatar.transform = CGAffineTransformMakeScale(1.2, 1.2)
      //      self.mainContent.frame = viewFrame
      }, completion: { finished in
    })
    
    //    UIView.animateWithDuration(1.0 , animations: {
    //      
    //    })
    
    print("open")
  }
  
  func close() {
    self.pointsContainer.hidden = false
    var viewFrame = mainContent.frame
    viewFrame.size.height = 66
    self.mainContent.frame = viewFrame
    
    var frame = userAvatar.frame
    frame.origin.x = 8
    
    UIView.animateWithDuration(2.0, delay: 0, options: .CurveEaseOut, animations: {
      self.userAvatar.frame     = frame
      self.userAvatar.transform = CGAffineTransformMakeScale(1.0, 1.0)
      //
      }, completion: { finished in
    })
    
    
    
    
    print("close")
  }
  
  
  required init?(coder aDecoder: NSCoder) {
    // 1. setup any properties here
    // 2. call super.init(coder:)
    super.init(coder: aDecoder)
    // 3. Setup view from .xib file
    xibSetup()
  }
}
