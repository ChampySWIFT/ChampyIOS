//
//  ChallengeDetailsViewController.swift
//  Champy
//
//  Created by Azinec Development on 3/18/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class ChallengeDetailsViewController: UIViewController {
  
  @IBOutlet weak var streakNumberLabel: UILabel!
  @IBOutlet weak var completitionLabel: UILabel!
  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var streakSlider: StreakSlider!
  
  var needsToCheck:Bool = false
  var strweaksValue:Int = 0
  var completitionValue = ""
  var dayValue = 0
  var challengeName = ""
  
  @IBOutlet weak var navigationItemView: UINavigationItem!
  @IBOutlet weak var navigationBar: UINavigationBar!
  
//  @IBOutlet weak var skipAdayNeedsToCheck: UIButton!
//  @IBOutlet weak var checkInNeedsToCheck: UIButton!
  @IBOutlet weak var checkIn: UIButton!
  @IBOutlet weak var resultView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItemView.title = challengeName
    self.streakNumberLabel.text = String(self.strweaksValue)
    self.completitionLabel.text = self.completitionValue
    self.dayLabel.text = String(self.dayValue)
    
    let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 6, width: checkIn.frame.width, height: checkIn.frame.height)) 
    checkIn.layer.shadowColor = UIColor.green.cgColor
    checkIn.layer.shadowOpacity = 0.15   
    checkIn.layer.shadowRadius = 2.0 //Here control blur
    checkIn.layer.shadowPath = shadowPath.cgPath
    
    if needsToCheck {
//      self.checkIn.isHidden = true
//      self.checkInNeedsToCheck.isHidden = false
//      self.skipAdayNeedsToCheck.isHidden = false
    } else {
//      self.checkIn.isHidden = false
//      self.checkInNeedsToCheck.isHidden = true
//      self.skipAdayNeedsToCheck.isHidden = true
    }
    
    streakSlider.setDayNumber()
    
    streakSlider.setCurrentDay(day: self.dayValue)
    streakSlider.setUp()
    
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func closeAction(_ sender: Any) {
    self.dismiss(animated: true) { 
      
    }
  }
  
  @IBAction func confirmAction(_ sender: Any) {
    resultView.isHidden = true
  }
  @IBAction func checkInAction(_ sender: Any) {
    resultView.isHidden = false
  }
  
//  @IBAction func checkInNeeds(_ sender: Any) {
//    resultView.isHidden = false
//  }
    
    
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
