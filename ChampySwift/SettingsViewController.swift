//
//  SettingsViewController.swift
//  Champy
//
//  Created by AzinecLLC on 5/29/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    
    @IBOutlet var editProfileButton: UIButton!
    
    @IBOutlet var viewBehindImageView: UIView!
    
    @IBOutlet var imageView: UIImageView!
    
    
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
        let shadowPathForImage = UIBezierPath(roundedRect: CGRect(x: 0, y: 6, width: self.viewBehindImageView.frame.width, height: self.viewBehindImageView.frame.height), cornerRadius: self.viewBehindImageView.layer.cornerRadius)
        self.viewBehindImageView.layer.shadowColor = UIColor.green.cgColor
        self.viewBehindImageView.layer.shadowOpacity = 0.15   
        self.viewBehindImageView.layer.shadowPath = shadowPathForImage.cgPath
        
        self.imageView.layer.masksToBounds = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}
