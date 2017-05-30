//
//  ProfileSliderViewController.swift
//  Champy
//
//  Created by Molnar Kristian on 5/29/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class ProfileSliderViewController: UIViewController, UIScrollViewDelegate {
  @IBAction func pageindicatorValueChanged(_ sender: Any) {
    let page = CGFloat(self.paageIndicator.currentPage)
    let contentOffset = CGPoint(x: page * self.view.frame.width, y: 0.0)
    
    self.scrollView.setContentOffset(contentOffset, animated: true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.scrollView.delegate = self
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width * 3.0, height: self.scrollView.frame.height - 20 )
    
  }
  
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let point = self.scrollView.contentOffset
    let viewWidth = self.view.frame.width
    
    let pageIndicator = point.x / viewWidth
    
    paageIndicator.currentPage = Int(pageIndicator)
  }
  
  @IBOutlet weak var paageIndicator: UIPageControl!
  @IBOutlet weak var scrollView: UIScrollView!
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
