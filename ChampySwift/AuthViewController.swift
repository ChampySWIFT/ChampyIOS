//
//  AuthViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/3/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Async

class AuthViewController: UIViewController {
  
  
  
  override func viewDidLoad() {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    super.viewDidLoad()
    
    self.navigationItem.hidesBackButton = true
    self.navigationItem.leftBarButtonItem = nil
    NotificationCenter.default.addObserver(self, selector: #selector(AuthViewController.authorized), name: NSNotification.Name(rawValue: "authorized"), object: nil)
    // Do any additional setup after loading the view.
  }
  
  
  
  
  
  @IBAction func authWithFacebook(_ sender: AnyObject) {
    
  }
  
  
  
  func authorized() {
    
    CHPush().localPush("setUpBehavior", object: self)
    self.dismiss(animated: false) {
      
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}
