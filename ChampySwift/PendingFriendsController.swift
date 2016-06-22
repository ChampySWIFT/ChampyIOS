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
import SwipyCell
class PendingFriendsController: UITableViewController, SwipyCellDelegate {
  
  let center = NSNotificationCenter.defaultCenter()
  
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
  
  func clearArrays() {
    //    friendsContent.removeAll()
    heights.removeAll()
  }
  
  override func viewDidDisappear(animated: Bool) {
    center.removeObserver(self, name: "pendingReload", object: nil)
  }
  
  override func viewDidAppear(animated: Bool) {
    center.addObserver(self, selector: #selector(PendingFriendsController.refreshTableViewAction(_:)), name: "pendingReload", object: nil)
    
  }
  override func viewDidLoad() {
    super.viewDidLoad()
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
      if incomingfriendsContent.count == 0 {
        return 1
      } else {
        return incomingfriendsContent.count
      }
    } else {
      if outgoingfriendsContent.count == 0 {
        return 1
      } else {
        return outgoingfriendsContent.count
      }
      
    }
  
    return 0
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
        if incomingfriendsContent.count > 0 {
          let content = incomingfriendsContent[indexPath.row] as! FriendCell
          content.close()
          heights.append(66)
          return 66
        } else {
          return 66
        }
        
      }
    } else {
      
      if indexPath.row == self.selectedRow && selectedSection == indexPath.section {
        heights.append(220.0)
        return 220
      } else {
        if outgoingfriendsContent.count > 0 {
          let content = outgoingfriendsContent[indexPath.row] as! FriendCell
          content.close()
          heights.append(66)
          return 66
        } else {
          return 66
        }
        
        return 66
      }
    }
    
    
    
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var isIpad = false
    if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad {
      isIpad = true
    }
    var cell:SwipyCell! = nil
    
    if pendingFriends.count <= 0 {
      
      cell = tableView.dequeueReusableCellWithIdentifier("CELL-nofriends") as! SwipyCell?
      let content = NoPendingRequests(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200))
//      cell                 = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL-nofriends")
      cell                 = SwipyCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL-nofriends")
      cell.accessoryType  = .None
      cell.selectionStyle = UITableViewCellSelectionStyle.None
      cell.addSubview(content)
      cell.backgroundColor = UIColor.clearColor()
      return cell
    }
    
    if indexPath.section == 0 {
      var identifier = ""
      if incomingfriendsContent.count == 0 {
        identifier = "emptyinc"
      } else {
        identifier = self.incomingidentifiers[indexPath.row]
      }
      cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)") as! SwipyCell?
      cell = nil
      autoreleasepool {
        if cell == nil {
//          cell                 = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL\(identifier)")
          cell                 = SwipyCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL\(identifier)")
          cell?.accessoryType  = .None
          cell?.selectionStyle = UITableViewCellSelectionStyle.None
          
          if incomingfriendsContent.count == 0 {
            cell.addSubview(getEmpty("No Incoming Requests"))
            cell!.backgroundColor = UIColor.clearColor()
          } else {
            
            let content = incomingfriendsContent[indexPath.row] as! FriendCell
            
            cell?.addSubview(content)
            cell!.backgroundColor = UIColor.clearColor()
          }
          
          
        }
      }
      
    } else {
      var identifier = ""
      if outgoingfriendsContent.count == 0 {
        identifier = "emptyout"
      } else {
        identifier = self.outgoingidentifiers[indexPath.row]
      }
      cell = tableView.dequeueReusableCellWithIdentifier("CELL\(identifier)") as! SwipyCell?
      cell = nil
      autoreleasepool {
        if cell == nil {
//          cell                 = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "CELL\(identifier)")
          cell                 = SwipyCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "CELL\(identifier)")
          cell?.accessoryType  = .None
          cell?.selectionStyle = UITableViewCellSelectionStyle.None
          cell!.contentView.backgroundColor = UIColor.clearColor()
          
          if outgoingfriendsContent.count == 0 {
            cell.addSubview(getEmpty("No Incoming Requests"))
            cell!.backgroundColor = UIColor.clearColor()
          } else {
            
            let content = outgoingfriendsContent[indexPath.row] as! FriendCell
            
            cell?.addSubview(content)
            cell!.backgroundColor = UIColor.clearColor()
          }
          
          
        }
      }
    }
    
    //    cell = nil
    
    return cell!
  }
  
  
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.beginUpdates()
    
    if tap {
      if indexPath.section == 0 {
        if incomingfriendsContent.count > 0 {
          if indexPath.row == selectedRow  {
            let content = incomingfriendsContent[indexPath.row] as! FriendCell
            content.close()
//            tableView.scrollEnabled = true
            selectedRow = -1
            selectedSection = -1
          } else {
            let content = incomingfriendsContent[indexPath.row] as! FriendCell
            content.open()
            self.setTimeout(1.0, block: {
//              tableView.scrollEnabled = false
            })
            
            selectedSection = indexPath.section
            self.selectedRow = indexPath.row
          }
        }
      } else {
        if outgoingfriendsContent.count > 0 {
          if indexPath.row == selectedRow  {
            let content = outgoingfriendsContent[indexPath.row] as! FriendCell
            content.close()
//            tableView.scrollEnabled = true
            selectedRow = -1
            selectedSection = -1
          } else {
            let content = outgoingfriendsContent[indexPath.row] as! FriendCell
            content.open()
            self.setTimeout(1.0, block: {
//              tableView.scrollEnabled = false
            })
            
            selectedSection = indexPath.section
            self.selectedRow = indexPath.row
          }
        }
        
      }
      disableTapForASec()
    
    }
    
    
    
    clearArrays()
    //    tableView.reloadData()
    tableView.endUpdates()
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
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    var title:String = ""
    
