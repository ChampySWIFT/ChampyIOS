//
//  HistoryViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/26/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import CoreMotion
import Firebase

class HistoryViewController: UIViewController {
  let appDelegate     = UIApplication.shared.delegate as! AppDelegate
  
  @IBOutlet weak var segmentControl: UISegmentedControl!
  @IBOutlet weak var contentScrollView: UIScrollView!
  @IBOutlet weak var background: UIImageView!
  
  var table1 = HistoryTableViewController()
  var table2 = HistoryTableViewController() 
  var table3 = HistoryTableViewController()
  

  
  var pageImages: [UIImage]       = []
  var pageViews: [UIImageView?]   = []
  var manager: CMMotionManager!
  @IBOutlet weak var challengesBatButtonItem: UIBarButtonItem!
  @IBOutlet weak var friendsBarButton: UIBarButtonItem!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    table1.type = .inProgress
    table2.type = .wins
    table3.type = .failed
    
    
    var unconfirmedChallenges:Int = 0
    self.appDelegate.unconfirmedChallenges = unconfirmedChallenges
    
    for challenge in CHChalenges().getInProgressChallenges(CHSession().currentUserId).reversed() {
      let challengeType = CHChalenges().getChallengeType(challenge)
      if challengeType == .unconfirmedDuelRecipient || challengeType == .unconfirmedDuelSender {
        unconfirmedChallenges += 1
        self.appDelegate.unconfirmedChallenges = unconfirmedChallenges
      }
    }
    
    if appDelegate.unconfirmedChallenges > 0 {
      if self.challengesBatButtonItem.badgeLayer != nil {
        self.challengesBatButtonItem.updateBadge(number: appDelegate.unconfirmedChallenges)
      } else {
        self.challengesBatButtonItem.addBadge(number: appDelegate.unconfirmedChallenges)
      }
    }
    
