//
//  FriendsViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/26/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import CoreMotion

class FriendsViewController: UIViewController {
  let appDelegate     = UIApplication.shared.delegate as! AppDelegate
  
  var table3 = AllFriendsTableViewController()
  var table2 = PendingFriendsController()
  var table1 = FriendsTableViewController()
  var manager: CMMotionManager!
  let delegate = UIApplication.shared.delegate as! AppDelegate
  var pageImages: [UIImage]       = []
  var pageViews: [UIImageView?]   = []
  
  @IBOutlet weak var challengesBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var friendsBarButton: UIBarButtonItem!
  
  @IBOutlet weak var segmentControl: UISegmentedControl!
  @IBOutlet weak var contentScrollView: UIScrollView!
  @IBOutlet weak var background: UIImageView!
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(FriendsViewController.refreshBadge), name: NSNotification.Name(rawValue: "refreshBadge"), object: nil)
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
      if self.challengesBarButtonItem.badgeLayer != nil {
        self.challengesBarButtonItem.updateBadge(number: appDelegate.unconfirmedChallenges)
      } else {
        self.challengesBarButtonItem.addBadge(number: appDelegate.unconfirmedChallenges)
      }
    }
    
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
    if appDelegate.friendsViewController == nil {
      appDelegate.friendsViewController = self
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
    
    
    
  }
  
  
  
  func refreshBadge() {
    Async.background {
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
    }
  }
  
  @IBAction func shareAction(_ sender: AnyObject) {
    let textToShare = "Hey! I’ve just started using Champy. Join me so we can improve our lives together."
    if let myWebsite = URL(string: "https://itunes.apple.com/app/id1110777364") {
      
      let objectsToShare = [textToShare, myWebsite] as [Any]
      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      
      activityVC.popoverPresentationController?.sourceView = sender as? UIView
      self.present(activityVC, animated: true, completion: {
        
      })
      
    }
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
  
  
  
  
  
  
  func scrollViewDidScroll(_ scrollView: UIScrollView!) {
    print(self.table1.tableView.frame)
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
    
    if appDelegate.table3 != nil {
      table3 = appDelegate.table3
    } else {
      appDelegate.table3 = mainStoryboard.instantiateViewController(withIdentifier: "AllFriendsTableViewController") as! AllFriendsTableViewController
      table3 = appDelegate.table3
    }
    
    if appDelegate.table2 != nil {
      table2 = appDelegate.table2
    } else {
      appDelegate.table2 = mainStoryboard.instantiateViewController(withIdentifier: "PendingFriendsController") as! PendingFriendsController
      table2 = appDelegate.table2
    }
    
    if appDelegate.table1 != nil {
      table1 = appDelegate.table1
    } else {
      appDelegate.table1 = mainStoryboard.instantiateViewController(withIdentifier: "FriendsTableViewController") as! FriendsTableViewController
      table1 = appDelegate.table1
    }
    
    
    
    
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
    CHPush().localPush("pendingReload", object: self)
    CHPush().localPush("friendsReload", object: self)
    if CHUsers().getIncomingRequestCount() > 0 {
      let p =  CGPoint(x:self.view.frame.size.width,y:0)
      contentScrollView.setContentOffset(p, animated: false)
      
    }
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    manager.stopDeviceMotionUpdates()
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "inviteFriend"), object: nil)
  }
  
  func setUpFrames() {
    
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
    
    contentScrollView.contentSize  = CGSize(width: self.view.frame.size.width * 3, height: self.view.frame.size.height * 0.5)
    
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
  
  
  
}
