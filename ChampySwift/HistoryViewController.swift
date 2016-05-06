//
//  HistoryViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/26/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {
  let appDelegate     = UIApplication.sharedApplication().delegate as! AppDelegate
  
  @IBOutlet weak var background: UIImageView!
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
    if appDelegate.historyViewController == nil {
      appDelegate.historyViewController = self
    }
    CHImages().setUpBackground(background, frame: self.view.frame)
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(animated: Bool) {
//    CHImages().setUpBackground(background)
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
