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
  
  @IBOutlet weak var refreshTableView: UIRefreshControl!
  
  let center = NotificationCenter.default
  var selectedRow:Int         = -1
  var selectedSection:Int = -1
  var tap:Bool = true
  var heights:[CGFloat]       = []
  var incoming:[JSON] = []
  var incomingfriendsContent:[UIView] = []
  var outgoing:[JSON] = []
  var outgoingfriendsContent:[UIView] = []
  var incomingidentifiers:[String]    = []
  var outgoingidentifiers:[String]    = []
  var pendingFriends:[JSON] = []
  let closedHeight:CGFloat = 66.0
  let openedHeight:CGFloat = 220.0
  
  
  override func viewDidDisappear(_ animated: Bool) {
    center.removeObserver(self, name: NSNotification.Name(rawValue: "pendingReload"), object: nil)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    center.addObserver(self, selector: #selector(PendingFriendsController.refreshTableViewAction(_:)), name: NSNotification.Name(rawValue: "pendingReload"), object: nil)
    self.fillArray()
    self.refreshTableViewAction(self.refreshTableView)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.fillArray()
    self.refreshTableViewAction(self.refreshTableView)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    
    if pendingFriends.count <= 0 {
      return 1
    }
    
    return 2
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    guard pendingFriends.count != 0 else {
      return 1
    }
    
    switch section {
    case 0:
      guard incomingfriendsContent.count != 0 else {
        return 1
      }
      return incomingfriendsContent.count
    case 1:
      guard outgoingfriendsContent.count != 0 else {
        return 1
      }
      return outgoingfriendsContent.count
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard pendingFriends.count != 0 else {
      return openedHeight
    }
    
    switch (indexPath as NSIndexPath).section {
    case 0:
      return getHeightByIndexPath(indexPath, andArray: self.incomingfriendsContent)
      
    case 1:
      return getHeightByIndexPath(indexPath, andArray: self.outgoingfriendsContent)
      
    default:
      return closedHeight
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard pendingFriends.count != 0 else {
      return self.getEmptyCell()
    }
    
    
    switch (indexPath as NSIndexPath).section {
    case 0:
      guard incomingfriendsContent.count != 0 else {
        return getEmptySubCell()
      }
      return self.setUpCellWithIdentifier(self.incomingidentifiers[(indexPath as NSIndexPath).row], andContent: incomingfriendsContent[(indexPath as NSIndexPath).row] as! FriendCell, index: (indexPath as NSIndexPath).row, type: "Incoming", friendsNumber: incomingfriendsContent.count)
    case 1:
      guard outgoingfriendsContent.count != 0 else {
        return getEmptySubCell()
      }
      return self.setUpCellWithIdentifier(self.outgoingidentifiers[(indexPath as NSIndexPath).row], andContent: self.outgoingfriendsContent[(indexPath as NSIndexPath).row], index: (indexPath as NSIndexPath).row, type: "Outgoing", friendsNumber: outgoingfriendsContent.count)
    default:
      return getEmptySubCell()
    }
    
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard tap else {
      return
    }
    
    self.tableView.beginUpdates()
    
    switch (indexPath as NSIndexPath).section {
    case 0:
      guard incomingfriendsContent.count > 0 else {
        return
      }
      self.triggerContent(incomingfriendsContent[(indexPath as NSIndexPath).row] as! FriendCell, andIndexPath: indexPath)
      break
      
    case 1:
      guard outgoingfriendsContent.count > 0 else {
        return
      }
      self.triggerContent(outgoingfriendsContent[(indexPath as NSIndexPath).row] as! FriendCell, andIndexPath: indexPath)
      break
    default: break
      
    }
    
    self.disableTapForASec()
    heights.removeAll()
    self.tableView.endUpdates()
  }
  
  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
    let content = HeaderViewForPendingFriendsCells(frame: CGRect(x: 0, y:0, width: self.view.frame.size.width, height: 30))
    
    switch section {
    case 0:
      return modfiedTableHeader(content, text: "Incoming")
      
    case 1:
      return modfiedTableHeader(content, text: "Outgoing")
      
    default:
      break
    }
    return content
  }
  
  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    switch section {
    case 0:
      if self.incomingfriendsContent.count == 0 && self.outgoingfriendsContent.count == 0 {
        return 0
      } else {
        return 30
      }
      
    case 1:
      if self.incomingfriendsContent.count == 0 && self.outgoingfriendsContent.count == 0 {
        return 0
      } else {
        return 30
      }
      
    default:
      return 30
    }
    
  }
  
  func triggerContent(_ content: FriendCell, andIndexPath indexPath:IndexPath) {
    if (indexPath as NSIndexPath).row == selectedRow  {
      content.close()
      selectedRow = -1
      selectedSection = -1
    } else {
      content.open()
      selectedSection = (indexPath as NSIndexPath).section
      self.selectedRow = (indexPath as NSIndexPath).row
    }
  }
  
  func modfiedTableHeader(_ content:HeaderViewForPendingFriendsCells, text:String) -> UIView {
    guard self.pendingFriends.count == 0 else {
      content.setUp(text)
      content.isHidden = false
      return content
    }
    
    return content
  }
  
  func disableTapForASec() {
    tap = false
    CHBanners().setTimeout(1.0) {
      self.tap = true
    }
  }
  
  func destroyAll() {
    for item in self.outgoingfriendsContent {
      item.removeFromSuperview()
    }
    
    for item in self.incomingfriendsContent {
      item.removeFromSuperview()
    }
    
    self.incomingfriendsContent.removeAll()
    self.outgoingfriendsContent.removeAll()
  }
  
  func fillArray() {
    self.selectedRow = -1
    self.destroyAll()
    
    self.outgoingfriendsContent.removeAll()
    self.outgoingidentifiers.removeAll()
    self.outgoing.removeAll()
    
    self.incomingfriendsContent.removeAll()
    self.incomingidentifiers.removeAll()
    self.incoming.removeAll()
    
    self.pendingFriends = CHUsers().getPendingFriend(CHSession().currentUserId)
    
    for friend in pendingFriends {
      let content = FriendCell(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 66))
      
      switch CHSession().currentUserId {
      case friend["friend"]["_id"].stringValue:
        outgoingidentifiers.append("\(friend["owner"]["_id"].stringValue)")
        self.outgoing.append(friend)
        content.status = "Outgoing"
        content.setUp(friend["owner"])
        self.outgoingfriendsContent.append(content)
        break
        
      case friend["owner"]["_id"].stringValue:
        incomingidentifiers.append("\(friend["friend"]["_id"].stringValue)")
        self.incoming.append(friend)
        content.status = "Incoming"
        content.setUp(friend["friend"])
        self.incomingfriendsContent.append(content)
        break
      default:
        continue
      }
    }
  }
  
  func getEmpty(_ text:String) ->UIView {
    let container = UIView(frame: CGRect(x: 0, y:0, width: self.view.frame.size.width, height: 66))
    let innercontainer = UIView(frame: CGRect(x: 0, y:0, width: self.view.frame.size.width, height: 66))
    let label = UILabel(frame: CGRect(x: 0, y:0, width: self.view.frame.size.width, height: 66))
    
    container.backgroundColor = UIColor.clear
    innercontainer.backgroundColor = UIColor.clear
    label.backgroundColor = UIColor.clear
    
    label.text = text
    label.textColor = CHUIElements().APPColors["Info"]
    label.font = CHUIElements().font16
    label.textAlignment = .center
    
    container.addSubview(innercontainer)
    container.addSubview(label)
    
    return container
  }
  
  func setUpCellForUsage(_ cell:UITableViewCell) {
    cell.accessoryType  = .none
    cell.selectionStyle = UITableViewCellSelectionStyle.none
    cell.backgroundColor = UIColor.clear
  }
  
  func getEmptyCell() -> UITableViewCell {
    let cell:UITableViewCell! = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CELL-nofriends")
    self.setUpCellForUsage(cell)
    cell.addSubview(NoPendingRequests(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200)))
    return cell
  }
  
  func getEmptySubCell() -> UITableViewCell {
    let cell:UITableViewCell! = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CELL-empty")
    self.setUpCellForUsage(cell)
    cell.addSubview(self.getEmpty("There are no Requests"))
    return cell
  }
  
  func getHeightByIndexPath(_ indexPath: IndexPath, andArray array:[UIView]) -> CGFloat {
    if (indexPath as NSIndexPath).row == self.selectedRow && selectedSection == (indexPath as NSIndexPath).section {
      heights.append(openedHeight)
      return openedHeight
    }
    
    if array.count > 0 {
      let content = array[(indexPath as NSIndexPath).row] as! FriendCell
      content.close()
      heights.append(closedHeight)
      return closedHeight
    } else {
      return closedHeight
    }
  }
  
  func setUpCellWithIdentifier(_ identifier:String, andContent:UIView?, index:Int, type:String, friendsNumber:Int) -> UITableViewCell {
    let cell:UITableViewCell! = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "CELL\(identifier)")
    self.setUpCellForUsage(cell)
    
    cell?.addSubview(andContent!)
    return cell
  }
  
  @IBAction func refreshTableViewAction(_ sender: AnyObject) {
    guard IJReachability.isConnectedToNetwork() else {
      self.refreshTableView.endRefreshing()
      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    }
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
