//
//  FeedbackViewController.swift
//  Champy
//
//  Created by Azinec Development on 12/23/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import Async

class FeedbackViewController: UIViewController, UITextViewDelegate {

  @IBOutlet weak var userAvatar: UIImageView!
  @IBOutlet weak var feedbackText: UITextView!
  
  
  @IBAction func sendAction(_ sender: Any) {
    let text = self.feedbackText.text
    let userId = CHSession().currentUserId
    let userEmail = CHSession().currentUserObject["email"].stringValue
    let userName = CHSession().currentUserName
    
    let params:[String:String] = [
      "userId" : userId,
      "name" : userName,
      "email" : userEmail,
      "description" : text!
    ]
    
    
    if (text?.characters.count)! < 15 || text == "Your Feedback: "  {
      self.alertWithMessage("Your feedback is too short", type: .Warning)
      return
    }
    
    
    CHRequests().leaveFeedback(params, completitionHandler: { (result, json) in
      if result {
        self.dismiss(animated: true, completion: nil)
        CHPush().alertPush("Your feedback has been sent", type: "Info")
      }
    })
  }
  
  func alertWithMessage(_ message:String, type:CHBanners.CHBannerTypes) {
    Async.main {
      let banner = CHBanners(withTarget: self.view, andType: type)
      banner.showBannerForViewControllerAnimated(true, message: message)
    }
  }
  
  @IBAction func closeAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.feedbackText.text = "Your Feedback: "
    self.feedbackText.delegate = self
    self.userAvatar.layer.masksToBounds = true
    self.userAvatar.layer.cornerRadius = 50.0
    
    self.feedbackText.textColor = CHUIElements().APPColors["navigationBar"]
    let spaceButton     = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
    
    let toolBar                             = UIToolbar(frame: CGRect(x: 0,y: 0,width: self.view.frame.size.width,height: 44))
    toolBar.barStyle                        = UIBarStyle.default
    let barButtonDone                       = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(FeedbackViewController.done))
    barButtonDone.tintColor = CHUIElements().APPColors["navigationBar"]
    toolBar.items                           = [spaceButton, barButtonDone]
    
    self.feedbackText.inputAccessoryView = toolBar;
    self.feedbackText.delegate  = self
    
    CHImages().setUpAvatar(userAvatar)
    
    // Do any additional setup after loading the view.
  }
  
  func done (){
    
    self.feedbackText.resignFirstResponder()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func textViewDidEndEditing(_ textView: UITextView) {
    let myString = textView.text
    let trimmedString = myString?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    textView.text = trimmedString
    if textView.text == "" {
      textView.text = "Your Feedback: "
    }
    textView.resignFirstResponder()
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    if textView.text == "Your Feedback: " || textView.text == "" {
     textView.text = ""
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
