  
  //
  //  ViewController.swift
  //  ChampySwift
  //
  //  Created by Molnar Kristian on 4/23/16.
  //  Copyright © 2016 AzinecLLC. All rights reserved.
  //
  
  import UIKit
  import Async
  import SwiftyJSON
//  import UIViewBadge
  import CoreMotion
  
  class MainViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {
    let appDelegate     = UIApplication.shared.delegate as! AppDelegate
    let CurrentUser = UserDefaults.standard
    
    @IBOutlet weak var wellcomeLabel: UILabel!
    @IBOutlet weak var mainMenu: UIView!
    @IBOutlet weak var centerBackground: UIImageView!
    @IBOutlet weak var plusIcon: UIImageView!
    var opened:Bool = false
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var challengeButton: UIButton!
    
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
    @IBOutlet weak var friendsBarButton: UIBarButtonItem!
    
    @IBOutlet weak var challengesbarButton: UIBarButtonItem!
    var centerTapped:Bool = false
    var inProgressChallenges:Int = 0
    var wins:Int = 0
    var points:Int = 0
    
    var items: [Int] = []
    
    var challenges:[JSON] = []
    var itemViewArray:[UIView] = []
    @IBOutlet var carousel : iCarousel!
    
    let center = NotificationCenter.default
    
    
    var manager: CMMotionManager!
    
    deinit {
      print("valami")
    }
    
    func printFonts() {
      let fontFamilyNames = UIFont.familyNames
      for familyName in fontFamilyNames {
        let names = UIFont.fontNames(forFamilyName: familyName )
      }
    }
    
    
    func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
      return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
    }
    
    func showModal() {
      let mainStoryboard: UIStoryboard          = UIStoryboard(name: "Main",bundle: nil)
      let WakeUpInfoViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "WakeUpInfoViewController")
      WakeUpInfoViewController.modalPresentationStyle = .overCurrentContext
      present(WakeUpInfoViewController, animated: true, completion: nil)
    }
    
    func fillCarousel() {
      Async.main{
        var firstIncomigRequestCount:Int = -1
        var i:Int = 0
        var unconfirmedChallenges:Int = 0
        self.appDelegate.unconfirmedChallenges = unconfirmedChallenges
        for item in self.itemViewArray {
          item.removeFromSuperview()
        }
        self.itemViewArray.removeAll()
        self.challenges.removeAll()
        self.challenges = CHChalenges().getInProgressChallenges(CHSession().currentUserId).reversed()
        
        let height = self.carousel.frame.size.height
        
//        let frame = CGRect(x:0, y:-5, width:self.view.frame.size.width / 1.7, height: (self.view.frame.size.height / 2.2) - 5)
        let frame = CGRect(x:0, y:-5, width:self.view.frame.size.width / 1.4, height: height)
        
        for challenge in self.challenges {
          
          var containerView: UIView
          let challengeType = CHChalenges().getChallengeType(challenge)
          if challengeType == .unconfirmedDuelRecipient || challengeType == .unconfirmedDuelSender {
            if challengeType == .unconfirmedDuelRecipient {
              firstIncomigRequestCount = i
            }
            unconfirmedChallenges += 1
            self.appDelegate.unconfirmedChallenges = unconfirmedChallenges
          }
          i += 1
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
        
        self.firstNumber.text = "\(self.inProgressChallenges)"
        self.secondNumber.text = "\(self.wins)"
        self.thirdNumber.text = "\(self.points)"
        
        if unconfirmedChallenges > 0 {
          if self.challengesbarButton.badgeLayer != nil {
            self.challengesbarButton.updateBadge(number: unconfirmedChallenges)
          } else {
            self.challengesbarButton.addBadge(number: unconfirmedChallenges)
          }
        }
        
        if unconfirmedChallenges == 0 {
          if self.challengesbarButton.badgeLayer != nil {self.challengesbarButton.removeBadge()}
        }
        
        if firstIncomigRequestCount != -1 {
          let duration:Double = Double(self.challenges.count / 6)
          if self.challenges.count > 15 {
            self.carousel.scrollToItem(at: firstIncomigRequestCount, animated: true)
          } else {
            self.carousel.scrollToItem(at: firstIncomigRequestCount, duration: duration)
          }
        } else {
          let duration:Double = Double(self.challenges.count / 6)
          if self.challenges.count > 15 {
            self.carousel.scrollToItem(at: self.challenges.count - 1, animated: true)
          } else {
            self.carousel.scrollToItem(at: self.challenges.count - 1, duration: duration)
          }
          
        }
        
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
      
      self.navigationController?.setNavigationBarHidden(false, animated: false)
      super.viewDidLoad()
      self.navigationController?.setNavigationBarHidden(false, animated: false)
      center.addObserver(self, selector: #selector(MainViewController.setUpBehavior), name: NSNotification.Name(rawValue: "setUpBehavior"), object: nil)
      if CHSession().logined {
        self.setUpBehavior()
      }
      
      self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "BebasNeueRegular", size: 18)!,  NSForegroundColorAttributeName: CHUIElements().APPColors["title"]!]
     // navigationController!.navigationBar.barTintColor = CHUIElements().APPColors["navigationBar"]
     // navigationController!.navigationBar.tintColor    = UIColor.white
      
      self.navigationItem.hidesBackButton = true
      self.navigationItem.leftBarButtonItem = nil
//      self.carousel
//      challengeView.type       = .linear
//      challengeView.decelerationRate = 0.0
      
//      self.challengesBarButton.customView?.addSubview(badge)
      
    }
    
    func buildACustomButton() -> UIButton {
      let button = UIButton(type: UIButtonType.infoDark)
      button.frame = CGRect(x:0, y:0, width: 24, height: 24);
      button.backgroundColor = UIColor.blue;
      return button;
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
                      let roleControlViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "RoleControlViewController")
//                      self.presentViewController(roleControlViewController, animated: false, completion: .push)
                      self.present(roleControlViewController, animated: false, completion: {
                        
                      })
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
          Async.main {
            let friendsBadgeCount = CHUsers().getIncomingRequestCount()
            if friendsBadgeCount > 0 {
              if self.friendsBarButton.badgeLayer != nil {
                self.friendsBarButton.updateBadge(number: friendsBadgeCount)
              } else {
                self.friendsBarButton.addBadge(number: friendsBadgeCount)
              }
            }
            
            if CHUsers().getIncomingRequestCount() == 0 {
              if self.friendsBarButton.badgeLayer != nil {self.friendsBarButton.removeBadge()}
            }
          }
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
      self.carousel.type       = .rotary
      self.carousel.layer.opacity = 0.0
      
      
      self.animateScoreBorders()
      self.view.bringSubview(toFront: self.plusIcon)
      
      self.plusIcon.addGestureRecognizer(plusTapped)
      
      CHImages().setUpBackground(background, frame: self.view.frame)
      manager = CMMotionManager()
      if manager.isGyroAvailable {
        
      }
      
      manager.startGyroUpdates()
      
      let queue = OperationQueue.main
      
      if manager.isDeviceMotionAvailable {
        manager.deviceMotionUpdateInterval = 0.01
        
        manager.startDeviceMotionUpdates(to: queue, withHandler: { (data, error) in
          if (data?.userAcceleration.z)! < Double(-2.5) {
//            self.dismiss(animated: true, completion: {
//              
//            })
            self.centerTappedAction(self)
//            self.openAction()
          }
          
        })
      }
    }
    
    
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
      switch option {
      case .spacing:
        return value * 1.1
      case .wrap:
        return 0.0
      default:
        return value
      }
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      if let touch = touches.first {
        if opened {
          if touch.view != plusIcon {
            checkerAction()
          }
        }
      }
      super.touchesBegan(touches, with:event)
      
      
    }
    
    func refreshCarousel() {
      
      if opened {
        checkerAction()
      }
      
      
      CHRequests().updateUserFromRemote { (result, json) in
        if result {
          Async.main {
            self.challenges.removeAll()
            self.challenges = CHChalenges().getInProgressChallenges(CHSession().currentUserId).reversed()
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
    
    override func viewDidAppear(_ animated: Bool) {
      center.addObserver(self, selector: #selector(MainViewController.refreshCarousel), name: NSNotification.Name(rawValue: "refreshIcarousel"), object: nil)
      center.addObserver(self, selector: #selector(MainViewController.showModal), name: NSNotification.Name(rawValue: "wakeUpCreated"), object: nil)
      self.fillCarousel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
      //    self.view.removeFromSuperview()
      self.center.removeObserver(self, name: NSNotification.Name(rawValue: "refreshIcarousel"), object: nil)
      self.center.removeObserver(self, name: NSNotification.Name(rawValue: "wakeUpCreated"), object: nil)
      
    }
    
    func numberOfItems(in carousel: iCarousel) -> Int {
      //    return CHChalenges().getInProgressChallenges(CHSession().currentUserId).count
      return self.itemViewArray.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
      
      let containerView = itemViewArray[index]
      
      return containerView
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
          self.firstNumber.isHidden = false
          self.firstScoreBorder.fillScoreBorder(1.0)
          self.firstContainer.bringSubview(toFront: self.firstNumber)
          self.firstNumber.method   = UILabelCountingMethodLinear
          self.firstNumber.format   = "%d";
          self.firstMiniIcon.isHidden = false
          if self.inProgressChallenges >= 15 {
            self.firstNumber.text = "\(self.inProgressChallenges)"
          } else {
            self.firstNumber.animationDuration = 1.0
            self.firstNumber.count(from: 0, to: Float(self.inProgressChallenges))
          }
          
          
        }
      }
      
      secondScoreBorder.rotateScoreViewToZero()
      secondScoreBorder.rotateView(1.0)
      secondScoreBorder.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
        if ended {
          self.secondNumber.isHidden = false
          self.secondScoreBorder.fillScoreBorder(1.0)
          self.secondContainer.bringSubview(toFront: self.secondNumber)
          self.secondNumber.method   = UILabelCountingMethodLinear
          self.secondNumber.format   = "%d";
          self.secondMiniIcon.isHidden = false
          if self.inProgressChallenges >= 15 {
            self.secondNumber.text = "\(self.wins)"
          } else {
            self.secondNumber.animationDuration = 1.0
            self.secondNumber.count(from: 0, to: Float(self.wins))
          }
          
        }
      }
      
      thirdScoreBorder.rotateScoreViewToZero()
      thirdScoreBorder.rotateView(1.0)
      
      
      thirdScoreBorder.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
        if ended {
          self.thirdNumber.isHidden = false
          self.thirdScoreBorder.fillScoreBorder(1.0)
          self.thirdContainer.bringSubview(toFront: self.thirdNumber)
          self.thirdNumber.method   = UILabelCountingMethodLinear
          self.thirdNumber.format   = "%d";
          self.thirdMiniIcon.isHidden = false
          
          if self.points >= 15 {
            self.thirdNumber.text = "\(self.points)"
          } else {
            self.thirdNumber.animationDuration = 1.0
            self.thirdNumber.count(from: 0, to: Float(self.points))
            
          }
          self.fillCHallenges()
          
          
        }
      }
      
      UIView.animate(withDuration: 2.0, animations: {
        self.carousel.layer.opacity = 1.0
      }) 
      
      
    }
    
    @IBOutlet var plusIconTapped: UITapGestureRecognizer!
    
    @IBAction func plusIconTappedAction(_ sender: AnyObject) {
      
      checkerAction()
      
    }
    
    @IBOutlet var plusTapped: UITapGestureRecognizer!
    
    @IBAction func centerTappedAction(_ sender: AnyObject) {
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
      self.wakeUpContainer.isHidden = true
      self.selfImprovementContainer.isHidden = true
      self.duelContainer.isHidden = true
      
      UIView.animate(withDuration: 0.5, animations: {
        self.plusIcon.transform = CGAffineTransform(rotationAngle: (0 * CGFloat(M_PI)) / 180.0)
      })
      
      UIView.animate(withDuration: 0.5, animations: {
        self.carousel.layer.opacity = 1
      })
      
      
      UIView.animate(withDuration: 0.5 , animations: {
        self.centerBackground.transform = CGAffineTransform(scaleX: 1, y: 1)
      })
    }
    
    func openAction() {
      UIView.animate(withDuration: 0.5, animations: {
        self.plusIcon.transform = CGAffineTransform(rotationAngle: (45 * CGFloat(M_PI)) / 180.0)
      })
      
      UIView.animate(withDuration: 0.5, animations: {
        self.carousel.layer.opacity = 0
      })
      
      Async.main(after: 0.5) {
        self.wakeUpContainer.isHidden = false
        self.selfImprovementContainer.isHidden = false
        self.duelContainer.isHidden = false
        
      }
      
      UIView.animate(withDuration: 0.5 , animations: {
        self.centerBackground.transform = CGAffineTransform(scaleX: 4, y: 4)
      })
    }
    
    
    @IBAction func logOutAction(_ sender: AnyObject) {
      //    CHSession().clearSession()
      //    let mainStoryboard: UIStoryboard                 = UIStoryboard(name: "Main",bundle: nil)
      //    let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
      //    presentViewController(roleControlViewController, type: .push, animated: false)
    }
    
    
    
  }
  
  
  extension CAShapeLayer {
    
    
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
      fillColor = filled ? color.cgColor : UIColor.white.cgColor
      strokeColor = color.cgColor
      let origin = CGPoint(x: location.x - radius, y: location.y - radius)
      path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
  }
 
 
  private var handle: UInt8 = 0;
    
    extension UIBarButtonItem {
      
      var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
          return b as? CAShapeLayer
        } else {
          return nil
        }
      }
      
      func addBadge(number: Int, withOffset offset: CGPoint = CGPoint.zero, andFilled filled: Bool = true) {
        let color:UIColor = UIColor.red
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = "\(number)"
        label.alignmentMode = kCAAlignmentCenter
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
        label.foregroundColor = filled ? UIColor.white.cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      }
      
      func updateBadge(number: Int) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
          text.string = "\(number)"
        }
      }
      
      func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
      }
      
    }
  
  
