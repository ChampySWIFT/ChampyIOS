//
//   FriendsTableViewController.swift
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


class FriendsTableViewController: UITableViewController {
  
  var identifiers:[String]    = []
  var tap:Bool = true
  var selectedRow:Int         = -1
  var friendsContent:[UIView] = []
  var heights:[CGFloat]       = []
  let center = NotificationCenter.default
  var inviteFriendsContent:InviteFriendsView! = nil
  var userCount:Int = 0
  
  
  override func viewDidDisappear(_ animated: Bool) {
    center.removeObserver(self, name: NSNotification.Name(rawValue: "friendsReload"), object: nil)
    center.removeObserver(self, name: NSNotification.Name(rawValue: "openDuelView"), object: nil)
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    center.addObserver(self, selector: #selector(FriendsTableViewController.refreshTableViewAction(_:)), name: NSNotification.Name(rawValue: "friendsReload"), object: nil)
    center.addObserver(self, selector: #selector(FriendsTableViewController.openDuelView), name: NSNotification.Name(rawValue: "openDuelView"), object: nil)
    self.refreshTableViewAction(self.refreshTableView)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.fillArray()
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
    // #warning Incomplete implementation, return the number of rows
    
    if friendsContent.count == 0 {
      return 1
    }
    return friendsContent.count
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if friendsContent.count == 0 {
      return self.view.frame.size.height
    }
    
    if (indexPath as NSIndexPath).row == self.selectedRow {
      heights.append(220.0)
      return 220
    } else {
      let content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
      content.close()
      heights.append(66)
      return 66
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var identifier = "first"
    
    if friendsContent.count > 0 {
      identifier = self.identifiers[(indexPath as NSIndexPath).row]
    }
    
    var cell = tableView.dequeueReusableCell(withIdentifier: "CELL\(identifier)")
    
    cell = nil
    autoreleasepool {
      if cell == nil {
        cell                 = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "CELL\(identifier)")
        cell?.accessoryType  = .none
        cell?.selectionStyle = UITableViewCellSelectionStyle.none
        
        
        if friendsContent.count == 0 {
          inviteFriendsContent.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
          cell?.addSubview(inviteFriendsContent)
          cell!.backgroundColor = UIColor.clear
        } else {
          //          let content = FriendCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 66))
          //          let friend = CHUsers().getFriends(CHSession().currentUserId)[indexPath.row]
          //          var object = friend["owner"]
          //          if friend["owner"]["_id"].stringValue == CHSession().currentUserId {
          //            object = friend["friend"]
          //          }
          //          content.setUp(object)
          //          //////print(indexPath.row)
          let content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
          cell?.addSubview(content)
          cell!.backgroundColor = UIColor.clear
        }
      }
    }
    return cell!
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.friendsContent.count == 0 {
      return
    }
    if tap {
      disableTapForASec()
      tableView.beginUpdates()
      if (indexPath as NSIndexPath).row == selectedRow {
        let content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
        content.close()
        selectedRow = -1
      } else {
        let content = friendsContent[(indexPath as NSIndexPath).row] as! FriendCell
        content.open()
        self.selectedRow = (indexPath as NSIndexPath).row
      }
      clearArrays()
      //    tableView.reloadData()
      tableView.endUpdates()
    }
  }
  
  func openDuelView() {
    self.navigationController?.performSegue(withIdentifier: "showDuelViewController", sender: self)
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
    for friend in CHUsers().getFriends(CHSession().currentUserId) {
      let content = FriendCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 66))
      
      content.status = "Friends"
      var object = friend["owner"]
      if friend["owner"]["_id"].stringValue == CHSession().currentUserId {
        object = friend["friend"]
      }
      
      content.setUp(object)
      content.setUpImage()
      self.friendsContent.append(content)
      identifiers.append("\(friend["_id"].stringValue)")
    }
    
    
    if friendsContent.count == 0 {
      let content = InviteFriendsView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.tableView.frame.size.height))
      content.backgroundColor = UIColor.clear
      self.inviteFriendsContent = content
    } else {
      if self.inviteFriendsContent != nil {
        self.inviteFriendsContent.removeFromSuperview()
      }
    }
    
    self.userCount = self.friendsContent.count
    
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
  
  func clearArrays() {
    //    friendsContent.removeAll()
    heights.removeAll()
  }
  
  @IBOutlet weak var refreshTableView: UIRefreshControl!
  
  @IBAction func refreshTableViewAction(_ sender: AnyObject) {
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
  
  
  
  
}


