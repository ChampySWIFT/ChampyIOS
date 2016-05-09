
//
//  ViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/23/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import PresenterKit
import Async
import SwiftyJSON

class MainViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
  let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
  let CurrentUser = NSUserDefaults.standardUserDefaults()
  
  @IBOutlet weak var wellcomeLabel: UILabel!
  @IBOutlet weak var mainMenu: UIView!
  @IBOutlet weak var centerBackground: UIImageView!
  @IBOutlet weak var plusIcon: UIImageView!
  var opened:Bool = false
  
  @IBOutlet weak var toolbar: UIToolbar!
  
  @IBOutlet weak var background: UIImageView!
  @IBOutlet weak var firstContainer: UIView!
  @IBOutlet weak var firstScoreBorder: ScoreBorder!
  @IBOutlet weak var firstNumber: UICountingLabel!
  @IBOutlet weak var firstMiniIcon: UIImageView!
  @IBOutlet weak var secondContainer: UIView!
  @IBOutlet weak var secondScoreBorder: ScoreBorder!
  @IBOutlet weak var secondNumber: UICountingLabel!
  @IBOutlet weak var secondMiniIcon: UIImageView!
  @IBOutlet weak var thirdContainer: UIView!
  @IBOutlet weak var thirdScoreBorder: ScoreBorder!
  @IBOutlet weak var thirdNumber: UICountingLabel!
  @IBOutlet weak var thirdMiniIcon: UIImageView!
  @IBOutlet weak var wakeUpContainer: UIView!
  @IBOutlet weak var selfImprovementContainer: UIView!
  @IBOutlet weak var duelContainer: UIView!
  
  var inProgressChallenges:Int = 0
  var wins:Int = 0
  var points:Int = 0
  
  var items: [Int] = []
  @IBOutlet var carousel : iCarousel!
  
  override func awakeFromNib()
  {
    super.awakeFromNib()
    for i in 0...6
    {
      items.append(i)
    }
  }
  
  func printFonts() {
    let fontFamilyNames = UIFont.familyNames()
    for familyName in fontFamilyNames {
      print("------------------------------")
      print("Font Family Name = [\(familyName)]")
      let names = UIFont.fontNamesForFamilyName(familyName as! String)
      print("Font Names = [\(names)]")
    }
  }
  
  override func viewDidLoad(){
    
    super.viewDidLoad()
    Async.background{
      CHRequests().getFriends(CHSession().currentUserId, completitionHandler: { (result, json) in
        
      })
      CHRequests().getAllUsers { (result, json) in
        
      }
    }
    
    
    
    
    //    printFonts()
    
    if appDelegate.mainViewController == nil {
      appDelegate.mainViewController = self
    }
    
    //    asdas
    let userObject:JSON       = CHSession().currentUserObject
    self.inProgressChallenges = userObject["inProgressChallengesCount"].intValue
    self.wins                 = userObject["successChallenges"].intValue
    self.points               = userObject["score"].intValue
    
    self.wellcomeLabel.text = "Wellcome \(CHSession().currentUserName)"
    self.wellcomeLabel.adjustsFontSizeToFitWidth = true
    
    carousel.delegate   = self
    carousel.dataSource = self
    carousel.type       = .Rotary
    
    animateScoreBorders()
    
    
    self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "BebasNeueRegular", size: 18)!,  NSForegroundColorAttributeName: CHUIElements().APPColors["title"]!]
    navigationController!.navigationBar.barTintColor = CHUIElements().APPColors["navigationBar"]
    navigationController!.navigationBar.tintColor    = UIColor.whiteColor()
    self.view.bringSubviewToFront(self.plusIcon)
    
    self.plusIcon.addGestureRecognizer(plusTapped)
    self.navigationItem.hidesBackButton = true
    self.navigationItem.leftBarButtonItem = nil
    CHImages().setUpBackground(background, frame: self.view.frame)
    // Do any additional setup after loading the view, typically from a nib.
  }
  
  
  override func viewDidAppear(animated: Bool) {
    
  }
  
  func numberOfItemsInCarousel(carousel: iCarousel) -> Int
  {
    return items.count
  }
  
  func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
    var containerView: UIView
    
    //create new view if no view is available for recycling
    if (view == nil) {
      
      
      //don't do anything specific to the index within
      //this `if (view == nil) {...}` statement because the view will be
      //recycled and used with other index values later
      let frame = CGRect(x:0, y:5, width:self.view.frame.size.width / 1.7, height: self.view.frame.size.height / 2.2)
      switch index {
      case 0:
        let itemView = WakeUpChallenge(frame:frame)
        itemView.setUp()
        containerView = itemView
        break
      case 1:
        let itemView = SelfImprovementWin(frame:frame)
        itemView.setUp()
        containerView = itemView
        break
      case 2:
        let itemView = SelfImprovementDone(frame:frame)
        itemView.setUp()
        containerView = itemView
        break
      case 3:
        let itemView = SelfImprovementInProgress(frame:frame)
        itemView.setUp()
        containerView = itemView
        break
      case 4:
        let itemView = SelfImprovementInProgress(frame:frame)
        itemView.setUp()
        containerView = itemView
        break
      case 5:
        let itemView = SelfImprovementInProgress(frame:frame)
        itemView.setUp()
        containerView = itemView
        break
      case 6:
        let itemView = SelfImprovementInProgress(frame:frame)
        itemView.setUp()
        containerView = itemView
        break
        
      default:
        let itemView = WakeUpChallenge(frame:frame)
        itemView.setUp()
        containerView = itemView
        
      }
      
      
    } else {
      //get a reference to the label in the recycled view
      let itemView = view!
      containerView = itemView
    }
    
    
    return containerView
  }
  
  func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
    switch option {
    case .Spacing:
      return value * 1.1
    case .Wrap:
      return 0.0
    default:
      return value
    }
  }
  
  
  
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func animateScoreBorders() {
    firstScoreBorder.rotateScoreViewToZero()
    firstScoreBorder.rotateView(1.0)
    firstScoreBorder.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        self.firstNumber.hidden = false
        self.firstScoreBorder.fillScoreBorder(1.0)
        self.firstContainer.bringSubviewToFront(self.firstNumber)
        self.firstNumber.method   = UILabelCountingMethodLinear
        self.firstNumber.format   = "%d";
        self.firstMiniIcon.hidden = false
        self.firstNumber.countFrom(0, to: Float(self.inProgressChallenges))
      }
    }
    
    secondScoreBorder.rotateScoreViewToZero()
    secondScoreBorder.rotateView(1.0)
    secondScoreBorder.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        self.secondNumber.hidden = false
        self.secondScoreBorder.fillScoreBorder(1.0)
        self.secondContainer.bringSubviewToFront(self.secondNumber)
        self.secondNumber.method   = UILabelCountingMethodLinear
        self.secondNumber.format   = "%d";
        self.secondMiniIcon.hidden = false
        self.secondNumber.countFrom(0, to: Float(self.wins))
      }
    }
    
    thirdScoreBorder.rotateScoreViewToZero()
    thirdScoreBorder.rotateView(1.0)
    thirdScoreBorder.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        self.thirdNumber.hidden = false
        self.thirdScoreBorder.fillScoreBorder(1.0)
        self.thirdContainer.bringSubviewToFront(self.thirdNumber)
        self.thirdNumber.method   = UILabelCountingMethodLinear
        self.thirdNumber.format   = "%d";
        self.thirdMiniIcon.hidden = false
        self.thirdNumber.countFrom(0, to: Float(self.points))
      }
    }
    
    carousel.scrollToItemAtIndex(99, duration: 2)
  }
  
  
  @IBOutlet var plusIconTapped: UITapGestureRecognizer!
  
  @IBAction func plusIconTappedAction(sender: AnyObject) {
    
    opened ? closeAction(): openAction()
    
    self.opened = !self.opened
  }
  
  @IBOutlet var plusTapped: UITapGestureRecognizer!
  
  @IBAction func centerTappedAction(sender: AnyObject) {
    opened ? closeAction(): openAction()
    
    self.opened = !self.opened
    
  }
  
  func closeAction() {
    self.wakeUpContainer.hidden = true
    self.selfImprovementContainer.hidden = true
    self.duelContainer.hidden = true
    
    UIView.animateWithDuration(0.5, animations: {
      self.plusIcon.transform = CGAffineTransformMakeRotation((0 * CGFloat(M_PI)) / 180.0)
    })
    
    UIView.animateWithDuration(0.5, animations: {
      self.carousel.layer.opacity = 1
    })
    
    
    UIView.animateWithDuration(0.5 , animations: {
      self.centerBackground.transform = CGAffineTransformMakeScale(1, 1)
    })
  }
  
  func openAction() {
    UIView.animateWithDuration(0.5, animations: {
      self.plusIcon.transform = CGAffineTransformMakeRotation((45 * CGFloat(M_PI)) / 180.0)
    })
    
    UIView.animateWithDuration(0.5, animations: {
      self.carousel.layer.opacity = 0
    })
    
    Async.main(after: 0.5) {
      self.wakeUpContainer.hidden = false
      self.selfImprovementContainer.hidden = false
      self.duelContainer.hidden = false
      
    }
    
    UIView.animateWithDuration(0.5 , animations: {
      self.centerBackground.transform = CGAffineTransformMakeScale(4, 4)
    })
  }
  
  
  @IBAction func logOutAction(sender: AnyObject) {
    CHSession().clearSession()
    let mainStoryboard: UIStoryboard                 = UIStoryboard(name: "Main",bundle: nil)
    let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
    presentViewController(roleControlViewController, type: .push, animated: false)
  }
  
  
  
  
}

