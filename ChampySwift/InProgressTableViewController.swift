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

class InProgressTableViewController: UITableViewController {
  let center = NotificationCenter.default
  var historyItems:[UIView] = []
  var identifiers:[String] = []
  var tap:Bool = true
  var selectedRow:Int         = -1
  var heights:[CGFloat]       = []
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.refreshTableViewAction(self.refreshTableView)
    self.center.addObserver(self, selector: #selector(InProgressTableViewController.refreshTableViewAction(_:)), name: NSNotification.Name(rawValue: "refreshIcarousel"), object: nil)
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //    return 80
//    if (indexPath as NSIndexPath).row == self.selectedRow {
//      heights.append(170)
//      return 170
//    } else {
//      let content = historyItems[(indexPath as NSIndexPath).row] as! HistoryCell
//      content.close()
//      heights.append(80)
//      return 80
//    }\
    
    heights.append(80)
    return 80
    
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return historyItems.count
  }
  
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let identifier = self.identifiers[(indexPath as NSIndexPath).row]
    //    var cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)") as UITableViewCell?
    var cell = tableView.dequeueReusableCell(withIdentifier: "CELL\(identifier)") 
    
    cell = nil
    autoreleasepool {
      if cell == nil {
        cell                 = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "CELL\(identifier)")
        cell?.accessoryType  = .none
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        
        let content = historyItems[(indexPath as NSIndexPath).row] as! HistoryCell
        
        cell?.addSubview(content)
        cell!.backgroundColor = UIColor.clear
      }
    }
    return cell!
  }
  
  @IBOutlet weak var refreshTableView: UIRefreshControl!
  
  @IBAction func refreshTableViewAction(_ sender: AnyObject) {
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    return
    
  }
  
  func fillArray() {
    self.selectedRow = -1
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
  
  func disableTapForASec() {
    tap = false
    self.setTimeout(1.0) {
      self.tap = true
    }
  }
  
  func setTimeout(_ delay:TimeInterval, block:@escaping ()->Void) -> Timer {
    return Timer.scheduledTimer(timeInterval: delay, target: BlockOperation(block: block), selector: #selector(Operation.main), userInfo: nil, repeats: false)
  }
  
  
}
