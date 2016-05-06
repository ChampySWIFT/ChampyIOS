//
//  FriendsViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/26/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit

class FriendsViewController: UIViewController, FBSDKAppInviteDialogDelegate {
  let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
  
  var table1 = ExampleTableViewController()
  var table2 = ExampleTableViewController()
  var table3 = ExampleTableViewController()
  
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
    //    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    //    content.appLinkURL = [NSURL URLWithString:@"https://www.mydomain.com/myapplink"];
    //    //optionally set previewImageURL
    //    content.appInvitePreviewImageURL = [NSURL URLWithString:@"https://www.mydomain.com/my_invite_image.jpg"];
    //    
    //    // present the dialog. Assumes self implements protocol `FBSDKAppInviteDialogDelegate`
    //    [FBSDKAppInviteDialog showWithContent:content
    //    delegate:self];
    
    
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
    
    loadVisiblePages()
  }
  
  
  override func viewDidAppear(animated: Bool) {
    
    
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
    table1 = mainStoryboard.instantiateViewControllerWithIdentifier("ExampleTableViewController") as! ExampleTableViewController
    table2 = mainStoryboard.instantiateViewControllerWithIdentifier("ExampleTableViewController") as! ExampleTableViewController
    table3 = mainStoryboard.instantiateViewControllerWithIdentifier("ExampleTableViewController") as! ExampleTableViewController
    
    
    
    
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
  }
  
  
  func setUpFrames() {
    let pagesScrollViewSize = contentScrollView.frame.size
    contentScrollView.contentSize  = CGSizeMake(pagesScrollViewSize.width * 3, pagesScrollViewSize.height)
    
    var firstFrame:CGRect  = table1.tableView.frame
    firstFrame.origin.x    = 0
    firstFrame.size.width  = self.view.frame.size.width
    firstFrame.size.height = self.contentScrollView.frame.size.height
    table1.tableView.frame = firstFrame
    
    //    privateUserSecondScreen                 = mainStoryboard.instantiateViewControllerWithIdentifier("PrivateProfileSecondScreenTableViewController") as! PrivateProfileSecondScreenTableViewController
    var secondFrame:CGRect  = table2.tableView.frame
    secondFrame.origin.x    = self.view.frame.size.width
    secondFrame.size.width  = self.view.frame.size.width
    secondFrame.size.height = self.contentScrollView.frame.size.height
    table2.tableView.frame = secondFrame
    
    var thirdFrame:CGRect  = table3.tableView.frame
    thirdFrame.origin.x    = self.view.frame.size.width * 2
    thirdFrame.size.width  = self.view.frame.size.width
    thirdFrame.size.height = self.contentScrollView.frame.size.height
    table3.tableView.frame = thirdFrame
  }
  
  
  func loadPage(page: Int) {
    
    if page < 0 || page >= pageImages.count {
      // If it's outside the range of what you have to display, then do nothing
      return
    }
    
    if let pageView = pageViews[page] {
      // Do nothing. The view is already loaded.
    } else {
      var frame       = contentScrollView.bounds
      frame.origin.x  = frame.size.width * CGFloat(page)
      frame.origin.y  = 0.0
      let newPageView = UIImageView(image: pageImages[page])
      pageViews[page] = newPageView
    }
  }
  
  func purgePage(page: Int) {
    
    if page < 0 || page >= pageImages.count {
      // If it's outside the range of what you have to display, then do nothing
      return
    }
    
  }
  
  func loadVisiblePages() {
    
    // First, determine which page is currently visible
    let pageWidth = contentScrollView.frame.size.width
    let page      = Int(floor((contentScrollView.contentOffset.x * 3.0 + pageWidth) / (pageWidth * 3.0)))
    
    
    if page == 0 {
      self.title = "All friends"
      segmentControl.selectedSegmentIndex = 0
      
      return
    }
    
    if page == 1 {
      self.title = "All friends"
      segmentControl.selectedSegmentIndex = 1
      
      return
    }
    
    
    if page == 2 {
      self.title = "All friends"
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
