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
  var userCount:Int = 0
  let center = NotificationCenter.default
  var userArray:[JSON] = []
  override func viewDidDisappear(_ animated: Bool) {
    center.removeObserver(self, name: NSNotification.Name(rawValue: "allReload"), object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    center.addObserver(self, selector: #selector(AllFriendsTableViewController.refreshTableViewAction(_:)), name: NSNotification.Name(rawValue: "allReload"), object: nil)
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
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return identifiers	.count
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if friendsContent.indices.contains((indexPath as NSIndexPath).row) {
      let content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
      if content.opened {
        content.close()
        heights[(indexPath as NSIndexPath).row] = 66
        self.selectedRow = -1
      }
      
      content.removeFromSuperview()
      self.friendsContent[(indexPath as NSIndexPath).row] = FriendCell()
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
    
    
    if (indexPath as NSIndexPath).row == self.selectedRow {
      //      heights.append(220.0)
      heights[(indexPath as NSIndexPath).row] = 220.0
      return 220
    } else {
      content.close()
      heights[(indexPath as NSIndexPath).row] = 66
      //      heights.append(66)
      return 66
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let identifier = self.identifiers[(indexPath as NSIndexPath).row]
    var cell = tableView.dequeueReusableCell(withIdentifier: "CELL\(identifier)")
    cell = nil
    autoreleasepool {
      if cell == nil {
        cell                 = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CELL\(identifier)")
        cell?.accessoryType  = .none
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        cell!.contentView.backgroundColor = UIColor.clear
        
        //        let content = friendsContent[indexPath.row] as! FriendCell
        let content = FriendCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 66))
        let friend = self.userArray[indexPath.row]
        let status = CHUsers().getStatus(friend) //"Other"
        content.status = status
        
        content.setUp(json: friend)
        content.close()
        self.friendsContent[(indexPath as NSIndexPath).row] = content
        cell?.addSubview(content)
        cell!.backgroundColor = UIColor.clear
      }
    }
    return cell!
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    
    if tap {
      disableTapForASec()
      tableView.beginUpdates()
      if (indexPath as NSIndexPath).row == selectedRow {
        let content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
        content.close()
        selectedRow = -1
        self.setTimeout(0.4, block: {
          tableView.endUpdates()
          self.setTimeout(0.8, block: {
            tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
          })
        })
      } else {
        let content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
        content.open()
        self.selectedRow = (indexPath as NSIndexPath).row
        tableView.endUpdates()
        self.setTimeout(0.8, block: {
          tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        })
      }
      //      clearArrays()
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
