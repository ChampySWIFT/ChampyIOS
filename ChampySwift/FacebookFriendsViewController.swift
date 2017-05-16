//
//  FacebookFriendsViewController.swift
//  Champy
//
//  Created by Azinec Development on 4/7/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftRandom


class FacebookFriendsViewController: UIViewController {
  fileprivate var friendNumber:Int = 0
  fileprivate var friendNames:[String] = []
  fileprivate var cellStatus:[Bool] = []
  fileprivate var selectedFriend:IndexPath!
  fileprivate var tableViewCells:[FriendsTableViewCell] = []
  
  @IBOutlet weak var profileButton: UIBarButtonItem!
  @IBOutlet weak var tableViewOutlet: UITableView!
  @IBOutlet weak var navBar: UINavigationItem!
  @IBOutlet weak var bottomConstrait: NSLayoutConstraint!
  @IBOutlet weak var searchBar: UISearchBar!
  
  var isChallenging:Bool = false
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.friendNumber = Randoms.randomInt(10,50)
    
    for i in 0..<self.friendNumber {
      self.friendNames.append(Randoms.randomFakeName())
    }
    
    if isChallenging {
      navBar.title = "Challenge a Friend"
      self.navBar.leftBarButtonItem = nil
      let backButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(FacebookFriendsViewController.backAction))
      self.navBar.leftBarButtonItem = backButton
      self.bottomConstrait.constant = 0.0
    }
  }
  
  func backAction() {
    self.dismiss(animated: true) { 
    
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
}


extension FacebookFriendsViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    self.friendNumber = Randoms.randomInt(0,10)
    self.friendNames.removeAll()
    for i in 0..<self.friendNumber {
      self.friendNames.append(Randoms.randomFakeName())
    }
    
    self.tableViewOutlet.reloadData()
    
    return true
  }
}

extension FacebookFriendsViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.friendNumber
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! FriendsTableViewCell
    if cell.isOpened {
      selectedFriend = nil
      cell.close()
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "friendsTableViewCell") as! FriendsTableViewCell
    
    cell.setUp(friend: nil, name: friendNames[indexPath.row])
    cell.selectionStyle = .none
    if selectedFriend == nil {return cell}
    cell.spotID = "12312b3jhg12hj3g1jh3"
    if selectedFriend == indexPath {
      cell.open()
    } else {
      cell.close()
    }
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! FriendsTableViewCell
    self.searchBar.resignFirstResponder()
    if isChallenging {
      CHSession().CurrentUser.setValue(friendNames[indexPath.row], forKey: "selectedFriendName")
      CHPush().localPush("refreshSelectedFriend", object: self)
      backAction()
      return
    }
    
    
    if cell.isOpened {
      selectedFriend = nil
      cell.close()
    } else {
      if selectedFriend != nil { self.closePrevious(indexPath: selectedFriend) }
      selectedFriend = indexPath
      cell.open()
    }
  }
  
  func closePrevious(indexPath: IndexPath) {
    if let cell = tableViewOutlet.cellForRow(at: indexPath) as? FriendsTableViewCell {
      cell.close()
    }
  }
  
  
}


class FriendsTableViewCell: UITableViewCell {
  @IBOutlet weak var friendAvatar: UIImageView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var streakContainer: UIView!
  @IBOutlet weak var streakTitleLabel: UILabel!
  @IBOutlet weak var streakLabel: UILabel!
  @IBOutlet weak var challengeTitleLabel: UILabel!
  @IBOutlet weak var challengeLabel: UILabel!
  @IBOutlet weak var separatorView: UIView!
  @IBOutlet weak var containerView: UIView!
  
  var spotID:String = ""
  
 
  
   var isOpened:Bool = false
  
  
  func open(){
    isOpened = true
    self.streakContainer.fadeIn()
  }
  
  func close() {
    isOpened = false
     self.streakContainer.fadeOut()
  }
  
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  
  func setUp(friend:JSON = nil, name:String = "") {
    self.nameLabel.text = name
    let index = "color\(Randoms.randomInt(1, 8))"
    
    self.nameLabel.textColor = Colors.labelColors[index]
    self.challengeLabel.textColor = Colors.labelColors[index]
    self.challengeTitleLabel.textColor = Colors.labelColors[index]
    self.streakLabel.textColor = Colors.labelColors[index]
    self.streakTitleLabel.textColor = Colors.labelColors[index]
    self.separatorView.backgroundColor = Colors.labelColors[index]
    self.separatorView.alpha = 0.15
    self.containerView.addShadow(color: separatorView.backgroundColor!)
    Randoms.createGravatar(Randoms.GravatarStyle.MonsterID) { (image, error) -> Void in
      if error == nil {
        self.friendAvatar.layer.borderColor = UIColor.white.cgColor//Colors.labelColors[index]?.cgColor
        self.friendAvatar.layer.borderWidth = 2.0
        self.friendAvatar.image = image
        self.friendAvatar.layer.cornerRadius = self.friendAvatar.frame.width / 2
        self.friendAvatar.layer.masksToBounds = true
      }
    }
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}

extension UIView {
  
  func fadeIn(){
    UIView.animate(withDuration: 0.5) {
      self.alpha = 1.0
    }
  }
  
  
  func fadeOut(){
    UIView.animate(withDuration: 0.5) {
      self.alpha = 0.0
    }
  }
  
  
}

