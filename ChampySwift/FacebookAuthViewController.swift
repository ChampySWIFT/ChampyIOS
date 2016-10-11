//
//  FacebookAuthViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 7/18/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async



class FacebookAuthViewController: UIViewController {
  var tapped:Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
//    let loginManager = LoginManager()
//    loginManager.logIn([ .PublicProfile, .UserFriends, .Email ], viewController: self) { loginResult in
//      switch loginResult {
//      case .Failed(let error):
//        print(error)
//      case .Cancelled:
//        print("User cancelled login.")
//      case .Success(let grantedPermissions, let declinedPermissions, let accessToken):
//        print("Logged in!")
//      }
    
    
    
    CHBanners().setTimeout(3) {
      guard IJReachability.isConnectedToNetwork() else {
        CHPush().alertPush("No Internet Connection", type: "Warning")
        return
      }
      
      guard !self.tapped else {
        return
      }
      
      self.tapped = true
      let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
      fbLoginManager.logOut()
      let facebookReadPermissions = ["public_profile", "email", "user_friends"]
      fbLoginManager.logIn(withReadPermissions: facebookReadPermissions,  handler: { (result, error) -> Void in
        
        guard error == nil else {
          CHPush().alertPush("Error with facebook...", type: "Warning")
          self.tapped = false
          self.goback()
          return
        }
        
        let fbloginresult : FBSDKLoginManagerLoginResult = result!
        guard fbloginresult.grantedPermissions != nil else {
          CHPush().alertPush("Can`t get data from facebook", type: "Warning")
          self.tapped = false
          self.goback()
          return
        }
        guard fbloginresult.grantedPermissions.contains("email") else {
          let message = "Please check your facebook permissions..."
          CHPush().alertPush(message, type: "Warning")
          self.tapped = false
          self.goback()
          return
        }
        guard FBSDKAccessToken.current() != nil else {
          let message = "Please check your facebook session..."
          CHPush().alertPush(message, type: "Warning")
          self.tapped = false
          self.goback()
          return
        }
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (connection, result, error) -> Void in
          guard error == nil else {
            CHPush().alertPush("Can`t get data from facebook", type: "Warning")
            self.tapped = false
            self.goback()
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
          
          
          
          //          FBReq
          CHRequests().createUser(params, completitionHandler: { (json, status) in
            print(json)
            self.tapped = false
            if status {
              Async.main {
                let faceParams = ["fields": "id"]
                let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: faceParams)
                request?.start(completionHandler: { (connection, result, error) in
                  
                  let res = result as! [String:AnyObject]
                  if error != nil {
                    
                    self.dismiss(animated: true, completion: {
                      self.tapped = false
                      CHPush().alertPush("Can't get friends from facebook", type: "Warning")
                      CHPush().localPush("authorized", object: self)
                    })
                    /* Handle error */
                  }
                  print(result)
                  Async.main {
                    
                    let array = res["data"] as! [[String:String]]
                    var friendsIdArray:[String] = []
                    for item in array {
                      friendsIdArray.append(item["id"]!)
                    }
                    CHPush().subscribeForNotifications()
                    CHSession().saveFacebookFriends("\(friendsIdArray)")
                    self.dismiss(animated: false, completion: {
                      self.tapped = false
                      CHPush().alertPush("Succesfully authorized", type: "Success")
                      CHPush().localPush("authorized", object: self)
                    })
                  }
                })
                
                
                
              }
            }
          })
          
          
        })
      })
      
    }
    // Do any additional setup after loading the view.
  }
  
  func saveFacebookFriends() {
    
  }
  
  @IBAction func backToLoginAction(_ sender: AnyObject) {
    self.dismiss(animated: true) { 
      
    }
  }
  
  func goback() {
    self.dismiss(animated: true, completion: {
      
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
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
