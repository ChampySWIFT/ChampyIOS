//
//  WakeUpInfoViewController.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 6/30/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit

class WakeUpInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBOutlet weak var dismissViewController: UIButton!

  @IBAction func dismissAction(sender: AnyObject) {
    self.dismissViewControllerAnimated(true, completion: nil)
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
