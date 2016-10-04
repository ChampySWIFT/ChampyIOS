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
  let appDelegate     = UIApplication.shared.delegate as! AppDelegate
  let center = NotificationCenter.default
  
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
                    let roleControlViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "RoleControlViewController")
                    self.present(roleControlViewController, animated: false, completion: { 
                      
                    })
                  }
                }
              })
            }
          }
        }
      }
      
    }
    
    
    
    
    
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    center.removeObserver(self, name: NSNotification.Name(rawValue: "updateImage"), object: nil)
  }
  
  
  func setUpBackground() {
    Async.main {
      CHImages().setUpBackground(self.background, frame: self.view.frame)
    }
  }
  
  func setUpBackroundNotif(_ notification:Notification) {
    let data = (notification as NSNotification).userInfo as! [String:UIImage]
    self.background.image = data["image"]
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
    center.addObserver(self, selector: #selector(SettingsViewController.setUpBackroundNotif(_:)), name: NSNotification.Name(rawValue: "updateImage"), object: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  
  
}
