//
//  AuthViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import PresenterKit

class AuthViewController: UIViewController {
  
  var tapped:Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.hidesBackButton = true
    self.navigationItem.leftBarButtonItem = nil
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func authWithFacebook(sender: AnyObject) {
    guard IJReachability.isConnectedToNetwork() else {
      CHPush().alertPush("No Internet Connection", type: "Warning")
      return
    }
    
    guard !tapped else {
      return
    }
    
    tapped = true
    let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
    fbLoginManager.logOut()
    fbLoginManager.logInWithReadPermissions(["email"],  handler: { (result, error) -> Void in
      
      guard error == nil else {
        CHPush().alertPush("Error with facebook...", type: "Warning")
        self.tapped = false
        
        return
      }
      
      let fbloginresult : FBSDKLoginManagerLoginResult = result
      guard fbloginresult.grantedPermissions != nil else {
        CHPush().alertPush("Can`t get data from facebook", type: "Warning")
        self.tapped = false
        return
      }
      guard fbloginresult.grantedPermissions.contains("email") else {
        let message = "Please check your facebook permissions..."
        CHPush().alertPush(message, type: "Warning")
        self.tapped = false
        return
      }
      guard FBSDKAccessToken.currentAccessToken() != nil else {
        let message = "Please check your facebook session..."
        CHPush().alertPush(message, type: "Warning")
        self.tapped = false
        return
      }
      
      FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
        guard error == nil else {
          CHPush().alertPush("Can`t get data from facebook", type: "Warning")
          self.tapped = false
          return
        }
        let fbResult   = result as! Dictionary<String, AnyObject>
        let name       = fbResult["name"] as! String
        let email      = fbResult["email"] as! String
        let facebookId = fbResult["id"] as! String
        
        let params:[String:String] = [
          "facebookId": facebookId,
          "name": name,
          "email": email
        ]
        
        Async.background {
          CHRequests().createUser(params, completitionHandler: { (json, status) in
            self.tapped = false
            if status {
              Async.main {
                self.tapped = false
                CHPush().alertPush("Succesfully authorized", type: "Success")
                let mainStoryboard: UIStoryboard          = UIStoryboard(name: "Main",bundle: nil)
                let roleControlViewController : UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("RoleControlViewController")
                self.presentViewController(roleControlViewController, type: .push, animated: false)
              }
            }
          })
        }
        
        
        
      })
    })
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
