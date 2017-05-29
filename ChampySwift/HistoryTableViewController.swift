//
//  HistoryTableViewController
//  ChampySwift
//
//  Created by Molnar Kristian on 6/2/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//



import UIKit
import Async
import SwiftyJSON

class HistoryTableViewController: UITableViewController {
  
  let center = NotificationCenter.default
  var historyItems:[UIView] = []
  var identifiers:[String] = []
  var tap:Bool = true
  var selectedRow:Int         = -1
  var heights:[CGFloat]       = []
  var emptyContent:InviteFriendsView! = nil
  var type:CHHistoryType! = nil
  
  enum CHHistoryType: String {
    case inProgress    = "There are no challenges in progress."
    case wins = "There are no wins."
    case failed = "There are no Failed Challenges."
    case Default = "Default"
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.fillArray()
    self.refreshTableViewAction(self.refreshTableView)
    self.center.addObserver(self, selector: #selector(HistoryTableViewController.refreshTableViewAction(_:)), name: NSNotification.Name(rawValue: "refreshIcarousel"), object: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if historyItems.count == 0 {
      return 1
    }
    return self.historyItems.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if historyItems.count == 0 {
      return self.view.frame.size.height
    }
    
    heights.append(80)
    return 80
  }
  
  
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    var cell:UITableViewCell! = nil
    
    var identifier = ""
    if historyItems.count == 0 {
      identifier = "empty"
      cell                 = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "CELL\(identifier)")
      
    } else {
      identifier = self.identifiers[(indexPath as NSIndexPath).row]
      cell = tableView.dequeueReusableCell(withIdentifier: "CELL\(identifier)")
    }
    cell = nil
    autoreleasepool {
      if cell == nil {
        cell                 = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "CELL\(identifier)")
        cell?.accessoryType  = .none
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        
        
        if historyItems.count == 0 {
          emptyContent.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
          cell?.addSubview(emptyContent)
          cell!.backgroundColor = UIColor.clear
          
        } else {
          let content = historyItems[(indexPath as NSIndexPath).row] as! HistoryCell
          
          cell?.addSubview(content)
          cell!.backgroundColor = UIColor.clear
        }
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
    
    CHRequests().retrieveFails(CHSession().currentUserId) { (result, json) in
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
    var array:[JSON] = []
    if type != nil && type == CHHistoryType.failed {
      array = CHChalenges().getWinChallenges(CHSession().currentUserId)
    }
    
    if type != nil && type == CHHistoryType.wins {
      array = CHChalenges().getWinChallenges(CHSession().currentUserId)
    }
    
    if type != nil && type == CHHistoryType.inProgress {
      array = CHChalenges().getInProgressChallenges(CHSession().currentUserId)
    }
    
    CHSettings().clearViewArray(historyItems)
    self.historyItems.removeAll()
    self.identifiers.removeAll()
    for item in array  {
      self.identifiers.append(item["_id"].stringValue)
//      let content = HistoryCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 80))
//      content.setUp(item)
//      self.historyItems.append(content)
    }
    
    if historyItems.count == 0 {
      let content = InviteFriendsView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.tableView.frame.size.height))
      content.titleLabel.text = ""
      content.descriptionLabel.text = type.rawValue
      content.backgroundColor = UIColor.clear
      self.emptyContent = content
    } else {
      if self.emptyContent != nil {
        self.emptyContent.removeFromSuperview()
      }
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
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    return
    
  }
  
  
  
  
}
