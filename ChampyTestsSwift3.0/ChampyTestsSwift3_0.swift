//
//  ChampyTestsSwift3_0.swift
//  ChampyTestsSwift3.0
//
//  Created by Azinec Development on 10/24/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

//
//  ChampySwiftTests.swift
//  ChampySwiftTests
//
//  Created by Molnar Kristian on 7/13/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Champy

class ChampyTestsSwift3_0: XCTestCase {
  var chRequests1:CHRequests! = nil
  var chRequests2:CHRequests! = nil
  var chSessions1:CHSession! = nil
  var chSessions2:CHSession! = nil
  var user1:JSON! = nil
  var user2:JSON! = nil
  var firstToken = ""
  var secondToken = ""
  var firstFacebookId = "1111111111111"
  var secondFacebookId = "2222222222222"
  
  override func setUp() {
    super.setUp()
    self.firstFacebookId = "first\(CHUIElements().getCurretnTime())"
    self.secondFacebookId = "second\(CHUIElements().getCurretnTime())"
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  func testExample() {
    XCTAssert(true)
  }
  //+++++
  func testlogout() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.logout(json["_id"].stringValue, completitionHandler: { (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testCreateUser() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        XCTAssert(true)
      } else {
        XCTAssert(false)
      }
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testupdateUser() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.updateUser(json)
      if status {
        XCTAssert(true)
      } else {
        XCTAssert(false)
      }
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  
  //+++++
  func testDeleteUser() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.chRequests1.deleteAccount(json["_id"].stringValue, completitionHandler: { (result, json) in
          if status {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testAcceptFriendRequest() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        let params2:[String:String] = [
          "facebookId": self.secondFacebookId,
          "name": "sadassecondFacebookIdasda"
        ]
        
        self.chRequests2.createUser(params2, completitionHandler: { (json, status) in
          self.chRequests2.getTokenForTests()
          if status {
            self.user2 = json
            //            self.secondToken = CHSession().getTokenWithFaceBookId(self.secondFacebookId)
            
            self.chRequests2.sendFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
              if status {
                self.chRequests1.acceptFriendRequest(self.user1["_id"].stringValue, friendId: self.user2["_id"].stringValue, completitionHandler: { (result, json) in
                  if status {
                    XCTAssert(true)
                  } else {
                    XCTAssert(false)
                  }
                  expectation.fulfill()
                })
              }
            })
            
          }
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testDeclineFriendRequest() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        let params2:[String:String] = [
          "facebookId": self.secondFacebookId,
          "name": "sadassecondFacebookIdasda"
        ]
        
        self.chRequests2.createUser(params2, completitionHandler: { (json, status) in
          self.chRequests2.getTokenForTests()
          if status {
            self.user2 = json
            //            self.secondToken = CHSession().getTokenWithFaceBookId(self.secondFacebookId)
            
            self.chRequests2.sendFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
              if status {
                self.chRequests1.removeFriendRequest(self.user1["_id"].stringValue, friendId: self.user2["_id"].stringValue, completitionHandler: { (result, json) in
                  if status {
                    XCTAssert(true)
                  } else {
                    XCTAssert(false)
                  }
                  expectation.fulfill()
                })
              }
            })
            
          }
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testCancleFriendRequest() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        let params2:[String:String] = [
          "facebookId": self.secondFacebookId,
          "name": "sadassecondFacebookIdasda"
        ]
        
        self.chRequests2.createUser(params2, completitionHandler: { (json, status) in
          self.chRequests2.getTokenForTests()
          if status {
            self.user2 = json
            //            self.secondToken = CHSession().getTokenWithFaceBookId(self.secondFacebookId)
            
            self.chRequests2.sendFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
              if status {
                self.chRequests2.removeFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
                  if status {
                    XCTAssert(true)
                  } else {
                    XCTAssert(false)
                  }
                  expectation.fulfill()
                })
              }
            })
            
          }
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testAddFriend() {
    
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    
    CHRequests().createUser(params1) { (json, status) in
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        let params2:[String:String] = [
          "facebookId": self.secondFacebookId,
          "name": "sadassecondFacebookIdasda"
        ]
        
        CHRequests().createUser(params2, completitionHandler: { (json, status) in
          if status {
            self.user2 = json
            self.secondToken = CHSession().getTokenWithFaceBookId(self.secondFacebookId)
            
            CHRequests().sendFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
              if status {
                XCTAssert(true)
              } else {
                XCTAssert(false)
              }
              expectation.fulfill()
            })
            
          }
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
    
  }
  
  //+++++
  func testreloginUser() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    
    CHRequests().createUser(params1) { (json, status) in
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        CHRequests().reloginUser(self.firstFacebookId, completitionHandler: { (responseJSON, status) in
          if status {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
        
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testcheckUserTrue() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    
    CHRequests().createUser(params1) { (json, status) in
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        
        CHRequests().checkUser(self.user1["_id"].stringValue, completitionHandler: { (json, status) in
          if status {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
        
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testcheckUserFalse() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    
    CHRequests().createUser(params1) { (json, status) in
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        
        CHRequests().checkUser("\(self.user1["_id"].stringValue)sad", completitionHandler: { (json, status) in
          if !status {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
        
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testgetAllUsers() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.getAllUsers({ (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testgetFacebookImageById() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if self.chRequests1.getFacebookImageById(self.firstFacebookId) is UIImage {
        XCTAssert(true)
      } else {
        XCTAssert(false)
      }
      expectation.fulfill()
      
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testgetFriends() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.getFriends(json["_id"].stringValue, completitionHandler: { (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
      
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testgetChallenges() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.getChallenges(json["_id"].stringValue, completitionHandler: { (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
      
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testretrieveAllInProgressChallenges() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.retrieveAllInProgressChallenges(json["_id"].stringValue, completitionHandler: { (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
      
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testupdateUserFromRemote() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.updateUserFromRemote({ (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
      
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  
  //+++++
  
  func testcreateChallengeAndSendItToaStranger() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        let params2:[String:String] = [
          "facebookId": self.secondFacebookId,
          "name": "sadassecondFacebookIdasda"
        ]
        
        self.chRequests2.createUser(params2, completitionHandler: { (json, status) in
          self.chRequests2.getTokenForTests()
          if status {
            self.user2 = json
            
            self.chRequests1.sendFriendRequest(self.user1["_id"].stringValue, friendId: self.user2["_id"].stringValue, completitionHandler: { (result, json) in
              if status {
                self.chRequests2.acceptFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
                  //////print(json)
                  
                  let params:[String:String] = [
                    "name": "name",
                    "type": CHSettings().self.duelsId,
                    "description": "desc",
                    "details": "details",
                    "duration": "\(CHSettings().daysToSec(21))"
                  ]
                  
                  self.chRequests1.createChallengeAndSendIt(self.user2["_id"].stringValue, params: params, completitionHandler: { (json, status) in
                    //////print(json)
                    //////print(status)
                    if status {
                      XCTAssert(true)
                    } else {
                      XCTAssert(false)
                    }
                    expectation.fulfill()
                  })
                })
              }
            })
            
          }
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testuploadUsersPhoto() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.chRequests1.uploadUsersPhoto(json["_id"].stringValue, image: UIImage(named: "center")!, completitionHandler: { (result, json) in
          //////print(json)
          if result {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
      }
      
      
    }
    
    waitForExpectations(timeout: 20) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testupdateUserProfile() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        
        self.chRequests1.updateUserProfile(json["_id"].stringValue, params: ["name": "username1"], completitionHandler: { (result, json) in
          if status {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
      }
      
      
    }
    
    waitForExpectations(timeout: 20) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testupdateUserProfileOptions() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    expectation.fulfill()
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testcreateDuelInProgressChallenge() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    expectation.fulfill()
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testcreateSingleInProgressChallenge() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    
    
    expectation.fulfill()
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testcreateSelfImprovementChallengeAndSendIt() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    expectation.fulfill()
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testjoinToChallenge() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    expectation.fulfill()
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testrejectInvite() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    expectation.fulfill()
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testsurrender() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    expectation.fulfill()
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testcheckChallenge() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    expectation.fulfill()
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  // mark: Unauthorized person
  
  func testExampleUA() {
    XCTAssert(true)
  }
  //+++++
  func testlogoutUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.logout(json["_id"].stringValue, completitionHandler: { (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testCreateUserUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        XCTAssert(true)
      } else {
        XCTAssert(false)
      }
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testupdateUserUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.updateUser(json)
      if status {
        XCTAssert(true)
      } else {
        XCTAssert(false)
      }
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  
  //+++++
  func testDeleteUserUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.chRequests1.deleteAccount(json["_id"].stringValue, completitionHandler: { (result, json) in
          if status {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testAcceptFriendRequestUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        let params2:[String:String] = [
          "facebookId": self.secondFacebookId,
          "name": "sadassecondFacebookIdasda"
        ]
        
        self.chRequests2.createUser(params2, completitionHandler: { (json, status) in
          self.chRequests2.getTokenForTests()
          if status {
            self.user2 = json
            //            self.secondToken = CHSession().getTokenWithFaceBookId(self.secondFacebookId)
            
            self.chRequests2.sendFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
              if status {
                self.chRequests1.acceptFriendRequest(self.user1["_id"].stringValue, friendId: self.user2["_id"].stringValue, completitionHandler: { (result, json) in
                  if status {
                    XCTAssert(true)
                  } else {
                    XCTAssert(false)
                  }
                  expectation.fulfill()
                })
              }
            })
            
          }
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testDeclineFriendRequestUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        let params2:[String:String] = [
          "facebookId": self.secondFacebookId,
          "name": "sadassecondFacebookIdasda"
        ]
        
        self.chRequests2.createUser(params2, completitionHandler: { (json, status) in
          self.chRequests2.getTokenForTests()
          if status {
            self.user2 = json
            //            self.secondToken = CHSession().getTokenWithFaceBookId(self.secondFacebookId)
            
            self.chRequests2.sendFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
              if status {
                self.chRequests1.removeFriendRequest(self.user1["_id"].stringValue, friendId: self.user2["_id"].stringValue, completitionHandler: { (result, json) in
                  if status {
                    XCTAssert(true)
                  } else {
                    XCTAssert(false)
                  }
                  expectation.fulfill()
                })
              }
            })
            
          }
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testCancleFriendRequestUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        let params2:[String:String] = [
          "facebookId": self.secondFacebookId,
          "name": "sadassecondFacebookIdasda"
        ]
        
        self.chRequests2.createUser(params2, completitionHandler: { (json, status) in
          self.chRequests2.getTokenForTests()
          if status {
            self.user2 = json
            //            self.secondToken = CHSession().getTokenWithFaceBookId(self.secondFacebookId)
            
            self.chRequests2.sendFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
              if status {
                self.chRequests2.removeFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
                  if status {
                    XCTAssert(true)
                  } else {
                    XCTAssert(false)
                  }
                  expectation.fulfill()
                })
              }
            })
            
          }
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testAddFriendUA() {
    
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    
    CHRequests().createUser(params1) { (json, status) in
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        let params2:[String:String] = [
          "facebookId": self.secondFacebookId,
          "name": "sadassecondFacebookIdasda"
        ]
        
        CHRequests().createUser(params2, completitionHandler: { (json, status) in
          if status {
            self.user2 = json
            self.secondToken = CHSession().getTokenWithFaceBookId(self.secondFacebookId)
            
            CHRequests().sendFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
              if status {
                XCTAssert(true)
              } else {
                XCTAssert(false)
              }
              expectation.fulfill()
            })
            
          }
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
    
  }
  
  //+++++
  func testreloginUserUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    
    CHRequests().createUser(params1) { (json, status) in
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        CHRequests().reloginUser(self.firstFacebookId, completitionHandler: { (responseJSON, status) in
          if status {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
        
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testcheckUserTrueUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    
    CHRequests().createUser(params1) { (json, status) in
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        
        CHRequests().checkUser(self.user1["_id"].stringValue, completitionHandler: { (json, status) in
          if status {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
        
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testcheckUserFalseUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    
    CHRequests().createUser(params1) { (json, status) in
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        
        CHRequests().checkUser("\(self.user1["_id"].stringValue)sad", completitionHandler: { (json, status) in
          if !status {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
        
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testgetAllUsersUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.getAllUsers({ (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testgetFacebookImageByIdUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if self.chRequests1.getFacebookImageById(self.firstFacebookId) is UIImage {
        XCTAssert(true)
      } else {
        XCTAssert(false)
      }
      expectation.fulfill()
      
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testgetFriendsUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.getFriends(json["_id"].stringValue, completitionHandler: { (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
      
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testgetChallengesUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.getChallenges(json["_id"].stringValue, completitionHandler: { (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
      
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testretrieveAllInProgressChallengesUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.retrieveAllInProgressChallenges(json["_id"].stringValue, completitionHandler: { (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
      
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  //+++++
  func testupdateUserFromRemoteUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      self.chRequests1.updateUserFromRemote({ (result, json) in
        if status {
          XCTAssert(true)
        } else {
          XCTAssert(false)
        }
        expectation.fulfill()
      })
      
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  
  //+++++
  
  func testcreateChallengeAndSendItToaStrangerUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        self.user1 = json
        self.firstToken = CHSession().getTokenWithFaceBookId(self.firstFacebookId)
        let params2:[String:String] = [
          "facebookId": self.secondFacebookId,
          "name": "sadassecondFacebookIdasda"
        ]
        
        self.chRequests2.createUser(params2, completitionHandler: { (json, status) in
          self.chRequests2.getTokenForTests()
          if status {
            self.user2 = json
            
            self.chRequests1.sendFriendRequest(self.user1["_id"].stringValue, friendId: self.user2["_id"].stringValue, completitionHandler: { (result, json) in
              if status {
                self.chRequests2.acceptFriendRequest(self.user2["_id"].stringValue, friendId: self.user1["_id"].stringValue, completitionHandler: { (result, json) in
                  //////print(json)
                  
                  let params:[String:String] = [
                    "name": "name",
                    "type": CHSettings().self.duelsId,
                    "description": "desc",
                    "details": "details",
                    "duration": "\(CHSettings().daysToSec(21))"
                  ]
                  
                  self.chRequests1.createChallengeAndSendIt(self.user2["_id"].stringValue, params: params, completitionHandler: { (json, status) in
                    //////print(json)
                    if status {
                      XCTAssert(true)
                    } else {
                      XCTAssert(false)
                    }
                    expectation.fulfill()
                  })
                })
              }
            })
            
          }
        })
      }
    }
    
    waitForExpectations(timeout: 10) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  func testuploadUsersPhotoUA() {
    let expectation = self.expectation(description: "SendFriendRequest")
    
    let params1:[String:String] = [
      "facebookId": self.firstFacebookId,
      "name": "sadasfirstFacebookIdasda"
    ]
    
    self.chRequests1 = CHRequests()
    self.chRequests2 = CHRequests()
    self.chSessions1 = CHSession()
    self.chSessions2 = CHSession()
    
    self.chRequests1.createUser(params1) { (json, status) in
      self.chRequests1.getTokenForTests()
      if status {
        sleep(2)
        self.chRequests1.uploadUsersPhoto(json["_id"].stringValue, image: UIImage(named: "center")!, completitionHandler: { (result, json) in
          //////print(json)
          if result {
            XCTAssert(true)
          } else {
            XCTAssert(false)
          }
          expectation.fulfill()
        })
      }
      
      
    }
    
    waitForExpectations(timeout: 20) { error in
      if let error = error {
        //////////print("Error: \(error.localizedDescription)")
      }
    }
  }
  
  
}


