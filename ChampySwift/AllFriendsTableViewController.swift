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

class AllFriendsTableViewController: UITableViewController {
  
  var tap:Bool = true
  
  var identifiers:[String]    = []
  
  var selectedRow:Int         = -1
  var friendsContent:[UIView] = []
  var heights:[CGFloat]       = []
  
  let center = NSNotificationCenter.defaultCenter()
  
  func clearArrays() {
    //    friendsContent.removeAll()
    heights.removeAll()
  }
  
  override func viewDidDisappear(animated: Bool) {
    center.removeObserver(self, name: "allReload", object: nil)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
    center.addObserver(self, selector: #selector(PendingFriendsController.refreshTableViewAction(_:)), name: "allReload", object: nil)
    
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
  
  func fillArray() {
    self.selectedRow = -1
    self.friendsContent.removeAll()
    for friend in CHUsers().getUsers() {
      let content = FriendCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 66))
      content.status = "Other"
      content.setUp(friend)
      self.friendsContent.append(content)
      identifiers.append("\(friend["_id"].stringValue)")
    }
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return friendsContent.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    let content = friendsContent[indexPath.row] as! FriendCell
    
    if indexPath.row == self.selectedRow {
      heights.append(220.0)
      return 220
    } else {
      content.close()
      heights.append(66)
      return 66
    }
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var isIpad = false
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
      isIpad = true
    }
    let identifier = self.identifiers[indexPath.row]
    var cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)") as UITableViewCell?
    cell = nil
    autoreleasepool {
      if cell == nil {
        cell                 = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL\(identifier)")
        cell?.accessoryType  = .None
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
        let content = friendsContent[indexPath.row] as! FriendCell
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
      } else {
        let content = friendsContent[indexPath.row] as! FriendCell
        content.open()
        //      [tableView scrollToRowAtIndexPath: atScrollPosition:UITableViewScrollPositionMiddle animated:YES]\
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: true)
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

  
  @IBOutlet weak var refreshTableView: UIRefreshControl!
  
  @IBAction func refreshTableViewAction(sender: AnyObject) {
  
    CHRequests().getAllUsers { (result, json) in
      if result {
        Async.main {
          self.fillArray()
          self.tableView.reloadData()
          self.refreshTableView.endRefreshing()
        }
      }
    }
  
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
