//
//  Extentions.swift
//  Champy
//
//  Created by Azinec Development on 12/21/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Firebase
import SwiftyJSON
import Async
import MessageUI

class Extensions: NSObject {
  class func logEvent(eventName:String) {
    FIRAnalytics.setUserPropertyString(eventName, forName: "favourite_screen")
  }
}

extension MainViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    FIRAnalytics.setUserPropertyString(segue.identifier, forName: "favourite_screen")
  }
  
}

extension HistoryViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    FIRAnalytics.setUserPropertyString(segue.identifier, forName: "favourite_screen")
  }
  
}

extension FriendsViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    FIRAnalytics.setUserPropertyString(segue.identifier, forName: "favourite_screen")
  }
  
}

extension SettingsViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    FIRAnalytics.setUserPropertyString(segue.identifier, forName: "favourite_screen")
  }
  
}

extension SelfImprovementViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    FIRAnalytics.setUserPropertyString(segue.identifier, forName: "favourite_screen")
  }
  
}

extension DuelViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    FIRAnalytics.setUserPropertyString(segue.identifier, forName: "favourite_screen")
  }
  
}

extension WakeUpViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    FIRAnalytics.setUserPropertyString(segue.identifier, forName: "favourite_screen")
  }
  
}

extension WakeUpInfoViewController {
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    FIRAnalytics.setUserPropertyString(segue.identifier, forName: "favourite_screen")
  }
  
}

extension UIImageView{
  
  func makeBlurImage(_ targetImageView:UIImageView?) {
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
    
    let blurEffectView = UIVisualEffectView(effect: blurEffect)
    blurEffectView.alpha = 0.7
    blurEffectView.frame = targetImageView!.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
    targetImageView?.addSubview(blurEffectView)
  }
  
}

extension UIView {
  
  func cleareScoreContainer() {
    for item in self.subviews {
      if item.layer.value(forKey: "type") != nil {
        if item.layer.value(forKey: "type") as! String == "inner" {
          item.removeFromSuperview()
        }
      }
    }
  }
  
  func rotateView(_ withDuration:Double) {
    self.transform = CGAffineTransform(rotationAngle: (0 * CGFloat(M_PI)) / 180.0)
    UIView.animate(withDuration: withDuration, animations: {
      self.transform = CGAffineTransform(rotationAngle: (180 * CGFloat(M_PI)) / 180.0)
    })
  }
  
  func rotateScoreViewToZero(){ }
  
  func fillScoreBorder(_ withDuration:Double) {
    let view    = self as! ScoreBorder
    let newView = UIView(frame: view.frame)
    newView.frame              = CGRect(x: newView.frame.origin.x + 3, y: newView.frame.origin.y + 2, width: newView.frame.width, height: newView.frame.height)
    newView.backgroundColor    = UIColor.white
    newView.layer.cornerRadius = view.frame.width / 2
    newView.layer.opacity      = 0.50
    newView.layer.setValue("inner", forKey: "type")
    newView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    self.superview!.addSubview(newView)
    self.superview?.sendSubview(toBack: newView)
    UIView.animate(withDuration: withDuration , animations: {
      newView.transform = CGAffineTransform(scaleX: 0.782, y: 0.782)
    })
  }
  
  func oval2Path() -> UIBezierPath {
    let oval2Path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 2, height: 2))
    return oval2Path
  }
  
}

extension UILabel {
  
  func countdownFrom(_ from:Int, to:Int) {
    
  }
  
}

extension UIApplication {
  
  class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let nav = base as? UINavigationController {
      return topViewController(nav.visibleViewController)
    }
    if let tab = base as? UITabBarController {
      if let selected = tab.selectedViewController {
        return topViewController(selected)
      }
    }
    if let presented = base?.presentedViewController {
      return topViewController(presented)
    }
    return base
  }
  
}

