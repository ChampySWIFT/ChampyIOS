//
//  CHGradients.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 5/2/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit

class CHGradients: NSObject {
  let firstTopBarColor = UIColor(red: 147.0/255.0, green: 60.0/255.0, blue: 96.0/255.0, alpha: 1.0).cgColor
  let secondTopBarColor = UIColor(red: 243.0/255.0, green: 163.0/255.0, blue: 88.0/255.0, alpha: 1.0).cgColor
  let thirdTopBarColor = UIColor(red: 248.0/255.0, green: 219.0/255.0, blue: 154.0/255.0, alpha: 1.0).cgColor
  
  
  let backgroundGradiend1 = UIColor(red: 50/255.0, green: 153/255.0, blue: 150/255.0, alpha: 1.0).cgColor
  let backgroundGradiend2 = UIColor(red: 55/255.0, green: 50/255.0, blue: 74/255.0, alpha: 1.0).cgColor
  
  func topBarGradient() -> CAGradientLayer {
    let gl: CAGradientLayer
    gl = CAGradientLayer()
    gl.colors = [ firstTopBarColor, secondTopBarColor, thirdTopBarColor]
    gl.locations = [ 0.0, 0.5, 1.0]
    
    return gl
  }

}
