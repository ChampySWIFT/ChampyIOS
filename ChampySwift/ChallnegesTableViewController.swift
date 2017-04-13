//
//  ChallnegesTableViewController.swift
//  Champy
//
//  Created by Azinec Development on 3/17/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class ChallnegesTableViewController: UITableViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    // #warning Incomplete implementation, return the number of rows
    return challengeNumber
  }
  
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var index = indexPath.row
    
    if index == 0 {
      index = 1
    }
    
    if index >= 6 {
      index = 1
    }
    
    if indexPath.row % 2 == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ongoingCart", for: indexPath) as! OngoingChallengeTableViewCell
      cell.challengeType = .ongoingCart
      cell.setUpCart(challengeDetails: nil, color: index, width: self.view.frame.width - 16)
      
      return cell
    } else if indexPath.row % 3 == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "stepCounterCard", for: indexPath) as! OngoingChallengeTableViewCell
      cell.challengeType = .stepCounterCard
      cell.setUpCart(challengeDetails: nil, color: index, width: self.view.frame.width - 16)
      
      return cell
    } else if indexPath.row % 5 == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "incomingCart", for: indexPath) as! OngoingChallengeTableViewCell
      cell.challengeType = .incomingCart
      cell.setUpCart(challengeDetails: nil, color: index, width: self.view.frame.width - 16)
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "outgoingCart", for: indexPath) as! OngoingChallengeTableViewCell
      cell.challengeType = .outgoingCart
      cell.setUpCart(challengeDetails: nil, color: index, width: self.view.frame.width - 16)
      
      return cell
    }
    
    
    
    //        return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.performSegue(withIdentifier: "showChallengeDetails", sender: self)
  }
  
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showChallengeDetails" {
      let destination = segue.destination as! ChallengeDetailsViewController
      destination.strweaksValue = Int(arc4random_uniform(100))
      destination.completitionValue = "\(Int(arc4random_uniform(100)))%"
      destination.dayValue = Int(arc4random_uniform(20)+1)
      destination.challengeName = "Some challenge Name"
      let value = Int(arc4random_uniform(100))
      if value % 2 == 0 {
        destination.needsToCheck = true
      } else {
        destination.needsToCheck = false
      }
    }
  }
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
   if editingStyle == .delete {
   // Delete the row from the data source
   tableView.deleteRows(at: [indexPath], with: .fade)
   } else if editingStyle == .insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}
