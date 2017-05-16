//
//  CreateChallengeViewController.swift
//  Champy
//
//  Created by Azinec Development on 3/31/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class CreateChallengeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var challengesTableView: UITableView!
  
  override func viewDidLoad() {
     
    super.viewDidLoad()
    self.challengesTableView.delegate = self
    self.challengesTableView.dataSource = self
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 12
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CreateChallengeCart", for: indexPath)
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.performSegue(withIdentifier: "showChallengeDetails", sender: self)
  }
  
  @IBAction func backAction(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
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

