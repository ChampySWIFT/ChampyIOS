//
//  ExampleTableViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/5/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Async
import SwipyCell

class AllFriendsTableViewController: UITableViewController {
  
  var tap:Bool = true
  var identifiers:[String]    = []
  var selectedRow:Int         = -1
  var friendsContent:[UIView] = []
  var heights:[CGFloat]       = []
  var userCount:Int = 0
  let center = NSNotificationCenter.defaultCenter()
  var userArray:[JSON] = []
  override func viewDidDisappear(animated: Bool) {
    center.removeObserver(self, name: "allReload", object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    center.addObserver(self, selector: #selector(AllFriendsTableViewController.refreshTableViewAction(_:)), name: "allReload", object: nil)
    self.refreshTableViewAction(self.refreshTableView)
   
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return identifiers	.count
  }
  
  override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
    if friendsContent.indices.contains(indexPath.row) {
      let content = friendsContent[indexPath.row] as! FriendCell
      if content.opened {
        content.close()
        heights[indexPath.row] = 66
        self.selectedRow = -1
      }
      
      content.removeFromSuperview()
      self.friendsContent[indexPath.row] = FriendCell()
    }
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let content = friendsContent[indexPath.row] as! FriendCell
    
    
    if indexPath.row == self.selectedRow {
      //      heights.append(220.0)
      heights[indexPath.row] = 220.0
      return 220
    } else {
      content.close()
      heights[indexPath.row] = 66
      //      heights.append(66)
      return 66
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let identifier = self.identifiers[indexPath.row]
    var cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)")
    cell = nil
    autoreleasepool {
      if cell == nil {
        cell                 = SwipyCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL\(identifier)")
        cell?.accessoryType  = .None
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        cell!.contentView.backgroundColor = UIColor.clearColor()
        
        //        let content = friendsContent[indexPath.row] as! FriendCell
        let content = FriendCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 66))
        let friend = self.userArray[indexPath.row]
        let status = CHUsers().getStatus(friend) //"Other"
        content.status = status
        
        content.setUp(friend)
        content.close()
        self.friendsContent[indexPath.row] = content
        cell?.addSubview(content)
        cell!.backgroundColor = UIColor.clearColor()
      }
    }
    return cell!
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
    
    if tap {
      disableTapForASec()
      tableView.beginUpdates()
      if indexPath.row == selectedRow {
        let content = friendsContent[indexPath.row] as! FriendCell
        content.close()
        selectedRow = -1
        self.setTimeout(0.4, block: {
          tableView.endUpdates()
          self.setTimeout(0.8, block: {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
          })
        })
      } else {
        let content = friendsContent[indexPath.row] as! FriendCell
        content.open()
        self.selectedRow = indexPath.row
        tableView.endUpdates()
        self.setTimeout(0.8, block: {
          tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
        })
      }
      //      clearArrays()
    }
  }
  
  @IBOutlet weak var refreshTableView: UIRefreshControl!
  
  @IBAction func refreshTableViewAction(sender: AnyObject) {
    guard IJReachability.isConnectedToNetwork() else {
      self.refreshTableView.endRefreshing()
      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    }
    CHPush().alertPush("Updating Friends List", type: "Success")
    Async.background{
      CHRequests().getAllUsers { (result, json) in
        CHRequests().getFriends(CHSession().currentUserId, completitionHandler: { (result, json) in
          if result {
            Async.main {
              
              self.fillArray()
              self.tableView.reloadData()
              self.refreshTableView.endRefreshing()
            }
          }
        })
        
      }
    }
    
    
  }
  
  func viewWithImageName(imageName: String) -> UIView {
    let image = UIImage(named: imageName)
    let imageView = UIImageView(image: image)
    imageView.contentMode = .Center
    return imageView
  }
  
  func viewWithLabel(text: String) -> UIView {
    let label = UILabel(frame: CGRect(x:0, y: 0, width: self.view.frame.width / 2, height: 66))
    label.text = text
    label.font = CHUIElements().font16
    label.numberOfLines = 3
    label.lineBreakMode = .ByWordWrapping
    label.textColor = CHUIElements().APPColors["Info"]
    return label
  }
  
  func disableTapForASec() {
    tap = false
    self.setTimeout(1.0) {
      self.tap = true
    }
  }
  
  func setTimeout(delay:NSTimeInterval, block:()->Void) -> NSTimer {
    return NSTimer.scheduledTimerWithTimeInterval(delay, target: NSBlockOperation(block: block), selector: "main", userInfo: nil, repeats: false)
  }
  
  func destroyAll() {
    for item in self.friendsContent {
      item.removeFromSuperview()
    }
    self.friendsContent.removeAll()
  }
  
  func fillArray() {
    self.selectedRow = -1
    self.destroyAll()
    self.friendsContent.removeAll()
    self.identifiers.removeAll()
    heights.removeAll()
    self.userArray.removeAll()
    var i = 0;
    for friend in CHUsers().getUsers()  {
      
      let status = CHUsers().getStatus(friend)
      
      if CHUsers().getStatus(friend) == "Other" {
        heights.append(66)
        self.friendsContent.append(FriendCell())
        identifiers.append("\(friend["_id"].stringValue)")
        self.userArray.append(friend)
        
        
        // fantom friends
//        heights.append(66)
//        self.friendsContent.append(FriendCell())
//        identifiers.append("\(friend["_id"].stringValue) asd\(i)")
//        self.userArray.append(friend)
//        
//        heights.append(66)
//        self.friendsContent.append(FriendCell())
//        identifiers.append("\(friend["_id"].stringValue) adasd\(i)")
//        self.userArray.append(friend)
//        
//        heights.append(66)
//        self.friendsContent.append(FriendCell())
//        identifiers.append("\(friend["_id"].stringValue) asdasd\(i)")
//        self.userArray.append(friend)
//        
//        // fantom friends
//        heights.append(66)
//        self.friendsContent.append(FriendCell())
//        identifiers.append("\(friend["_id"].stringValue) asd\(i)")
//        self.userArray.append(friend)
//        
//        heights.append(66)
//        self.friendsContent.append(FriendCell())
//        identifiers.append("\(friend["_id"].stringValue) adasd\(i)")
//        self.userArray.append(friend)
//        
//        heights.append(66)
//        self.friendsContent.append(FriendCell())
//        identifiers.append("\(friend["_id"].stringValue) asdasd\(i)")
//        self.userArray.append(friend)
//        
        
        i = i + 1
      } else {
        
      }
    }
    
    
    
    //    ////print(userArray)
    self.userCount = self.friendsContent.count
  }
  
  
  
}
