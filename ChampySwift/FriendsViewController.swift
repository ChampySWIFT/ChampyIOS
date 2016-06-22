//
//  FriendsViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/26/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
class FriendsViewController: UIViewController, FBSDKAppInviteDialogDelegate {
  let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
  
  var table3 = AllFriendsTableViewController()
  var table2 = PendingFriendsController()
  var table1 = FriendsTableViewController()
  
  let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
  var pageImages: [UIImage]       = []
  var pageViews: [UIImageView?]   = []
  
  
  @IBOutlet weak var segmentControl: UISegmentedControl!
  @IBOutlet weak var contentScrollView: UIScrollView!
  @IBOutlet weak var background: UIImageView!
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
    if appDelegate.friendsViewController == nil {
      appDelegate.friendsViewController = self
    }
    CHImages().setUpBackground(background, frame: self.view.frame)
    let attr = NSDictionary(object: UIFont(name: "BebasNeueRegular", size: 16.0)!, forKey: NSFontAttributeName)
    segmentControl.setTitleTextAttributes(attr as [NSObject : AnyObject] , forState: .Normal)
    
    Async.background{
      if IJReachability.isConnectedToNetwork()  {
        
        CHRequests().checkUser(CHSession().currentUserId) { (json, status) in
          if !status {
            CHPush().alertPush(json.stringValue, type: "Warning")
            Async.main {
              CHSession().clearSession()
              let mainStoryboard: UIStoryboard                 = UIStoryboard(name: "Main",bundle: nil)
              let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
              self.presentViewController(roleControlViewController, type: .push, animated: false)
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
  
  
  @IBAction func changedSegmentControl(sender: AnyObject) {
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
  
  @IBAction func inviteFriend(sender: AnyObject) {
    
    var inviteDialog:FBSDKAppInviteDialog = FBSDKAppInviteDialog()
    if(inviteDialog.canShow()){
      let appLinkUrl:NSURL = NSURL(string: "http://champyapp.com/")!
      
      let inviteContent:FBSDKAppInviteContent = FBSDKAppInviteContent()
      inviteContent.appLinkURL = appLinkUrl
      
      inviteDialog.content = inviteContent
      inviteDialog.delegate = self
      inviteDialog.show()
    }

    
  
  }
  
  
  //function of FBSDKAppInviteDialogDelegate
  func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!){
    // my code here
  }
  
  func appInviteDialog(appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [NSObject : AnyObject]!) {
    
  }
  
  
  func scrollViewDidScroll(scrollView: UIScrollView!) {
    // Load the pages that are now on screen
//    let point = CGPointMake(scrollView.contentOffset.x, 0)
//    scrollView.setContentOffset(point, animated: false)
    loadVisiblePages()
  }
  
  
  override func viewDidAppear(animated: Bool) {
    
    
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
    
    if appDelegate.table3 != nil {
      table3 = appDelegate.table3
    } else {
      appDelegate.table3 = mainStoryboard.instantiateViewControllerWithIdentifier("AllFriendsTableViewController") as! AllFriendsTableViewController
      table3 = appDelegate.table3
    }
    
    if appDelegate.table2 != nil {
      table2 = appDelegate.table2
    } else {
      appDelegate.table2 = mainStoryboard.instantiateViewControllerWithIdentifier("PendingFriendsController") as! PendingFriendsController
      table2 = appDelegate.table2
    }
    
    if appDelegate.table1 != nil {
      table1 = appDelegate.table1
    } else {
      appDelegate.table1 = mainStoryboard.instantiateViewControllerWithIdentifier("FriendsTableViewController") as! FriendsTableViewController
      table1 = appDelegate.table1
    }
    
    
    
    
    self.setUpFrames()
    
    self.addChildViewController(table1)
    self.addChildViewController(table2)
    self.addChildViewController(table3)
    table1.didMoveToParentViewController(self)
    table2.didMoveToParentViewController(self)
    table3.didMoveToParentViewController(self)
    contentScrollView.addSubview(table1.tableView)
    contentScrollView.addSubview(table2.tableView)
    contentScrollView.addSubview(table3.tableView)
    
    
    
    loadVisiblePages()
    contentScrollView.setContentOffset(CGPointMake(0, 0), animated: false)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FriendsViewController.inviteFriend(_:)), name: "inviteFriend", object: nil)
  }
  
  override func viewDidDisappear(animated: Bool) {
    NSNotificationCenter.defaultCenter().removeObserver(self, name: "inviteFriend", object: nil)
  }
  
  func setUpFrames() {

    
    let pagesScrollViewSize = contentScrollView.frame.size
    contentScrollView.contentSize  = CGSizeMake(self.view.frame.size.width * 3, self.view.frame.size.height - 88)
    
    var firstFrame:CGRect  = table1.tableView.frame
    firstFrame.origin.x    = 0
    firstFrame.origin.y    = 0
    firstFrame.size.width  = self.contentScrollView.frame.size.width
    firstFrame.size.height = self.contentScrollView.frame.size.height
    table1.tableView.frame = firstFrame
    
    //    privateUserSecondScreen                 = mainStoryboard.instantiateViewControllerWithIdentifier("PrivateProfileSecondScreenTableViewController") as! PrivateProfileSecondScreenTableViewController
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
