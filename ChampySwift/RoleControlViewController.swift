//
//  RoleControlViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async

class RoleControlViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let center = NSNotificationCenter.defaultCenter()
    
    center.addObserver(self, selector: #selector(RoleControlViewController.alert(_:)), name: "alert", object: nil)
    
    self.navigationItem.leftBarButtonItem = nil
    
    navigationController!.navigationBar.barTintColor = CHUIElements().APPColors["navigationBar"]
    let mainStoryboard: UIStoryboard          = UIStoryboard(name: "Main",bundle: nil)
    let authViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("AuthViewController")
    let mainViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("MainViewController")
    
    if !CHSession().logined {
      presentViewController(authViewController, type: .push, animated: false)
    } else {
      presentViewController(mainViewController, type: .push, animated: false)
    }
    
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
    
    // Do any additional setup after loading the view.
  }
  
  func alert(notif:NSNotification) {
    let object = notif.userInfo as! [String:String]
    var type:CHBanners.CHBannerTypes! = nil
    
    let remoteType:String = object["type"]!
    
    
    switch remoteType {
    case "Warning":
      type = .Warning
      break
    case "Success":
      type = .Success
      break
    default:
      type = .Default
    }
    
    let message = object["message"]
    self.alertWithMessage(message!, type:type)
  }
  
  func alertWithMessage(message:String, type:CHBanners.CHBannerTypes) {
    Async.main {
      let banner = CHBanners(withTarget: (self.navigationController?.view)!, andType: type)
      banner.showBannerForViewControllerAnimated(true, message: message)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
