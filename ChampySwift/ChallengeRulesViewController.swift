//
//  ChallengeRulesViewController.swift
//  Champy
//
//  Created by Azinec Development on 3/18/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class ChallengeRulesViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func closeView(_ sender: Any) {
    self.dismiss(animated: true) { 
      
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