//    if section == 0 && self.pendingFriends.count > 0 {
//      title = "Incoming"
//    }
//    if section == 1 && self.pendingFriends.count > 0 {
//      title = "Outgoing"
//    }

    let container = UIView(frame: CGRect(x: 0, y:0, width: self.view.frame.size.width, height: 30))
    let topSeparator = UIView(frame: CGRect(x: 0, y:0, width: self.view.frame.size.width, height: 1))
    let bottomSeparator = UIView(frame: CGRect(x: 0, y:29, width: self.view.frame.size.width, height: 1))
    bottomSeparator.backgroundColor = CHUIElements().APPColors["Info"]
    topSeparator.backgroundColor = CHUIElements().APPColors["Info"]

    let innercontainer = UIView(frame: CGRect(x: 0, y:0, width: self.view.frame.size.width, height: 30))
    let label = UILabel(frame: CGRect(x: 15, y:0, width: self.view.frame.size.width - 15, height: 30))
    label.textColor = CHUIElements().APPColors["Info"]
    label.font = CHUIElements().font16
    
    if section == 0 && self.pendingFriends.count > 0 {
      title = "Incoming"
      label.text = title
      container.addSubview(topSeparator)
      container.addSubview(innercontainer)
      container.addSubview(bottomSeparator)
      container.addSubview(label)
      return container
    }
    if section == 1 && self.pendingFriends.count > 0 {
      title = "Outgoing"
      label.text = title
      container.addSubview(topSeparator)
      container.addSubview(innercontainer)
      container.addSubview(bottomSeparator)
      container.addSubview(label)
      return container
    }
    
    return container
  }
  
  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 30
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
  
  func getEmpty(text:String) ->UIView {
    let container = UIView(frame: CGRect(x: 0, y:0, width: self.view.frame.size.width, height: 66))
    let innercontainer = UIView(frame: CGRect(x: 0, y:0, width: self.view.frame.size.width, height: 66))
    let label = UILabel(frame: CGRect(x: 0, y:0, width: self.view.frame.size.width, height: 66))
    
    container.backgroundColor = UIColor.clearColor()
    innercontainer.backgroundColor = UIColor.clearColor()
    label.backgroundColor = UIColor.clearColor()
    
    label.text = text
    label.textColor = CHUIElements().APPColors["Info"]
    label.font = CHUIElements().font16
    label.textAlignment = .Center
    
    container.addSubview(innercontainer)
    container.addSubview(label)
    
    return container
  }
  
  @IBOutlet weak var refreshTableView: UIRefreshControl!
  
  @IBAction func refreshTableViewAction(sender: AnyObject) {
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
  
  func viewWithImageName(imageName: String) -> UIView {
    let image = UIImage(named: imageName)
    let imageView = UIImageView(image: image)
    imageView.contentMode = .Center
    return imageView
  }
  
  func viewWithLabel(text: String) -> UIView {
    let label = UILabel(frame: CGRect(x:0, y: 0, width: self.view.frame.width / 2, height: 66))
    label.text = text
    label.font = CHUIElements().font16
    label.numberOfLines = 3
    label.lineBreakMode = .ByWordWrapping
    label.textColor = CHUIElements().APPColors["Info"]
    return label
  }
  func swipeableTableViewCellDidStartSwiping(cell: SwipyCell) {
    
  }
  
  // When the user ends swiping the cell this method is called
  func swipeableTableViewCellDidEndSwiping(cell: SwipyCell) {
    
  }
  
  // When the user is dragging, this method is called with the percentage from the border
  func swipeableTableViewCell(cell: SwipyCell, didSwipeWithPercentage percentage: CGFloat) {
    
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
