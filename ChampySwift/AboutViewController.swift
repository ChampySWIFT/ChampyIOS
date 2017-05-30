//
//  AboutViewController.swift
//  Champy
//
//  Created by Molnar Kristian on 5/30/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {
  @IBOutlet var viewBehindImageView: UIView!
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    self.viewBehindImageView.layer.cornerRadius = self.viewBehindImageView.frame.width/2
    self.viewBehindImageView.layer.borderWidth = 1
    self.viewBehindImageView.layer.borderColor = CHUIElements().borderColor.cgColor
    
    let shadowPathForImage = UIBezierPath(roundedRect: CGRect(x: 0, y: 6, width: self.viewBehindImageView.frame.width, height: self.viewBehindImageView.frame.height), cornerRadius: self.viewBehindImageView.layer.cornerRadius)
    self.viewBehindImageView.layer.shadowColor = UIColor.green.cgColor
    self.viewBehindImageView.layer.shadowOpacity = 0.30
    self.viewBehindImageView.layer.shadowPath = shadowPathForImage.cgPath
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
