//
//  ChampySwiftTests.swift
//  ChampySwiftTests
//
//  Created by Molnar Kristian on 4/23/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import Foundation
import XCTest
import SwiftyJSON

@testable import ChampySwift

class ChampySwiftTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testExample() {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measureBlock {
      // Put the code you want to measure the time of here.
    }
  }
  
  func testCreateUser() {
    
    let expectation = expectationWithDescription("Async Method")
    
    let time = CHUIElements().getCurretnTime()
    
    let params:[String:String] = [
      "facebookId": "\(time)",
      "name": "test\(time)",
      "mail": "test\(time)@gmail.com"
    ]
    CHRequests().createUser(params) { (json, status) in
      if status {
        expectation.fulfill()
        XCTAssertTrue(status)
      } else {
        XCTFail("can`t create spot")
      }
    }
    
    waitForExpectationsWithTimeout(5, handler: { error in XCTAssertNil(error, "Oh, we got timeout")
    })
    
  }
  
  func testRemoveAccount() {
    let expectation = expectationWithDescription("Async Method")
    
    let time = CHUIElements().getCurretnTime()
    
    let params:[String:String] = [
      "facebookId": "\(time)",
      "name": "test\(time)",
      "mail": "test\(time)@gmail.com"
    ]
    CHRequests().createUser(params) { (json, status) in
      if status {
        CHRequests().deleteAccount(json["_id"].stringValue, completitionHandler: { (result, json) in
          if result {
            expectation.fulfill()
            XCTAssertTrue(status)
          }else {
            XCTFail("can`t create spot")
          }
        })
      } else {
        XCTFail("can`t create spot")
      }
    }
    
    waitForExpectationsWithTimeout(5, handler: { error in XCTAssertNil(error, "Oh, we got timeout")
    })
  }
  
  func testIsexistActiveSession() {
    let expectation = expectationWithDescription("Async Method")
    
    let time = CHUIElements().getCurretnTime()
    
    let params:[String:String] = [
      "facebookId": "\(time)",
      "name": "test\(time)",
      "mail": "test\(time)@gmail.com"
    ]
    CHRequests().createUser(params) { (json, status) in
      if status {
        if CHSession().currentUserId == json["_id"].stringValue {
          expectation.fulfill()
          XCTAssertTrue(status)
        } else {
          XCTFail("can`t create spot")
        }
      } else {
        XCTFail("can`t create spot")
      }
    }
    
    waitForExpectationsWithTimeout(10, handler: { error in XCTAssertNil(error, "Oh, we got timeout")
    })
  }
  
  func testRelogin() {
    let expectation = expectationWithDescription("Async Method")
    
    let time = CHUIElements().getCurretnTime()
    
    let params:[String:String] = [
      "facebookId": "\(time)",
      "name": "test\(time)",
      "mail": "test\(time)@gmail.com"
    ]
    CHRequests().createUser(params) { (json, status) in
      if status {
        CHRequests().reloginUser(params["facebookId"]!, completitionHandler: { (responseJSON, status) in
          if status {
            expectation.fulfill()
            XCTAssertTrue(status)
          }
        })
      } else {
        XCTFail("can`t create spot")
      }
    }
    
    waitForExpectationsWithTimeout(10, handler: { error in XCTAssertNil(error, "Oh, we got timeout")
    })
  }
  
  func testChangeName() {
    let expectation = expectationWithDescription("Async Method")
    var userObject:JSON! = nil
    
    let time = CHUIElements().getCurretnTime()
    
    let params:[String:String] = [
      "facebookId": "\(time)",
      "name": "test\(time)",
      "mail": "test\(time)@gmail.com"
    ]
    CHRequests().createUser(params) { (json, status) in
      if status {
        let params1:[String:String] = [
          "name": "test2\(time)"
        ]
        CHRequests().updateUserProfile(json["_id"].stringValue, params: params1, completitionHandler: { (result, json) in
          if result {
            expectation.fulfill()
            XCTAssertTrue(status)
          }
        })
      } else {
        XCTFail("can`t create spot")
      }
    }
    
    waitForExpectationsWithTimeout(5, handler: { error in XCTAssertNil(error, "Oh, we got timeout")
    })
  }
  
  func testOptions() {
    let expectation = expectationWithDescription("Async Method")
    var userObject:JSON! = nil
    
    let time = CHUIElements().getCurretnTime()
    
    let params:[String:String] = [
      "facebookId": "\(time)",
      "name": "test\(time)",
      "mail": "test\(time)@gmail.com"
    ]
    CHRequests().createUser(params) { (json, status) in
      if status {
        let params1 = [
          "friendRequests": "false",
          "challengeEnd": "false",
          "acceptedYourChallenge": "false",
          "newChallengeRequests": "false",
          "pushNotifications": "false"
        ]
        
        
        CHRequests().updateUserProfileOptions(json["_id"].stringValue, params: params1) { (result, json) in
          if result {
            expectation.fulfill()
            XCTAssertTrue(status)
          }
        }
      } else {
        XCTFail("can`t create spot")
      }
    }
    
    waitForExpectationsWithTimeout(5, handler: { error in XCTAssertNil(error, "Oh, we got timeout")
    })
  }
  
  func testGetFacebookImageById(){
    let facebookId:String = "\(CHUIElements().getCurretnTime())"
    let image = CHRequests().getFacebookImageById(facebookId)
    if image is UIImage {
      XCTAssert(true)
    } else {
      XCTAssert(false)
    }
    
    
  }
  
}
