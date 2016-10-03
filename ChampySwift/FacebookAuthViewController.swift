//
//  FacebookAuthViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 7/18/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async
import PresenterKit
import Firebase
class FacebookAuthViewController: UIViewController {
  var tapped:Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
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
      fbLoginManager.logInWithReadPermissions(facebookReadPermissions,  handler: { (result, error) -> Void in
        
        guard error == nil else {
          CHPush().alertPush("Error with facebook...", type: "Warning")
          self.tapped = false
          self.goback()
          return
        }
        
        let fbloginresult : FBSDKLoginManagerLoginResult = result
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
        guard FBSDKAccessToken.currentAccessToken() != nil else {
          let message = "Please check your facebook session..."
          CHPush().alertPush(message, type: "Warning")
          self.tapped = false
          self.goback()
          return
        }
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, email"]).startWithCompletionHandler({ (connection, result, error) -> Void in
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
          
          let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
          FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
            
          })
          
          
          //          FBReq
          CHRequests().createUser(params, completitionHandler: { (json, status) in
            ////print(json)
            self.tapped = false
            if status {
              Async.main {
                let faceParams = ["fields": "id"]
                let request = FBSDKGraphRequest(graphPath: "me/friends", parameters: faceParams)
                
                request.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                  
                  if error != nil {
                    let errorMessage = error.localizedDescription
                    ////print(errorMessage)
                    self.dismissViewControllerAnimated(true, completion: {
                      self.tapped = false
                      CHPush().alertPush("Can't get friends from facebook", type: "Warning")
                      CHPush().localPush("authorized", object: [])
                    })
                    /* Handle error */
                  }
                  else if result.isKindOfClass(NSDictionary){
                    Async.main {
                      
                      let array = result["data"] as! [[String:String]]
                      var friendsIdArray:[String] = []
                      for item in array {
                        friendsIdArray.append(item["id"]!)
                      }
                      CHPush().subscribeForNotifications()
                      CHSession().saveFacebookFriends("\(friendsIdArray)")
                      self.dismissViewControllerAnimated(false, completion: {
                        self.tapped = false
                        CHPush().alertPush("Succesfully authorized", type: "Success")
                        CHPush().localPush("authorized", object: [])
                      })
                    }
                    
                  }
                }
                
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
  
  @IBAction func backToLoginAction(sender: AnyObject) {
    self.dismissViewControllerAnimated(true) { 
      
    }
  }
  
  func goback() {
    self.dismissViewControllerAnimated(true, completion: {
      
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
    
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
