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
import Photos
import AVFoundation
import CoreMotion

class SettingsViewController: UIViewController {
  var manager: CMMotionManager!
  let appDelegate     = UIApplication.shared.delegate as! AppDelegate
  let center = NotificationCenter.default
  
  @IBOutlet weak var friendsBarButton: UIBarButtonItem!
  @IBOutlet weak var challengesBarButtonItem: UIBarButtonItem!
  @IBOutlet weak var background: UIImageView!
  override func viewDidLoad() {
    
    super.viewDidLoad()
    checkForAuthorizationStatus()
    var unconfirmedChallenges:Int = 0
    self.appDelegate.unconfirmedChallenges = unconfirmedChallenges
    
    for challenge in CHChalenges().getInProgressChallenges(CHSession().currentUserId).reversed() {
      let challengeType = CHChalenges().getChallengeType(challenge)
      if challengeType == .unconfirmedDuelRecipient || challengeType == .unconfirmedDuelSender {
        unconfirmedChallenges += 1
        self.appDelegate.unconfirmedChallenges = unconfirmedChallenges
      }
    }
    
    if appDelegate.unconfirmedChallenges > 0 {
      if self.challengesBarButtonItem.badgeLayer != nil {
        self.challengesBarButtonItem.updateBadge(number: appDelegate.unconfirmedChallenges)
      } else {
        self.challengesBarButtonItem.addBadge(number: appDelegate.unconfirmedChallenges)
      }
    }
    
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
    
    if appDelegate.settingsViewController == nil {
      appDelegate.settingsViewController = self
    }
    setUpBackground()
    
    Async.background{
      CHRequests().getAllUsers { (result, json) in
        Async.main {
          let friendsBadgeCount = CHUsers().getIncomingRequestCount()
          if friendsBadgeCount > 0 {
            if self.friendsBarButton.badgeLayer != nil {
              self.friendsBarButton.updateBadge(number: friendsBadgeCount)
            } else {
              self.friendsBarButton.addBadge(number: friendsBadgeCount)
            }
          }
          
          if CHUsers().getIncomingRequestCount() == 0 {
            if self.friendsBarButton.badgeLayer != nil {self.friendsBarButton.removeBadge()}
          }
        }
      }
      if IJReachability.isConnectedToNetwork()  {
        
        CHRequests().checkUser(CHSession().currentUserId) { (json, status) in
          if !status {
            CHPush().alertPush(json.stringValue, type: "Warning")
            Async.main {
              CHSession().clearSession({ (result) in
                if result {
                  Async.main {
//                    let mainStoryboard: UIStoryboard                 = UIStoryboard(name: "Main",bundle: nil)
//                    let roleControlViewController : UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "RoleControlViewController")
//                    self.present(roleControlViewController, animated: false, completion: { 
//                      
//                    })
                    self.navigationController?.performSegue(withIdentifier: "showRoleControllerFromNavigation", sender: self)
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
    manager.stopDeviceMotionUpdates()
    center.removeObserver(self, name: NSNotification.Name(rawValue: "updateImage"), object: nil)
  }
  
  func checkForAuthorizationStatus() {
    
    
    if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
      PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) in
        
      })
    }
    
    
    if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) ==  AVAuthorizationStatus.authorized
    {
      // Already Authorized
    }
    else
    {
      AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
        if granted == true
        {
          // User granted
        }
        else
        {
          // User Rejected
        }
      });
    }
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
    manager = CMMotionManager()
    if manager.isDeviceMotionAvailable {
      manager.deviceMotionUpdateInterval = 0.01
      
      manager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: { (data, error) in
        if (data?.userAcceleration.x)! < Double(-2.5) {
          self.navigationController?.popViewController(animated: true)
        }
        
      })
    }

    center.addObserver(self, selector: #selector(SettingsViewController.setUpBackroundNotif(_:)), name: NSNotification.Name(rawValue: "updateImage"), object: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  
  
}
