//
//  IJReachability.swift
//  IJReachability
//
//  Created by Isuru Nanayakkara on 1/14/15.
//  Copyright (c) 2015 Appex. All rights reserved.
//

import Foundation
import SystemConfiguration

public enum IJReachabilityType {
  case WWAN,
  WiFi,
  NotConnected
}

public class IJReachability {
  
  
  public class func isConnectedToNetwork() -> Bool {
    var zeroAddress              = sockaddr_in()
    zeroAddress.sin_len          = UInt8(sizeofValue(zeroAddress))
    zeroAddress.sin_family       = sa_family_t(AF_INET)
    let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
      SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
    }
    var flags                    = SCNetworkReachabilityFlags()
    if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
      return false
    }
    let isReachable              = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
    let needsConnection          = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
  
    return (isReachable && !needsConnection)
    
  }
  
  public class func isConnectedToNetworkOfType() -> IJReachabilityType {
    
    return .NotConnected
    
  }
  
}
