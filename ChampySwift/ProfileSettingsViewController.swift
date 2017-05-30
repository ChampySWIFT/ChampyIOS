//
//  ProfileSettingsViewController.swift
//  Champy
//
//  Created by AzinecLLC on 5/29/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class ProfileSettingsViewController: UIViewController {

    @IBOutlet var viewBehindImageView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()


        self.viewBehindImageView.layer.cornerRadius = self.viewBehindImageView.frame.width/2
        self.viewBehindImageView.layer.borderWidth = 1
        self.viewBehindImageView.layer.borderColor = CHUIElements().borderColor.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
