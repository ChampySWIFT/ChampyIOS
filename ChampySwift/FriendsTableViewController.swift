//
//      } FriendsTableViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/7/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//
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


class FriendsTableViewController: UITableViewController, SwipyCellDelegate {
  
  var identifiers:[String]    = []
  var tap:Bool = true
  var selectedRow:Int         = -1
  var friendsContent:[UIView] = []
  var heights:[CGFloat]       = []
  let center = NSNotificationCenter.defaultCenter()
  var inviteFriendsContent:InviteFriendsView! = nil
  var userCount:Int = 0
  
  
  func clearArrays() {
    //    friendsContent.removeAll()
    heights.removeAll()
  }
  
  override func viewDidDisappear(animated: Bool) {
    center.removeObserver(self, name: "friendsReload", object: nil)
    center.removeObserver(self, name: "openDuelView", object: nil)
    
  }
  
  override func viewDidAppear(animated: Bool) {
    center.addObserver(self, selector: #selector(FriendsTableViewController.refreshTableViewAction(_:)), name: "friendsReload", object: nil)
    center.addObserver(self, selector: #selector(FriendsTableViewController.openDuelView), name: "openDuelView", object: nil)
    
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.fillArray()
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
    
    if friendsContent.count == 0 {
      return 1
    }
    return friendsContent.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if friendsContent.count == 0 {
      return self.view.frame.size.height
    }
    
    if indexPath.row == self.selectedRow {
      heights.append(220.0)
      return 220
    } else {
      let content = friendsContent[indexPath.row] as! FriendCell
      content.close()
      heights.append(66)
      return 66
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var identifier = "first"
    
    if friendsContent.count > 0 {
      identifier = self.identifiers[indexPath.row]
    }
//    var cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)") as UITableViewCell?
    var cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)") as! SwipyCell?
    
        cell = nil
    autoreleasepool {
      if cell == nil {
        cell                 = SwipyCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL\(identifier)")
        cell?.accessoryType  = .None
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
        
        if friendsContent.count == 0 {
          inviteFriendsContent.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
          cell?.addSubview(inviteFriendsContent)
          cell!.backgroundColor = UIColor.clearColor()
        } else {
          let content = friendsContent[indexPath.row] as! FriendCell
          cell?.addSubview(content)
          cell!.backgroundColor = UIColor.clearColor()
        }
      }
    }
    return cell!
  }
  
  func openDuelView() {
     self.navigationController?.performSegueWithIdentifier("showDuelViewController", sender: self)
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if self.friendsContent.count == 0 {
      return
    }
    if tap {
      disableTapForASec()
      tableView.beginUpdates()
      if indexPath.row == selectedRow {
        let content = friendsContent[indexPath.row] as! FriendCell
        content.close()
        selectedRow = -1
      } else {
        let content = friendsContent[indexPath.row] as! FriendCell
        content.open()
        self.selectedRow = indexPath.row
      }
      clearArrays()
      //    tableView.reloadData()
      tableView.endUpdates()
    }
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
    for friend in CHUsers().getFriends(CHSession().currentUserId) {
      let content = FriendCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 66))
      
      content.status = "Friends"
      var object = friend["owner"]
      if friend["owner"]["_id"].stringValue == CHSession().currentUserId {
        object = friend["friend"]
      }
      
      content.setUp(object)
      self.friendsContent.append(content)
      identifiers.append("\(friend["_id"].stringValue)")
    }
    
    
    if friendsContent.count == 0 {
      let content = InviteFriendsView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.tableView.frame.size.height))
      content.backgroundColor = UIColor.clearColor()
      self.inviteFriendsContent = content
    } else {
      if self.inviteFriendsContent != nil {
        self.inviteFriendsContent.removeFromSuperview()
      }
    }
    
    self.userCount = self.friendsContent.count
    
  }
  
  @IBOutlet weak var refreshTableView: UIRefreshControl!
  
  @IBAction func refreshTableViewAction(sender: AnyObject) {
    guard IJReachability.isConnectedToNetwork() else {
      self.refreshTableView.endRefreshing()
      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    }
    CHRequests().getFriends(CHSession().currentUserId, completitionHandler: { (result, json) in
      if result {
        Async.main {
          if CHUsers().getFriends(CHSession().currentUserId).count == self.userCount {
            self.refreshTableView.endRefreshing()
            return
          }
          self.fillArray()
          self.tableView.reloadData()
          self.refreshTableView.endRefreshing()
        }
      }
    })
    
    
    
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
  
  func swipeableTableViewCellDidStartSwiping(cell: SwipyCell) {
    
  }
  
  // When the user ends swiping the cell this method is called
  func swipeableTableViewCellDidEndSwiping(cell: SwipyCell) {
    
  }
  
  // When the user is dragging, this method is called with the percentage from the border
  func swipeableTableViewCell(cell: SwipyCell, didSwipeWithPercentage percentage: CGFloat) {
    
  }
  
  
  /*
   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
   let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
   
   // Configure the cell...
   
   return cell
   }
   */
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
   if editingStyle == .Delete {
   // Delete the row from the data source
   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
   } else if editingStyle == .Insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}


