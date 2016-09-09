//
//  SettingsViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/26/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async

import AVFoundation
class SettingsViewController: UIViewController {
  let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
  let center = NSNotificationCenter.defaultCenter()
  
  @IBOutlet weak var background: UIImageView!
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
    
    if appDelegate.settingsViewController == nil {
      appDelegate.settingsViewController = self
    }
    setUpBackground()
    
    Async.background{
      if IJReachability.isConnectedToNetwork()  {
        
        CHRequests().checkUser(CHSession().currentUserId) { (json, status) in
          if !status {
            CHPush().alertPush(json.stringValue, type: "Warning")
            Async.main {
              CHSession().clearSession({ (result) in
                if result {
                  Async.main {
                    let mainStoryboard: UIStoryboard                 = UIStoryboard(name: "Main",bundle: nil)
                    let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
                    self.presentViewController(roleControlViewController, type: .push, animated: false)
                  }
                }
              })
            }
          }
        }
      }
      
    }
    
    
    
    
    
  }
  
  override func viewDidDisappear(animated: Bool) {
    center.removeObserver(self, name: "updateImage", object: nil)
  }
  
  
  func setUpBackground() {
    Async.main {
      CHImages().setUpBackground(self.background, frame: self.view.frame)
    }
  }
  
  func setUpBackroundNotif(notification:NSNotification) {
    let data = notification.userInfo as! [String:UIImage]
    self.background.image = data["image"]
  }
  
  override func viewDidAppear(animated: Bool) {
    //    CHImages().setUpBackground(background)
    center.addObserver(self, selector: #selector(SettingsViewController.setUpBackroundNotif(_:)), name: "updateImage", object: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  
  
}