extension String {
  //  /^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$/u
  func isName() -> Bool {
    let regex = try! NSRegularExpression(pattern: "[QWERTYUIOPLKJHGFDSAZXCVBNMйцукенгшщзхїґєждлорпавіфячсмитьбюыЙЦУКЕНГШЩЗХЇЄЖДЛҐОРПАВИФЯЧСМІТЬБЮЫqwertyuioplkjhgfdsazxcvbnmàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$",
                                         options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                            range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func isChallengeName() -> Bool {
    let regex = try! NSRegularExpression(pattern: "[1234567890QWERTYUIOPLKJHGFDSAZXCVBNMйцукенгшщзхїґєждлорпавіфячсмитьбюыЙЦУКЕНГШЩЗХЇЄЖДЛҐОРПАВИФЯЧСМІТЬБЮЫqwertyuioplkjhgfdsazxcvbnmàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$",
                                         options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                            range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func isDayNumber() -> Bool {
    //    ^[0-9]{1,3}$
    let regex = try! NSRegularExpression(pattern: "^[0-9]{1,3}$",
                                         options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                            range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func isStepNumber() -> Bool {
    //    ^[0-9]{1,3}$
    let regex = try! NSRegularExpression(pattern: "^[0-9]{1,6}$",
                                         options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                            range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func isValidChallengeName() -> Bool {
    //  [^,.'-]+
    let regex = try! NSRegularExpression(pattern: "^[^,.'-]+", options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                            range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func isValidConditions() -> Bool {
    //    ^[QWERTYUIOPLKJHGFDSAZXCVBNMйцукенгшщзхїґєждлорпавіфячсмитьбюыЙЦУКЕНГШЩЗХЇЄЖДЛҐОРПАВИФЯЧСМІТЬБЮЫqwertyuioplkjhgfdsazxcvbnmàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]{1,45}$
    let regex = try! NSRegularExpression(pattern: "^[1234567890QWERTYUIOPLKJHGFDSAZXCVBNMйцукенгшщзхїґєждлорпавіфячсмитьбюыЙЦУКЕНГШЩЗХЇЄЖДЛҐОРПАВИФЯЧСМІТЬБЮЫqwertyuioplkjhgfdsazxcvbnmàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]{1,45}$",
                                         options: [.caseInsensitive])
    
    return regex.firstMatch(in: self.lowercased(), options:[],
                            range: NSMakeRange(0, utf16.count)) != nil
  }
  
  func condenseWhitespace() -> String {
    let components = self.components(separatedBy: CharacterSet.whitespacesAndNewlines)
    return components.filter { !$0.isEmpty }.joined(separator: " ")
  }
  
}

extension UITableViewCell {
  
  func noSelectionNoColorNoAccessoryNoContentView() {
    self.backgroundColor = UIColor.clear
    self.accessoryType  = .none
    self.selectionStyle = UITableViewCellSelectionStyle.none
    self.contentView.backgroundColor = UIColor.clear
    
  }
  
}

extension UIImageView {
  
  func roundCornersAndSetUpWithId(id:String, userObject:JSON = nil) {
    self.layer.masksToBounds = true
    self.layer.cornerRadius  = self.frame.size.width / 2
    if userObject["photo"] != nil {
      CHImages().setImageForFriend(id, imageView: self, userObject: userObject)
    } else {
      CHImages().setUpDefaultImageForFriend(id, imageView: self)
    }
    
  }
  
}

extension Array  {
  
  func adjustFontSizeToFiTWidthForObjects(value:Bool)  {
    
    for x in self {
      let t = x as! UILabel;
      t.adjustsFontSizeToFitWidth = true
    }
    
  }
  
}

extension JSON {
  
  func getElementFromList(key:String, value:String) -> JSON {
    
    for json:JSON in self.arrayValue {
      if json[key].stringValue == value {
        return json
      }
    }
    
    return nil
  }
  
  func userImLookinFor(key:String, value:String) -> JSON {
    let array:[[String:AnyObject]] = self.arrayObject as! [[String:AnyObject]]
    let new = array.filter({
      if let subid = $0[key] {
        return subid as! String == value
      } else {
        return false
      }
    })
    return JSON(dictionaryObject: new[0])
  }
  
  func convertUsersStringToDictionary(text:String) -> [[String:AnyObject]]? {
    if let data = text.data(using: String.Encoding.utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [[String:AnyObject]]
      } catch let error as NSError {
        
      }
    }
    return nil
  }
  
  func getIntByKey(key:String) -> Int {
    if self[key].int != nil {
      return self[key].intValue
    }
    
    return 0
  }
  
  func getStringByKey(key:String) -> String {
    if self[key].string != nil {
      return self[key].stringValue
    }
    
    return ""
  }
  
  func getSummOffElements(keys:[String]) -> Int {
    var result = 0
    for key in keys {
      if self[key].int != nil {
        result += self[key].intValue
      }
    }
    
    
    return result
  }
  
}

extension ScoreBorder {
  
  func rotateScoreBorderOnFriends(scoreLabel:UICountingLabel, in container:UIView, with miniIcon:UIImageView, with value:Int) {
    self.rotateScoreViewToZero()
    self.rotateView(1.0)
    self.animateFromAngle(0, toAngle: 360, duration: 1.0) { (ended) in
      if ended {
        scoreLabel.adjustsFontSizeToFitWidth = true
        scoreLabel.isHidden = false
        self.fillScoreBorder(0.5)
        container.bringSubview(toFront: scoreLabel)
        scoreLabel.method   = UILabelCountingMethodLinear
        scoreLabel.format   = "%d";
        miniIcon.isHidden = false
        scoreLabel.count(from: 0, to: Float(value), withDuration: 0.5)
      }
    }
    
  }
  
}

public enum Model : String {
  case simulator = "simulator/sandbox",
  iPod1          = "iPod 1",
  iPod2          = "iPod 2",
  iPod3          = "iPod 3",
  iPod4          = "iPod 4",
  iPod5          = "iPod 5",
  iPad2          = "iPad 2",
  iPad3          = "iPad 3",
  iPad4          = "iPad 4",
  iPhone4        = "iPhone 4",
  iPhone4S       = "iPhone 4S",
  iPhone5        = "iPhone 5",
  iPhone5S       = "iPhone 5S",
  iPhone5C       = "iPhone 5C",
  iPadMini1      = "iPad Mini 1",
  iPadMini2      = "iPad Mini 2",
  iPadMini3      = "iPad Mini 3",
  iPadAir1       = "iPad Air 1",
  iPadAir2       = "iPad Air 2",
  iPhone6        = "iPhone 6",
  iPhone6plus    = "iPhone 6 Plus",
  iPhone6S       = "iPhone 6S",
  iPhone6Splus   = "iPhone 6S Plus",
  unrecognized   = "?unrecognized?"
}


enum UIUserInterfaceIdiom : Int
{
  case Unspecified
  case Phone
  case Pad
}

struct ScreenSize
{
  static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
  static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
  static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
  static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct DeviceType
{
  static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
  static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
  static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
  static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
  static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

extension Double {
  func toRadians() -> CGFloat {
    return CGFloat(self * .pi / 180.0)
  }
}

extension UIImage {
  
  func fixOrientation(img:UIImage) -> UIImage {
    
    if (img.imageOrientation == UIImageOrientation.up) {
      return img;
    }
    
    UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
    let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
    img.draw(in: rect)
    
    let normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext();
    return normalizedImage;
    
  }
  
  
  func rotated(by degrees: Double) -> UIImage? {
    guard let cgImage = self.cgImage else { return nil }
    
    let transform = CGAffineTransform(rotationAngle: degrees.toRadians())
    var rect = CGRect(origin: .zero, size: self.size).applying(transform)
    rect.origin = .zero
    
    if #available(iOS 10.0, *) {
      let renderer = UIGraphicsImageRenderer(size: rect.size)
      return renderer.image { renderContext in
        renderContext.cgContext.translateBy(x: rect.midX, y: rect.midY)
        renderContext.cgContext.rotate(by: degrees.toRadians())
        renderContext.cgContext.scaleBy(x: 1.0, y: -1.0)
        
        let drawRect = CGRect(origin: CGPoint(x: -self.size.width/2, y: -self.size.height/2), size: self.size)
        renderContext.cgContext.draw(cgImage, in: drawRect)
      }
    } else {
      return self
      // Fallback on earlier versions
    }
    
  }
}
