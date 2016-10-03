  
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
    
    var centerTapped:Bool = false
    var inProgressChallenges:Int = 0
    var wins:Int = 0
    var points:Int = 0
    
    var items: [Int] = []
    
    var challenges:[JSON] = []
    var itemViewArray:[UIView] = []
    @IBOutlet var carousel : iCarousel!
    
    let center = NSNotificationCenter.defaultCenter()
    
    func printFonts() {
      let fontFamilyNames = UIFont.familyNames()
      for familyName in fontFamilyNames {
        
        
        let names = UIFont.fontNamesForFamilyName(familyName )
        
      }
    }
    
    
    func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
      return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: "main", userInfo: nil, repeats: false)
    }
    
    func showModal() {
      let mainStoryboard: UIStoryboard          = UIStoryboard(name: "Main",bundle: nil)
      let WakeUpInfoViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("WakeUpInfoViewController")
      WakeUpInfoViewController.modalPresentationStyle = .OverCurrentContext
      presentViewController(WakeUpInfoViewController, animated: true, completion: nil)
    }
    
    func fillCarousel() {
      Async.main{
        
        for item in self.itemViewArray {
          item.removeFromSuperview()
        }
        self.itemViewArray.removeAll()
        self.challenges.removeAll()
        self.challenges = CHChalenges().getInProgressChallenges(CHSession().currentUserId).reverse()
        
        let frame = CGRect(x:0, y:-5, width:self.view.frame.size.width / 1.7, height: (self.view.frame.size.height / 2.2) - 5)
        
        
        for challenge in self.challenges {
          var containerView: UIView
          let challengeType = CHChalenges().getChallengeType(challenge)
          
          var timeIdentifier = "0"
          if  challenge["senderProgress"] != nil {
            timeIdentifier = challenge["senderProgress"][challenge["senderProgress"].count - 1]["at"].stringValue
          }
          
          let cardIdentifier = "\(challenge["_id"].stringValue)-\(challengeType.rawValue)-\(timeIdentifier)"
          if self.appDelegate.mainViewCard[cardIdentifier] != nil {
            containerView = self.appDelegate.mainViewCard[cardIdentifier]!
          } else {
            
            switch challengeType {
            case .unconfirmedDuelRecipient:
              let itemView = UnConfirmedDuel(frame:frame)
              itemView.setUp(challenge)
              containerView = itemView
              break
              
            case .unconfirmedDuelSender:
              let itemView = UnConfirmedDuelSender(frame:frame)
              itemView.setUp(challenge)
              containerView = itemView
              break
              
            case .startedSelfImprovement:
              let itemView = SelfImprovementInProgress(frame:frame)
              itemView.setUp(challenge)
              containerView = itemView
              break
              
            case .confirmedSelfImprovement:
              let itemView = SelfImprovementDone(frame:frame)
              itemView.setUp(challenge)
              containerView = itemView
              break
              
            case .wakeUpChallenge:
              let itemView = WakeUpChallenge(frame:frame)
              itemView.setUp(challenge)
              containerView = itemView
              break
              
            case .startedDuel:
              let itemView = ConfirmedDuel(frame:frame)
              itemView.setUp(challenge)
              containerView = itemView
              break
              
            case .checkedForToday:
              let itemView = CheckedDuel(frame:frame)
              itemView.setUp(challenge)
              containerView = itemView
              break
            case .waitingForNextDayWakeUp:
              let itemView = WakeUpChallenge(frame:frame)
              itemView.setUp(challenge)
              containerView = itemView
              break
            case .timedOutWakeUp:
              let itemView = TimedOutWakeUp(frame:frame)
              itemView.setUp(challenge)
              containerView = itemView
              break
              
              
            default:
              let itemView = WakeUpChallenge(frame:frame)
              itemView.setUp(challenge)
              containerView = itemView
            }
            
            self.appDelegate.mainViewCard[cardIdentifier] = containerView
          }
          
          
          
          self.itemViewArray.append(containerView)
        }
        
        
        self.carousel.reloadData()
        let duration:Double = Double(self.challenges.count / 6)
        if self.challenges.count > 15 {
          self.carousel.scrollToItemAtIndex(self.challenges.count - 1, animated: true)
        } else {
          self.carousel.scrollToItemAtIndex(self.challenges.count - 1, duration: duration)
        }
        
        self.firstNumber.text = "\(self.inProgressChallenges)"
        self.secondNumber.text = "\(self.wins)"
        self.thirdNumber.text = "\(self.points)"
        
        
      }
    }
    
    func fillCHallenges() {
      if IJReachability.isConnectedToNetwork() {
        CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId) { (result, json) in
          if result {
            self.fillCarousel()
          }
        }
      } else {
        fillCarousel()
      }
    }
    
    override func viewDidLoad(){
      CHUsers().getUsersFirebase { (result) in
        
      }
      self.navigationController?.setNavigationBarHidden(false, animated: false)
      super.viewDidLoad()
      center.addObserver(self, selector: #selector(MainViewController.setUpBehavior), name: "setUpBehavior", object: nil)
      if CHSession().logined {
        self.setUpBehavior()
      }
      
      self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "BebasNeueRegular", size: 18)!,  NSForegroundColorAttributeName: CHUIElements().APPColors["title"]!]
      navigationController!.navigationBar.barTintColor = CHUIElements().APPColors["navigationBar"]
      navigationController!.navigationBar.tintColor    = UIColor.whiteColor()
      
      self.navigationItem.hidesBackButton = true
      self.navigationItem.leftBarButtonItem = nil
      
      
    }
    
    
    func setUpBehavior() {
      Async.background{
        if IJReachability.isConnectedToNetwork()  {
          
          CHRequests().checkUser(CHSession().currentUserId) { (json, status) in
            if !status {
              CHPush().alertPush(json.stringValue, type: "Warning")
              Async.main {
                CHSession().clearSession({ (result) in
                  if result {
                    Async.main {
                      let mainStoryboard: UIStoryboard                 = UIStoryboard(name: "Main",bundle: nil)
                      let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
                      self.presentViewController(roleControlViewController, type: .push, animated: false)
                    }
                  }
                })
              }
            }
          }
        }
        
      }
      
      Async.background{
        CHRequests().getFriends(CHSession().currentUserId, completitionHandler: { (result, json) in
          
        })
        CHRequests().getAllUsers { (result, json) in
          
        }
        
        CHRequests().getChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
          
        })
        
        CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId, completitionHandler: { (result, json) in
          if result {
            CHWakeUpper().setUpWakeUp()
          }
        })
        
      }
      
      self.getUserData()
      
      
      self.wellcomeLabel.text = "Welcome \(CHSession().currentUserName)"
      self.wellcomeLabel.adjustsFontSizeToFitWidth = true
      
      
      self.carousel.delegate   = self
      self.carousel.dataSource = self
      self.carousel.type       = .Rotary
      self.carousel.layer.opacity = 0.0
      
      
      self.animateScoreBorders()
      self.view.bringSubviewToFront(self.plusIcon)
      
      self.plusIcon.addGestureRecognizer(plusTapped)
      
      CHImages().setUpBackground(background, frame: self.view.frame)
      
    }
    
    
    func getUserData() {
      CHRequests().updateUserFromRemote { (result, json) in
        if result {
          let userObject:JSON       = CHSession().currentUserObject
          self.inProgressChallenges = userObject["inProgressChallengesCount"].intValue
          self.wins                 = userObject["successChallenges"].intValue
          self.points               = userObject["allChallengesCount"].intValue + userObject["inProgressChallengesCount"].intValue
        }
        
      }
      
      let userObject:JSON       = CHSession().currentUserObject
      self.inProgressChallenges = userObject["inProgressChallengesCount"].intValue
      self.wins                 = userObject["successChallenges"].intValue
      self.points               = userObject["allChallengesCount"].intValue + userObject["inProgressChallengesCount"].intValue
      
      
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
      if let touch = touches.first {
        if opened {
          if touch.view != plusIcon {
            checkerAction()
          }
        }
      }
      super.touchesBegan(touches, withEvent:event)
      
      
    }
    
    func refreshCarousel() {
      
      if opened {
        checkerAction()
      }
      
      
      CHRequests().updateUserFromRemote { (result, json) in
        if result {
          Async.main {
            self.challenges.removeAll()
            self.challenges = CHChalenges().getInProgressChallenges(CHSession().currentUserId).reverse()
            self.fillCHallenges()
            
          }
          CHRequests().updateUserFromRemote { (result, json) in
            if result {
              Async.main {
                let userObject:JSON       = CHSession().currentUserObject
                self.inProgressChallenges = userObject["inProgressChallengesCount"].intValue
                self.wins                 = userObject["successChallenges"].intValue
                self.points               = userObject["allChallengesCount"].intValue + userObject["inProgressChallengesCount"].intValue
                
                self.firstNumber.text = "\(self.inProgressChallenges)"   //.countFrom(0, to: Float(self.inProgressChallenges))
                self.secondNumber.text = "\(self.wins)" //.countFrom(0, to: Float(self.wins))
                self.thirdNumber.text = "\(self.points)" //.countFrom(0, to: Float(self.points))
              }
            }
          }
        }
      }
      
    }
    
    override func viewDidAppear(animated: Bool) {
      center.addObserver(self, selector: #selector(MainViewController.refreshCarousel), name: "refreshIcarousel", object: nil)
      center.addObserver(self, selector: #selector(MainViewController.showModal), name: "wakeUpCreated", object: nil)
      self.fillCarousel()
    }
    
    override func viewDidDisappear(animated: Bool) {
      //    self.view.removeFromSuperview()
      self.center.removeObserver(self, name: "refreshIcarousel", object: nil)
      self.center.removeObserver(self, name: "wakeUpCreated", object: nil)
      
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
      //    return CHChalenges().getInProgressChallenges(CHSession().currentUserId).count
      return self.itemViewArray.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
      
      let containerView = itemViewArray[index]
      
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
          if self.inProgressChallenges >= 15 {
            self.firstNumber.text = "\(self.inProgressChallenges)"
          } else {
            self.firstNumber.animationDuration = 1.0
            self.firstNumber.countFrom(0, to: Float(self.inProgressChallenges))
          }
          
          
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
          if self.inProgressChallenges >= 15 {
            self.secondNumber.text = "\(self.wins)"
          } else {
            self.secondNumber.animationDuration = 1.0
            self.secondNumber.countFrom(0, to: Float(self.wins))
          }
          
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
          
          if self.points >= 15 {
            self.thirdNumber.text = "\(self.points)"
          } else {
            self.thirdNumber.animationDuration = 1.0
            self.thirdNumber.countFrom(0, to: Float(self.points))
            
          }
          self.fillCHallenges()
          
          
        }
      }
      
      UIView.animateWithDuration(2.0) {
        self.carousel.layer.opacity = 1.0
      }
      
      
    }
    
    @IBOutlet var plusIconTapped: UITapGestureRecognizer!
    
    @IBAction func plusIconTappedAction(sender: AnyObject) {
      
      checkerAction()
      
    }
    
    @IBOutlet var plusTapped: UITapGestureRecognizer!
    
    @IBAction func centerTappedAction(sender: AnyObject) {
      if self.challenges.count >= 30 {
        CHPush().alertPush("Can`t add new challenge", type: "Warning")
        return
      }
      checkerAction()
      
    }
    
    func checkerAction() {
      if !centerTapped {
        centerTapped = true
        opened ? closeAction(): openAction()
        
        self.opened = !self.opened
        self.setTimeout(0.7, block: {
          self.centerTapped = false
        })
      }
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
      //    CHSession().clearSession()
      //    let mainStoryboard: UIStoryboard                 = UIStoryboard(name: "Main",bundle: nil)
      //    let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
      //    presentViewController(roleControlViewController, type: .push, animated: false)
    }
    
    
    
  }
  
