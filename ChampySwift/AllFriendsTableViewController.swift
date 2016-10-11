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

class AllFriendsTableViewController: UITableViewController, MNMBottomPullToRefreshManagerClient {
  let appDelegate     = UIApplication.shared.delegate as! AppDelegate
  
  func bottomPull(toRefreshTriggered manager: MNMBottomPullToRefreshManager) {
    print("refreshed")
  }
  
  var pulltorefreshManager:MNMBottomPullToRefreshManager!
  var tap:Bool = true
  var identifiers:[String]    = []
  var selectedRow:Int         = -1
  var friendsContent:[UIView] = []
  var heights:[CGFloat]       = []
  var userCount:Int = 0
  let center = NotificationCenter.default
  var userArray:[JSON] = []
  
  var displayiedCells:Int = 0
  override func viewDidDisappear(_ animated: Bool) {
    center.removeObserver(self, name: NSNotification.Name(rawValue: "allReload"), object: nil)
  }
  
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if (scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height) { loadMoreFriends() }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    center.addObserver(self, selector: #selector(AllFriendsTableViewController.refreshTableViewAction(_:)), name: NSNotification.Name(rawValue: "allReload"), object: nil)
    self.refreshTableViewAction(self.refreshTableView)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableView.delegate = self
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   return identifiers	.count
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if friendsContent.indices.contains((indexPath as NSIndexPath).row) {
      weak var content = (friendsContent[(indexPath as NSIndexPath).row] as! FriendCell)
      if (content?.opened)! {
        content?.close()
        heights[(indexPath as NSIndexPath).row] = 66
        self.selectedRow = -1
      }
      if content?.userAvatar != nil {
      content?.userAvatar.removeFromSuperview()
      }
      content?.userAvatar = nil
      content?.removeFromSuperview()
      content = nil
      self.friendsContent[(indexPath as NSIndexPath).row] = appDelegate.prototypeFriendCell
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    weak var content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
    
    if (indexPath as NSIndexPath).row == self.selectedRow {
      heights[(indexPath as NSIndexPath).row] = 220.0
      return 220
    } else {
      content?.close()
      heights[(indexPath as NSIndexPath).row] = 66
      return 66
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let identifier = self.identifiers[(indexPath as NSIndexPath).row]
    var cell = tableView.dequeueReusableCell(withIdentifier: "CELL\(identifier)")
    cell = nil
    if cell == nil {
      cell                 = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CELL\(identifier)")
      cell?.accessoryType  = .none
      cell?.selectionStyle = UITableViewCellSelectionStyle.none
      cell!.contentView.backgroundColor = UIColor.clear
      
      //        let content = friendsContent[indexPath.row] as! FriendCell
      autoreleasepool {
        var content = FriendCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 66))
        let friend = self.userArray[indexPath.row]
        let status = CHUsers().getStatus(friend) //"Other"
        content.status = status
        
        content.setUp(friend)
        content.close()
        self.friendsContent[(indexPath as NSIndexPath).row] = content
        
        cell?.addSubview(content)
      }
      
      
      
      
      cell!.backgroundColor = UIColor.clear
      displayiedCells += 1
    }
    
    
    
    
    
    return cell!
  }
  
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if tap {
      disableTapForASec()
      tableView.beginUpdates()
      if (indexPath as NSIndexPath).row == selectedRow {
        weak var content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
        content?.close()
        selectedRow = -1
        self.setTimeout(0.4, block: {
          tableView.endUpdates()
          self.setTimeout(0.8, block: {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
          })
        })
      } else {
        weak var content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
        content?.open()
        self.selectedRow = (indexPath as NSIndexPath).row
        tableView.endUpdates()
        self.setTimeout(0.8, block: {
          tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        })
      }
    }
  }
  
  @IBOutlet weak var refreshTableView: UIRefreshControl!
  
  @IBAction func refreshTableViewAction(_ sender: AnyObject) {
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
  
  func viewWithImageName(_ imageName: String) -> UIView {
    let image = UIImage(named: imageName)
    let imageView = UIImageView(image: image)
    imageView.contentMode = .center
    return imageView
  }
  
  func viewWithLabel(_ text: String) -> UIView {
    let label = UILabel(frame: CGRect(x:0, y: 0, width: self.view.frame.width / 2, height: 66))
    label.text = text
    label.font = CHUIElements().font16
    label.numberOfLines = 3
    label.lineBreakMode = .byWordWrapping
    label.textColor = CHUIElements().APPColors["Info"]
    return label
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
  
  func destroyAll() {
    for item in self.friendsContent {
      item.removeFromSuperview()
    }
    self.friendsContent.removeAll()
  }
  
  func fillArray() {
    displayiedCells = 0
    self.selectedRow = -1
    self.destroyAll()
    self.friendsContent.removeAll()
    self.identifiers.removeAll()
    heights.removeAll()
    self.userArray.removeAll()
    var toValue = 20
    
    if CHUsers().getUsersCount() < toValue {
      toValue = CHUsers().getUsersCount() - 1
    }
    
//    for friend in CHUsers().getUsers()  {
    for friend in CHUsers().getUsers(from: 0, to: toValue)  {
      let status = CHUsers().getStatus(friend)
      if status == "Other" {
        heights.append(66)
        self.friendsContent.append(appDelegate.prototypeFriendCell)
        identifiers.append("\(friend["_id"].stringValue)")
        self.userArray.append(friend)
      }
    }
    self.userCount = self.friendsContent.count
  }
  
  
  
  
  
  
  
  
  func appendArray(fromValue:Int, toValue:Int) {
    CHPush().alertPush("Loading more friends", type: "Info")
    for friend in CHUsers().getUsers(from: fromValue, to: toValue)  {
      let status = CHUsers().getStatus(friend)
      if status == "Other" {
        if !identifiers.contains("\(friend["_id"].stringValue)") {
          heights.append(66)
          self.friendsContent.append(appDelegate.prototypeFriendCell)
          identifiers.append("\(friend["_id"].stringValue)")
          self.userArray.append(friend)
        }
        
      }
    }
    
    self.userCount = self.friendsContent.count
    self.tableView.reloadData()
  }
  
  func loadMoreFriends() {
    var toValue = 50
    
    if self.userCount == CHUsers().getUsersCount() {
      return
    }
    
    if self.userCount + toValue >= CHUsers().getUsersCount() {
      toValue = CHUsers().getUsersCount() - self.userCount
    }
    
    self.appendArray(fromValue: self.userCount - 1, toValue: self.userCount + toValue - 1)
  }
  
  
  
}

