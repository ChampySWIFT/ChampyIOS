//
//  SettingsViewController.swift
//  Champy
//
//  Created by AzinecLLC on 5/29/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet var viewBehindImageView: UIView!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var dailyNOtificatorSwitch: UISwitch!
      
    @IBOutlet var checkinTimeTextfield: UITextField!
    
    @IBOutlet var reminderTimeTextfield: UITextField!
    
    var timePicker:UIDatePicker! = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timePicker = CHUIElements().initAndSetUpDatePicker(30)
        
        let toolBarReminder = UIToolbar(frame: CGRect(x: 0,y: 0,width: self.view.frame.size.width,height: 44))
       
   
        let spaceButtonReminder = UIBarButtonItem(title: "Cancel", style: .plain, target: self , action: #selector(self.cancelChanges))
        
        let flexibleSpaceReminder = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let barButtonDoneReminder = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.valueChangedInReminder))
       
        
        toolBarReminder.items = [spaceButtonReminder, flexibleSpaceReminder, barButtonDoneReminder]
        
        
         let toolBarCheck = UIToolbar(frame: CGRect(x: 0,y: 0,width: self.view.frame.size.width,height: 44))
        
        let spaceButtonCheck = UIBarButtonItem(title: "Cancel", style: .plain, target: self , action: #selector(self.cancelChanges))
        
        let flexibleSpaceCheck = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
         let barButtonDoneCheck = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.valueChangedInCheck))
        
        toolBarCheck.items = [spaceButtonCheck, flexibleSpaceCheck, barButtonDoneCheck]
        
        
        
        self.reminderTimeTextfield.inputAccessoryView = toolBarReminder
        self.reminderTimeTextfield.inputView = timePicker
         self.checkinTimeTextfield.inputAccessoryView = toolBarCheck
        self.checkinTimeTextfield.inputView = timePicker
        
        
        self.reminderTimeTextfield.delegate = self
        self.checkinTimeTextfield.delegate = self
        
        let minutes:Int = CHSession().getIntByKey("minsDN")
        
        if CHSession().getIntByKey("minsDN") == 0 {
            self.reminderTimeTextfield.text = "\(CHSession().getIntByKey("hoursDN")):00"
        } else {
            self.reminderTimeTextfield.text = "\(CHSession().getIntByKey("hoursDN")):\(CHSession().getIntByKey("minsDN"))"
        }        
        
        if CHSession().getIntByKey("checkminsDN") == 0 {
            self.checkinTimeTextfield.text = "\(CHSession().getIntByKey("checkhoursDN")):00"
        } else {
            self.checkinTimeTextfield.text = "\(CHSession().getIntByKey("checkminsDN")):\(CHSession().getIntByKey("checkminsDN"))"
        }  
        
        
        
        
        self.viewBehindImageView.layer.cornerRadius = self.viewBehindImageView.frame.width/2
        self.viewBehindImageView.layer.borderWidth = 1
        self.viewBehindImageView.layer.borderColor = CHUIElements().borderColor.cgColor
        
        
        let shadowPathForImage = UIBezierPath(roundedRect: CGRect(x: 0, y: 6, width: self.viewBehindImageView.frame.width, height: self.viewBehindImageView.frame.height), cornerRadius: self.viewBehindImageView.layer.cornerRadius)
        self.viewBehindImageView.layer.shadowColor = UIColor.green.cgColor
        self.viewBehindImageView.layer.shadowOpacity = 0.30
        self.viewBehindImageView.layer.shadowPath = shadowPathForImage.cgPath
        
        
        
        self.imageView.layer.masksToBounds = true
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
    
    func valueChangedInReminder() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateFormat = "HH:mm"
        let strDate = dateFormatter.string(from : timePicker.date)
        
        let calendar = NSCalendar.current

        let comp = (calendar as NSCalendar).components([.hour, .minute, .second], from: timePicker.date)
        let hour = comp.hour
        let minute = comp.minute
        
        self.reminderTimeTextfield.text = strDate
        
        self.reminderTimeTextfield.resignFirstResponder()
        if hour! < 10 {
        CHSession().CurrentUser.set(hour, forKey: "hoursDN")
        } else {
            CHSession().CurrentUser.set(hour, forKey: "hoursDN")
        }
        CHSession().CurrentUser.set(minute, forKey: "minsDN")
        
    }
    
    func valueChangedInCheck() {
        let dateFormatter = DateFormatter()
        
        dateFormatter.timeStyle = DateFormatter.Style.short
        dateFormatter.dateFormat = "HH:mm"
        let strDate = dateFormatter.string(from : timePicker.date)
        
        let calendar = NSCalendar.current
        
        let comp = (calendar as NSCalendar).components([.hour, .minute, .second], from: timePicker.date)
        let hour = comp.hour
        let minute = comp.minute
        
        self.checkinTimeTextfield.text = strDate
        
        self.checkinTimeTextfield.resignFirstResponder()
        
        CHSession().CurrentUser.set(hour, forKey: "checkhoursDN")
        CHSession().CurrentUser.set(minute, forKey: "checkminsDN")
        
    }
    
    
    func cancelChanges(){
        self.reminderTimeTextfield.resignFirstResponder()
        self.checkinTimeTextfield.resignFirstResponder()
    }
    
    
    
    
}
