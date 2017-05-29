//
//  ProfileSettingsViewController.swift
//  Champy
//
//  Created by AzinecLLC on 5/29/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UIViewController {

    @IBOutlet var editProfileButton: UIButton!
    @IBOutlet var viewBehindImageView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.editProfileButton.layer.borderWidth = 1
        self.editProfileButton.layer.borderColor = UIColor(colorLiteralRed: 205/255.0, green: 206/255.0, blue: 210/255.0, alpha: 0.2).cgColor
        
        let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 6, width: self.editProfileButton.frame.width, height: self.editProfileButton.frame.height)) 
        self.editProfileButton.layer.shadowColor = UIColor.green.cgColor
        self.editProfileButton.layer.shadowOpacity = 0.15   
        self.editProfileButton.layer.shadowRadius = 2.0
        self.editProfileButton.layer.shadowPath = shadowPath.cgPath

        self.viewBehindImageView.layer.cornerRadius = self.viewBehindImageView.frame.width/2
        self.viewBehindImageView.layer.borderWidth = 1
        self.viewBehindImageView.layer.borderColor = self.editProfileButton.layer.borderColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
