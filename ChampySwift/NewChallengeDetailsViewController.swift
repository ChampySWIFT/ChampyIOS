//
//  NewChallengeDetailsViewController.swift
//  Champy
//
//  Created by Azinec Development on 3/31/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class NewChallengeDetailsViewController: UIViewController {
  
  @IBOutlet weak var friendName: UILabel!
  @IBOutlet weak var successView: UIView!
  override func viewDidLoad() {
    super.viewDidLoad()
//
//    CHPush().localPush("refreshSelectedFriend", object: self)

    NotificationCenter.default.addObserver(self, selector: #selector(self.refreshSelectedFriend), name: NSNotification.Name(rawValue: "refreshSelectedFriend"), object: nil)
    
    // Do any additional setup after loading the view.
  }
  
  func refreshSelectedFriend() {
//    CHSession().CurrentUser.setValue(friendNames[indexPath.row], forKey: "selectedFriendName")
    let friendName:String = CHSession().CurrentUser.string(forKey: "selectedFriendName")!
    self.friendName.text = friendName
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func cancelAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func backAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func createChallengeAction(_ sender: Any) {
    self.successView.isHidden = false
  }
  
  @IBAction func finishAction(_ sender: Any) {
    self.dismiss(animated: true) { 
      
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "challengeFriend" {
      let destination = segue.destination as! FacebookFriendsViewController
      destination.isChallenging = true
    }
  }
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
