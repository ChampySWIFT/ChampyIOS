//
//  ChampyUITests3_0.swift
//  ChampyUITests3.0
//
//  Created by Azinec Development on 10/24/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import XCTest
import SwiftyJSON
import UIKit

@testable import Champy

class ChampyUITests3_0: XCTestCase {
  
  let iterationCount:Int = 1
  
  override func setUp() {
    super.setUp()
    
    
    continueAfterFailure = false
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    XCUIApplication().launch()
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
  }
  
  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }
  
  // MARK: - other tests
  
  func testSelfImprovementDone() {
    
    
    let app = XCUIApplication()
    let centerImage = app.images["center"]
    centerImage.tap()
    app.buttons["SelfImprovement"].tap()
    app.buttons["addIcon"].tap()
    app.buttons["YES"].tap()
    
    app.otherElements.containing(.navigationBar, identifier:"Challenges").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 2).tap()
    
    
    
    
  }
  
  func testSelfImprovementWinFail() {
    
    
    let app = XCUIApplication()
    let centerImage = app.images["center"]
    centerImage.tap()
    app.buttons["SelfImprovement"].tap()
    app.buttons["addIcon"].tap()
    app.buttons["YES"].tap()
    app.otherElements.containing(.navigationBar, identifier:"Challenges").children(matching: .other).element.children(matching: .other).element.children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .other).element(boundBy: 2).tap()
    
    
    
  }
  
  func testToHistory() {
    let toolbarsQuery = XCUIApplication().toolbars
    
    for var i:Int in 0...iterationCount {
      toolbarsQuery.buttons["clock"].tap()
      toolbarsQuery.buttons["Challenge"].tap()
      
    }
  }
  
  func testTriggeringCell() {
    
    let app = XCUIApplication()
    app.toolbars.buttons["friends"].tap()
    app.navigationBars["Champy.FriendsView"].buttons["Other"].tap()
    //    Plus Button
    let cells = app.tables.cells
    sleep(1)
    cells.element(boundBy: 0).forceTapElement()
    sleep(2)
    cells.element(boundBy: 0).forceTapElement()
  }
  
  func testOpenCloseView() {
    
    let app = XCUIApplication()
    let centerImage = app.images["center"]
    centerImage.tap()
    centerImage.tap()
    
    
  }
  
  func testSelfImprovement() {
    
  }
  
  func testRedirects() {
    
    let toolbarsQuery = XCUIApplication().toolbars
    
    for var i:Int in 0...iterationCount {
      toolbarsQuery.buttons["clock"].tap()
      toolbarsQuery.buttons["friends"].tap()
      toolbarsQuery.buttons["settings"].tap()
      toolbarsQuery.buttons["Challenge"].tap()
      
    }
    
  }
  
  func testCreateChallenge() {
    
    let app = XCUIApplication()
    let centerImage = app.images["center"]
    centerImage.tap()
    app.buttons["SelfImprovement"].tap()
    app.buttons["addIcon"].tap()
    app.buttons["YES"].tap()
    
    
  }
  
  func testCreateWakeUp() {
    
    let app = XCUIApplication()
    let centerImage = app.images["center"]
    centerImage.tap()
    
    app.buttons["Wake up"].tap()
    app.buttons["addIcon"].tap()
    app.buttons["YES"].tap()
    app.buttons["ExitIcon"].tap()
    
  }
  
  func testAdd10Challenges() {
    let app = XCUIApplication()
    let centerImage = app.images["center"]
    for var i:Int in 0...iterationCount {
      centerImage.tap()
      app.buttons["SelfImprovement"].tap()
      app.buttons["addIcon"].tap()
      app.buttons["YES"].tap()
    }
  }
  
  // MARK: - Settings tests
  
  func testSettingsOptions() {
    
    let app = XCUIApplication()
    app.toolbars.buttons["settings"].tap()
    
    let tablesQuery = app.tables
    let table = tablesQuery.element
    table.swipeUp()
    
    let friendRequestsSwitch = tablesQuery.switches["Friend Requests"]
    friendRequestsSwitch.tap()
    friendRequestsSwitch.tap()
    
    let challengeEndSwitch = tablesQuery.switches["Challenge End"]
    challengeEndSwitch.tap()
    challengeEndSwitch.tap()
    
    let acceptedYourChallengeSwitch = tablesQuery.switches["Accepted Your Challenge"]
    acceptedYourChallengeSwitch.tap()
    acceptedYourChallengeSwitch.tap()
    
  }
  
  func testEndUserAgreement() {
    
    let app = XCUIApplication()
    app.toolbars.buttons["settings"].tap()
    
    let tablesQuery = app.tables
    let table = tablesQuery.element
    table.swipeUp()
    tablesQuery.buttons["End User Agreement"].tap()
    //    XCUIApplication().statusBars.buttons["Back to ChampySwift"].tap()
    //    XCUIDevice.sharedDevice().orientation = .Portrait
    
    
  }
  
  func testPrivacy() {
    
    let app = XCUIApplication()
    app.toolbars.buttons["settings"].tap()
    
    let tablesQuery = app.tables
    let table = tablesQuery.element
    table.swipeUp()
    tablesQuery.buttons["Privacy Policy"].tap()
    //    let backToChampyswiftButton = app.statusBars.buttons["Back to ChampySwift"]
    //    backToChampyswiftButton.tap()
    
  }
  
  func testAbout() {
    
    let app = XCUIApplication()
    app.toolbars.buttons["settings"].tap()
    
    let tablesQuery = app.tables
    let table = tablesQuery.element
    table.swipeUp()
    //    let backToChampyswiftButton = app.statusBars.buttons["Back to ChampySwift"]
    tablesQuery.buttons["About"].tap()
    //    backToChampyswiftButton.tap()
    
  }
  
  func testToSettings() {
    let toolbarsQuery = XCUIApplication().toolbars
    
    for var i:Int in 0...iterationCount {
      toolbarsQuery.buttons["settings"].tap()
      toolbarsQuery.buttons["Challenge"].tap()
      
    }
  }
  
  func testChangeName() {
    
    let app = XCUIApplication()
    app.toolbars.buttons["settings"].tap()
    app.tables.buttons["Name"].tap()
    app.alerts["Would you like to change your name?"].collectionViews.textFields["Enter your name"]
    
    
    
  }
  
  
  // MARK: - Friends tests
  
  func testToFrinds() {
    let toolbarsQuery = XCUIApplication().toolbars
    
    for var i:Int in 0...iterationCount {
      toolbarsQuery.buttons["friends"].tap()
      toolbarsQuery.buttons["Challenge"].tap()
      
    }
  }
  
  func testFriendsScreenSwitcing() {
    
    
    let app = XCUIApplication()
    app.toolbars.buttons["friends"].tap()
    
    let champyswiftFriendsviewNavigationBar = app.navigationBars["Champy.FriendsView"]
    let pendingButton = champyswiftFriendsviewNavigationBar.buttons["Pending"]
    pendingButton.tap()
    
    let otherButton = champyswiftFriendsviewNavigationBar.buttons["Other"]
    otherButton.tap()
    
    //    app.tables.cells.
    
    pendingButton.tap()
    champyswiftFriendsviewNavigationBar.buttons["Friends"].tap()
    pendingButton.tap()
    otherButton.tap()
    
    
  }
  
  func testaddFriend() {
    let app = XCUIApplication()
    app.toolbars.buttons["friends"].tap()
    app.navigationBars["Champy.FriendsView"].buttons["Other"].tap()
    let cells = app.tables.cells
    cells.element(boundBy: 0).forceTapElement()
    sleep(2)
    cells.element(boundBy: 0).forceTapElement()
    sleep(2)
    //    let button = app.buttons["plusicon"]
    
    //    button.forceTapElement()
  }
  
  func testrefreshFriendsView() {
    let app = XCUIApplication()
    app.toolbars.buttons["friends"].tap()
    let table = app.scrollViews.children(matching: .table).element
    
    
    
    let champyswiftFriendsviewNavigationBar = app.navigationBars["Champy.FriendsView"]
    champyswiftFriendsviewNavigationBar.buttons["Pending"].tap()
    table.swipeDown()
    champyswiftFriendsviewNavigationBar.buttons["Other"].tap()
    table.swipeDown()
    champyswiftFriendsviewNavigationBar.buttons["Friends"].tap()
    table.swipeDown()
    
  }
  
  
  // MARK: - History tests
  
  func testHistoryScreenSwitcing() {
    
    
    let app = XCUIApplication()
    let toolbarsQuery = app.toolbars
    toolbarsQuery.buttons["clock"].tap()
    
    let champyHistoryviewNavigationBar = app.navigationBars["Champy.HistoryView"]
    let winsButton = champyHistoryviewNavigationBar.buttons["Wins"]
    winsButton.tap()
    
    let failedButton = champyHistoryviewNavigationBar.buttons["Failed"]
    failedButton.tap()
    winsButton.tap()
    champyHistoryviewNavigationBar.buttons["In progress"].tap()
    winsButton.tap()
    failedButton.tap()
    toolbarsQuery.buttons["Challenge"].tap()
    
    
    
    
    
    
  }
  
  func testrefreshHistoryView() {
    
    
    let app = XCUIApplication()
    let toolbarsQuery = app.toolbars
    toolbarsQuery.buttons["clock"].tap()
    
    let emptyListTable = app.tables["Empty list"]
    emptyListTable.swipeRight()
    
    let champyHistoryviewNavigationBar = app.navigationBars["Champy.HistoryView"]
    champyHistoryviewNavigationBar.buttons["Wins"].tap()
    emptyListTable.tap()
    champyHistoryviewNavigationBar.buttons["Failed"].tap()
    emptyListTable.tap()
    toolbarsQuery.buttons["Challenge"].tap()
    
    
  }
  
  func testLogOutLogIn() {
    
  }
  
}

extension XCUIElement {
  
  func forceTapElement() {
    if self.isHittable {
      self.tap()
    }
    else {
      let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
      coordinate.tap()
    }
  }
}

