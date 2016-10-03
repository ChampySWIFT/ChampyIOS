//
//  FailedTableViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 6/2/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//



import UIKit
import Async
import SwiftyJSON

class FailedTableViewController: UITableViewController, SwipyCellDelegate {
  
  let center = NSNotificationCenter.defaultCenter()
  var historyItems:[UIView] = []
  var identifiers:[String] = []
  var tap:Bool = true
  var selectedRow:Int         = -1
  var heights:[CGFloat]       = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.refreshTableViewAction(self.refreshTableView)
    self.center.addObserver(self, selector: #selector(FailedTableViewController.refreshTableViewAction(_:)), name: "refreshIcarousel", object: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return self.historyItems.count
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    //    return 80
    if indexPath.row == self.selectedRow {
      heights.append(170)
      return 170
    } else {
      let content = historyItems[indexPath.row] as! HistoryCell
      content.close()
      heights.append(80)
      return 80
    }
    
  }
  
  func swipeableTableViewCellDidStartSwiping(cell: SwipyCell) {
    
  }
  
  // When the user ends swiping the cell this method is called
  func swipeableTableViewCellDidEndSwiping(cell: SwipyCell) {
    
  }
  
  // When the user is dragging, this method is called with the percentage from the border
  func swipeableTableViewCell(cell: SwipyCell, didSwipeWithPercentage percentage: CGFloat) {
    
  }
  
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
    let identifier = self.identifiers[indexPath.row]
    //    var cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)") as UITableViewCell?
    var cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)") as! SwipyCell?
    
    cell = nil
    autoreleasepool {
      if cell == nil {
        cell                 = SwipyCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL\(identifier)")
        cell?.accessoryType  = .None
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        
        let content = historyItems[indexPath.row] as! HistoryCell
        
        cell?.addSubview(content)
        cell!.backgroundColor = UIColor.clearColor()
      }
    }
    return cell!
  }
  
  @IBOutlet weak var refreshTableView: UIRefreshControl!
  
  @IBAction func refreshTableViewAction(sender: AnyObject) {
    guard IJReachability.isConnectedToNetwork() else {
      self.refreshTableView.endRefreshing()
      CHPush().alertPush("No Internet Connection", type: "Warning")
      Async.main {
        self.fillArray()
        self.tableView.reloadData()
        self.refreshTableView.endRefreshing()
      }
      return
    }
    
    CHRequests().retrieveAllInProgressChallenges(CHSession().currentUserId) { (result, json) in
      if result && json != nil {
        Async.main {
          self.fillArray()
          self.tableView.reloadData()
          self.refreshTableView.endRefreshing()
        }
      }
    }
    
  }
  
  func fillArray() {
    
    CHSettings().clearViewArray(historyItems)
    self.historyItems.removeAll()
    self.identifiers.removeAll()
    for item in CHChalenges().getFailedChallenges(CHSession().currentUserId)  {
      self.identifiers.append(item["_id"].stringValue)
      let content = HistoryCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80))
      content.setUp(item)
      self.historyItems.append(content)
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
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    return
    if tap {
      disableTapForASec()
      tableView.beginUpdates()
      if indexPath.row == selectedRow {
        let content = historyItems[indexPath.row] as! HistoryCell
        content.close()
        selectedRow = -1
      } else {
        let content = historyItems[indexPath.row] as! HistoryCell
        content.open()
        self.selectedRow = indexPath.row
      }
      
      tableView.endUpdates()
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
