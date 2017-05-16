//
//  SettingsDrowerViewController.swift
//  Champy
//
//  Created by Molnar Kristian on 4/16/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class SettingsDrowerViewController: UIViewController, UIScrollViewDelegate {
  let appDelegate     = UIApplication.shared.delegate as! AppDelegate
  let delegate = UIApplication.shared.delegate as! AppDelegate
  var pageImages: [UIImage]       = []
  var pageViews: [UIImageView?]   = []
  
  var table1 = SettingsFirstPageViewController()
  var table2 = SettingsSecondPageViewController()
  var table3 = SettingsThirdPageViewController()
  
  @IBOutlet weak var pageControl: UIPageControl!
  
  @IBOutlet weak var contentScrollView: UIScrollView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.hidesBackButton = true
    self.contentScrollView.delegate = self
//    CHImages().setUpBackground(background, frame: self.view.frame)
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
     loadVisiblePages()
  }
  
 
  
  
  
  override func viewDidAppear(_ animated: Bool) {
    let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
    table1 = mainStoryboard.instantiateViewController(withIdentifier: "SettingsFirstPageViewController") as! SettingsFirstPageViewController
    table2 = mainStoryboard.instantiateViewController(withIdentifier: "SettingsSecondPageViewController") as! SettingsSecondPageViewController
    table3 = mainStoryboard.instantiateViewController(withIdentifier: "SettingsThirdPageViewController") as! SettingsThirdPageViewController
    
    
    self.setUpFrames()
    
    self.addChildViewController(table1)
    self.addChildViewController(table2)
    self.addChildViewController(table3)
    table1.didMove(toParentViewController: self)
    table2.didMove(toParentViewController: self)
    table3.didMove(toParentViewController: self)
    contentScrollView.addSubview(table1.view)
    contentScrollView.addSubview(table2.view)
    contentScrollView.addSubview(table3.view)
    
    
    
    loadVisiblePages()
    contentScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
  }
  
  
  func setUpFrames() {
    
    
    let pagesScrollViewSize = contentScrollView.frame.size
    contentScrollView.contentSize =  CGSize(width: self.view.frame.size.width * 3, height: self.view.frame.size.height - 88)
//    CGSize()
    var firstFrame:CGRect  = table1.view.frame
    firstFrame.origin.x    = 0
    firstFrame.origin.y    = 0
    firstFrame.size.width  = self.contentScrollView.frame.size.width
    firstFrame.size.height = self.contentScrollView.frame.size.height
    table1.view.frame = firstFrame
    
    //    privateUserSecondScreen                 = mainStoryboard.instantiateViewControllerWithIdentifier("PrivateProfileSecondScreenTableViewController") as! PrivateProfileSecondScreenTableViewController
    var secondFrame:CGRect  = table2.view.frame
    secondFrame.origin.x    = self.contentScrollView.frame.size.width
    secondFrame.origin.y    = 0
    secondFrame.size.width  = self.contentScrollView.frame.size.width
    secondFrame.size.height = self.contentScrollView.frame.size.height
    table2.view.frame = secondFrame
    
    var thirdFrame:CGRect  = table3.view.frame
    thirdFrame.origin.x    = self.contentScrollView.frame.size.width * 2
    thirdFrame.origin.y    = 0
    thirdFrame.size.width  = self.contentScrollView.frame.size.width
    thirdFrame.size.height = self.contentScrollView.frame.size.height
    table3.view.frame = thirdFrame
  }
  
  
  func loadVisiblePages() {
    
    // First, determine which page is currently visible
    let pageWidth = contentScrollView.frame.size.width
    let page      = Int(floor((contentScrollView.contentOffset.x * 3.0 + pageWidth) / (pageWidth * 3.0)))
    pageControl.currentPage = page
  }
  
  
  
}
