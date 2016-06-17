//
//  InProgressTableViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 6/2/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import SwiftyJSON
import SwipyCell

class InProgressTableViewController: UITableViewController, SwipyCellDelegate {
  let center = NSNotificationCenter.defaultCenter()
  var historyItems:[UIView] = []
  var identifiers:[String] = []
  override func viewDidLoad() {
    super.viewDidLoad()
    self.refreshTableViewAction(self.refreshTableView)
    self.center.addObserver(self, selector: #selector(InProgressTableViewController.refreshTableViewAction(_:)), name: "refreshIcarousel", object: nil)
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 80
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return historyItems.count
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
    for item in CHChalenges().getInProgressChallenges(CHSession().currentUserId)  {
      self.identifiers.append(item["_id"].stringValue)
      let content = HistoryCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80))
      content.setUp(item)
      
      self.historyItems.append(content)
    }
  }
  
  
  
  
  
}
