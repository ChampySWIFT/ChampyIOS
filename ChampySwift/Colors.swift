//
//  Colors.swift
//  Champy
//
//  Created by Azinec Development on 4/6/17.
//  Copyright © 2017 AzinecLLC. All rights reserved.
//

import UIKit



class Colors {
  var gl:CAGradientLayer!
  
  var friendColors:[String:[String: UIColor]] = [
    "color1":["topColor": UIColor(hexString: "#FF5E3A")!, "bottomColor": UIColor(hexString: "#FF2A68")!],
    "color2":["topColor": UIColor(hexString: "#87FC70")!, "bottomColor": UIColor(hexString: "#0BD318")!],
    "color3":["topColor": UIColor(hexString: "#FFDB4C")!, "bottomColor": UIColor(hexString: "#FFCD02")!],
    "color4":["topColor": UIColor(hexString: "#FF9500")!, "bottomColor": UIColor(hexString: "#FF5E3A")!],
    "color5":["topColor": UIColor(hexString: "#52EDC7")!, "bottomColor": UIColor(hexString: "#5AC8FB")!],
    "color6":["topColor": UIColor(hexString: "#1AD6FD")!, "bottomColor": UIColor(hexString: "#1D62F0")!],
    "color7":["topColor": UIColor(hexString: "#C644FC")!, "bottomColor": UIColor(hexString: "#5856D6")!],
    "color8":["topColor": UIColor(hexString: "#EF4DB6")!, "bottomColor": UIColor(hexString: "#4A4A4A")!]
  ]
  
  var friendColors2:[String:[String: UIColor]] = [
    "color1":[
      "topColor": UIColor(colorLiteralRed: 255/255.0, green: 94/255.0, blue: 58/255.0, alpha: 1.0),
      "bottomColor": UIColor(colorLiteralRed: 255/255.0, green: 42/255.0, blue: 104/255.0, alpha: 1.0)],
    
    "color2":[
      "topColor": UIColor(colorLiteralRed: 255/255.0, green: 149/255.0, blue: 0/255.0, alpha: 1.0),
      "bottomColor": UIColor(colorLiteralRed: 255/255.0, green: 94/255.0, blue: 58/255.0, alpha: 1.0)],
    
    "color3":[
      "topColor": UIColor(colorLiteralRed: 255/255.0, green: 219/255.0, blue: 76/255.0, alpha: 1.0),
      "bottomColor": UIColor(colorLiteralRed: 255/255.0, green: 205/255.0, blue: 2/255.0, alpha: 1.0)],
    
    "color4":[
      "topColor": UIColor(colorLiteralRed: 135/255.0, green: 252/255.0, blue: 112/255.0, alpha: 1.0),
      "bottomColor": UIColor(colorLiteralRed: 11/255.0, green: 211/255.0, blue: 24/255.0, alpha: 1.0)],
    
    "color5":[
      "topColor": UIColor(colorLiteralRed: 82/255.0, green: 237/255.0, blue: 199/255.0, alpha: 1.0),
      "bottomColor": UIColor(colorLiteralRed: 90/255.0, green: 200/255.0, blue: 251/255.0, alpha: 1.0)],
    
    "color6":[
      "topColor": UIColor(colorLiteralRed: 26/255.0, green: 214/255.0, blue: 253/255.0, alpha: 1.0),
      "bottomColor": UIColor(colorLiteralRed: 29/255.0, green: 98/255.0, blue: 240/255.0, alpha: 1.0)],
    
    "color7":[
      "topColor": UIColor(colorLiteralRed: 198/255.0, green: 68/255.0, blue: 252/255.0, alpha: 1.0),
      "bottomColor": UIColor(colorLiteralRed: 88/255.0, green: 86/255.0, blue: 214/255.0, alpha: 1.0)],
    
    "color8":[
      "topColor": UIColor(colorLiteralRed: 239/255.0, green: 77/255.0, blue: 182/255.0, alpha: 1.0),
      "bottomColor": UIColor(colorLiteralRed: 197/255.0, green: 67/255.0, blue: 252/255.0, alpha: 1.0)]
  ]
  
  static var labelColors : [String:UIColor] = [
    "color1": UIColor(colorLiteralRed: 255/255.0, green: 94/255.0, blue: 58/255.0, alpha: 1.0),
    "color2": UIColor(colorLiteralRed: 255/255.0, green: 149/255.0, blue: 0/255.0, alpha: 1.0),
    "color3": UIColor(colorLiteralRed: 255/255.0, green: 219/255.0, blue: 76/255.0, alpha: 1.0),
    "color4": UIColor(colorLiteralRed: 135/255.0, green: 252/255.0, blue: 112/255.0, alpha: 1.0),
    "color5": UIColor(colorLiteralRed: 82/255.0, green: 237/255.0, blue: 199/255.0, alpha: 1.0),
    "color6": UIColor(colorLiteralRed: 26/255.0, green: 214/255.0, blue: 253/255.0, alpha: 1.0),
    "color7": UIColor(colorLiteralRed: 198/255.0, green: 68/255.0, blue: 252/255.0, alpha: 1.0),
    "color8": UIColor(colorLiteralRed: 239/255.0, green: 77/255.0, blue: 182/255.0, alpha: 1.0),
  ]
  
  init(colorId:String) {
    let colorTop = friendColors2[colorId]?["topColor"]?.cgColor
    let colorBottom = friendColors2[colorId]?["bottomColor"]?.cgColor
    
    self.gl = CAGradientLayer()
    self.gl.colors = [colorTop, colorBottom]
    self.gl.locations = [0.0, 1.0]
  }
  
  func refresh(view:UIView, colorId:Int, width:CGFloat = 0.0) {
    let colors = Colors(colorId: "color\(colorId)")
    view.backgroundColor = UIColor.clear
    let backgroundLayer = colors.gl
    backgroundLayer?.frame = CGRect(x: 0.0, y: 0.0, width: width, height: view.frame.height)
    backgroundLayer?.masksToBounds = true
    backgroundLayer?.cornerRadius = 10.0
    view.layer.insertSublayer(backgroundLayer!, at: 0)
  }
  
}



extension UIColor {
  public convenience init?(hexString: String) {
    let r, g, b, a: CGFloat
    
    if hexString.hasPrefix("#") {
      let start = hexString.index(hexString.startIndex, offsetBy: 1)
      let hexColor = hexString.substring(from: start)
      
      if hexColor.characters.count == 6 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
          g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
          b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
//          a = CGFloat(hexNumber & 0x000000ff) / 255
          
          self.init(red: r, green: g, blue: b, alpha: 1)
          return
        }
      }
    }
    
    return nil
  }
}
