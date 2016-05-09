//
//  PendingFriendsController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/7/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Async
class PendingFriendsController: UITableViewController {
  
  let center = NSNotificationCenter.defaultCenter()
  
  var selectedRow:Int         = -1
  var selectedSection:Int = -1
  
  
  var heights:[CGFloat]       = []
  
  var incoming:[JSON] = []
  var incomingfriendsContent:[UIView] = []
  var outgoing:[JSON] = []
  var outgoingfriendsContent:[UIView] = []
  
  var incomingidentifiers:[String]    = []
  
  var outgoingidentifiers:[String]    = []
  
  var pendingFriends:[JSON] = []
  
  func clearArrays() {
    //    friendsContent.removeAll()
    heights.removeAll()
  }
  
  override func viewDidDisappear(animated: Bool) {
    center.removeObserver(self, name: "pendingReload", object: nil)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    center.addObserver(self, selector: #selector(PendingFriendsController.refreshTableViewAction(_:)), name: "pendingReload", object: nil)
    self.fillArray()
    //    self.tableView.backgroundView = self.view
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    if pendingFriends.count <= 0 {
      return 1
    }
    // #warning Incomplete implementation, return the number of sections
    return 2
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    if pendingFriends.count <= 0 {
      return 1
    }
    if section == 0 {
      return incomingfriendsContent.count
    } else {
      return outgoingfriendsContent.count
    }
  
  
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    if pendingFriends.count <= 0 {
      return 200
    }
    
    if indexPath.section == 0 {
      if indexPath.row == self.selectedRow && selectedSection == indexPath.section {
        heights.append(220.0)
        return 220
      } else {
        
        let content = incomingfriendsContent[indexPath.row] as! FriendCell
        content.close()
        heights.append(66)
        return 66
      }
    } else {
      
      if indexPath.row == self.selectedRow && selectedSection == indexPath.section {
        heights.append(220.0)
        return 220
      } else {
        
        let content = outgoingfriendsContent[indexPath.row] as! FriendCell
        content.close()
        heights.append(66)
        return 66
      }
    }
    
    
    
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var isIpad = false
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
      isIpad = true
    }
    var cell:UITableViewCell! = nil
    
    if pendingFriends.count <= 0 {
      cell = tableView.dequeueReusableCellWithIdentifier("CELL-nofriends") as UITableViewCell?
      let content = NoPendingRequests(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
      cell                 = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL-nofriends")
      cell?.accessoryType  = .None
      cell?.selectionStyle = UITableViewCellSelectionStyle.None
      cell?.addSubview(content)
      cell!.backgroundColor = UIColor.clearColor()
      return cell
    }
    
    if indexPath.section == 0 {
      let identifier = self.incomingidentifiers[indexPath.row]
      cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)") as UITableViewCell?
      cell = nil
      autoreleasepool {
        if cell == nil {
          cell                 = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL\(identifier)")
          cell?.accessoryType  = .None
          cell?.selectionStyle = UITableViewCellSelectionStyle.None
          
          let content = incomingfriendsContent[indexPath.row] as! FriendCell
          cell?.addSubview(content)
          cell!.backgroundColor = UIColor.clearColor()
        }
      }
      
    } else {
      let identifier = self.outgoingidentifiers[indexPath.row]
      cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)") as UITableViewCell?
      cell = nil
      autoreleasepool {
        if cell == nil {
          cell                 = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL\(identifier)")
          cell?.accessoryType  = .None
          cell?.selectionStyle = UITableViewCellSelectionStyle.None
          
          let content = outgoingfriendsContent[indexPath.row] as! FriendCell
          cell?.addSubview(content)
          cell!.backgroundColor = UIColor.clearColor()
        }
      }
    }
    
    //    cell = nil
    
    return cell!
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.beginUpdates()
    
    if indexPath.section == 0 {
      if indexPath.row == selectedRow {
        let content = incomingfriendsContent[indexPath.row] as! FriendCell
        content.close()
        selectedRow = -1
        selectedSection = -1
      } else {
        let content = incomingfriendsContent[indexPath.row] as! FriendCell
        content.open()
        selectedSection = indexPath.section
        self.selectedRow = indexPath.row
      }
    } else {
      if indexPath.row == selectedRow {
        let content = outgoingfriendsContent[indexPath.row] as! FriendCell
        content.close()
        selectedRow = -1
        selectedSection = -1
      } else {
        let content = outgoingfriendsContent[indexPath.row] as! FriendCell
        content.open()
        selectedSection = indexPath.section
        self.selectedRow = indexPath.row
      }
    }
    
    
    clearArrays()
    //    tableView.reloadData()
    tableView.endUpdates()
  }
  
  
  override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    var title:String = ""
    
    if section == 0 && self.pendingFriends.count > 0 {
      title = "Incoming"
    }
    if section == 1 && self.pendingFriends.count > 0 {
      title = "Outgoing"
    }
    
    return title
  }
  
  func fillArray() {
    self.selectedRow = -1
    self.outgoingfriendsContent.removeAll()
    self.outgoingidentifiers.removeAll()
    self.outgoing.removeAll()
    
    self.incomingidentifiers.removeAll()
    self.incoming.removeAll()
    self.incomingfriendsContent.removeAll()
    
    self.pendingFriends = CHUsers().getPendingFriend(CHSession().currentUserId)
    for friend in pendingFriends {
      if friend["friend"]["_id"].stringValue == CHSession().currentUserId {
        outgoingidentifiers.append("\(friend["owner"]["_id"].stringValue)")
        self.outgoing.append(friend)
        let content = FriendCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 66))
        content.status = "Outgoing"
        content.setUp(friend["owner"])
        self.outgoingfriendsContent.append(content)
      }
      
      if friend["owner"]["_id"].stringValue == CHSession().currentUserId {
        incomingidentifiers.append("\(friend["friend"]["_id"].stringValue)")
        self.incoming.append(friend)
        let content = FriendCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 66))
        content.status = "Incoming"
        content.setUp(friend["friend"])
        self.incomingfriendsContent.append(content)
      }
      
      
      
    }
  }
  @IBOutlet weak var refreshTableView: UIRefreshControl!
  
  @IBAction func refreshTableViewAction(sender: AnyObject) {
    
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