    if appDelegate.unconfirmedChallenges == 0 {
      if self.challengesBatButtonItem.badgeLayer != nil {self.challengesBatButtonItem.removeBadge()}
    }
    
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
    if appDelegate.historyViewController == nil {
      appDelegate.historyViewController = self
    }
    CHImages().setUpBackground(background, frame: self.view.frame)
    let attr = NSDictionary(object: UIFont(name: "BebasNeueRegular", size: 16.0)!, forKey: NSFontAttributeName as NSCopying)
    segmentControl.setTitleTextAttributes((attr as! [AnyHashable: Any]) , for: UIControlState())
    
    
    Async.background{
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
      if IJReachability.isConnectedToNetwork()  {
        
        CHRequests().checkUser(CHSession().currentUserId) { (json, status) in
          if !status {
            CHPush().alertPush(json.stringValue, type: "Warning")
            Async.main {
              CHSession().clearSession({ (result) in
                if result {
                  Async.main {
                    self.navigationController?.performSegue(withIdentifier: "showRoleControllerFromNavigation", sender: self)
                  }
                }
              })
            }
          }
        }
      }
      
    }
    
    
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func changedSegmentControl(_ sender: AnyObject) {
    switch segmentControl.selectedSegmentIndex {
    case 1:
      let p =  CGPoint(x:self.view.frame.size.width,y:0)
      contentScrollView.setContentOffset(p, animated: true)
      break
    case 2:
      let p =  CGPoint(x:self.view.frame.size.width * 2,y:0)
      contentScrollView.setContentOffset(p, animated: true)
      break
    case 0:
      let p =  CGPoint(x:0,y:0)
      contentScrollView.setContentOffset(p, animated: true)
      break
      
    default:
      let p =  CGPoint(x:0,y:0)
      contentScrollView.setContentOffset(p, animated: true)
    }
  }
  
  
  
  
  //function of FBSDKAppInviteDialogDelegate
  func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!){
    // my code here
  }
  
  func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
    
  }
  
  
  func scrollViewDidScroll(_ scrollView: UIScrollView!) {
    // Load the pages that are now on screen
    //    let point = CGPointMake(scrollView.contentOffset.x, 0)
    //    scrollView.setContentOffset(point, animated: false)
    loadVisiblePages()
  }
  
  
  override func viewDidAppear(_ animated: Bool) {
    manager = CMMotionManager()
    if manager.isDeviceMotionAvailable {
      manager.deviceMotionUpdateInterval = 0.01
      
      manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { (data, error) in
        if (data?.userAcceleration.x)! < Double(-2.5) {
          self.navigationController?.popViewController(animated: true)
        }
        
      })
    }
    
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
    
    if appDelegate.historyTable1 != nil {
      table1 = appDelegate.historyTable1
    } else {
      appDelegate.historyTable1 = mainStoryboard.instantiateViewController(withIdentifier: "HistoryTableViewController") as! HistoryTableViewController
      table1 = appDelegate.historyTable1
    }
    
    if appDelegate.historyTable2 != nil {
      table2 = appDelegate.historyTable2
    } else {
      appDelegate.historyTable2 = mainStoryboard.instantiateViewController(withIdentifier: "HistoryTableViewController") as! HistoryTableViewController
      table2 = appDelegate.historyTable2
    }
    
    if appDelegate.historyTable3 != nil {
      table3 = appDelegate.historyTable3
    } else {
      appDelegate.historyTable3 = mainStoryboard.instantiateViewController(withIdentifier: "HistoryTableViewController") as! HistoryTableViewController
      table3 = appDelegate.historyTable3
    }
    
    
    table1.type = .inProgress
    table2.type = .wins
    table3.type = .failed
    
    
    self.setUpFrames()
    self.addChildViewController(table1)
    self.addChildViewController(table2)
    self.addChildViewController(table3)
    table1.didMove(toParentViewController: self)
    table2.didMove(toParentViewController: self)
    table3.didMove(toParentViewController: self)
    contentScrollView.addSubview(table1.tableView)
    contentScrollView.addSubview(table2.tableView)
    contentScrollView.addSubview(table3.tableView)
    
    
    
    loadVisiblePages()
    contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    self.contentScrollView.contentSize = CGSize(width: (self.view.frame.size.width * 3.0), height: contentScrollView.frame.size.height)
    
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    self.manager.stopDeviceMotionUpdates()
  }
  
  func setUpFrames() {
    
    
    let pagesScrollViewSize = contentScrollView.frame.size
    contentScrollView.contentSize  = CGSize(width: self.view.frame.size.width * 3, height: self.view.frame.size.height )
    contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    
    var firstFrame:CGRect  = table1.tableView.frame
    firstFrame.origin.x    = 0
    firstFrame.origin.y    = 0
    firstFrame.size.width  = self.contentScrollView.frame.size.width
    firstFrame.size.height = self.contentScrollView.frame.size.height
    table1.tableView.frame = firstFrame
    
    var secondFrame:CGRect  = table2.tableView.frame
    secondFrame.origin.x    = self.contentScrollView.frame.size.width
    secondFrame.origin.y    = 0
    secondFrame.size.width  = self.contentScrollView.frame.size.width
    secondFrame.size.height = self.contentScrollView.frame.size.height
    table2.tableView.frame = secondFrame
    
    var thirdFrame:CGRect  = table3.tableView.frame
    thirdFrame.origin.x    = self.contentScrollView.frame.size.width * 2
    thirdFrame.origin.y    = 0
    thirdFrame.size.width  = self.contentScrollView.frame.size.width
    thirdFrame.size.height = self.contentScrollView.frame.size.height
    table3.tableView.frame = thirdFrame
    
    contentScrollView.isScrollEnabled = false
  }
  
  
  func loadVisiblePages() {
    
    // First, determine which page is currently visible
    let pageWidth = contentScrollView.frame.size.width
    
    let page      = Int(floor((contentScrollView.contentOffset.x * 3.0 + pageWidth) / (pageWidth * 3.0)))
    
    
    if page == 0 {
      segmentControl.selectedSegmentIndex = 0
      
      return
    }
    
    if page == 1 {
      segmentControl.selectedSegmentIndex = 1
      
      return
    }
    
    
    if page == 2 {
      segmentControl.selectedSegmentIndex = 2
      
      return
    }
  } 
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
