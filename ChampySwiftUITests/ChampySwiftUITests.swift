//
//  ChampySwiftUITests.swift
//  ChampySwiftUITests
//
//  Created by Molnar Kristian on 4/23/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import XCTest
import SwiftyJSON
import UIKit

@testable import ChampySwift

class ChampySwiftUITests: XCTestCase {
  
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
  
  func testSelfImprovementWinDoneAndFail() {
    
    
    let app = XCUIApplication()
    app.toolbars.containingType(.Button, identifier:"ChallengeActive").childrenMatchingType(.Button).elementBoundByIndex(2).tap()
    app.buttons["SelfImprovement"].tap()
    app.buttons["addIcon"].tap()
    app.buttons["YES"].tap()
    
    let challengesElementsQuery = app.otherElements.containingType(.NavigationBar, identifier:"Challenges")
    challengesElementsQuery.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).elementBoundByIndex(2).tap()
    challengesElementsQuery.childrenMatchingType(.Other).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).elementBoundByIndex(2).tap()
    
    
  }
  
  func testSelfImprovementWinFail() {
    
    
    let app = XCUIApplication()
    app.toolbars.containingType(.Button, identifier:"ChallengeActive").childrenMatchingType(.Button).elementBoundByIndex(2).tap()
    app.buttons["SelfImprovement"].tap()
    app.buttons["addIcon"].tap()
    app.buttons["YES"].tap()
    app.otherElements.containingType(.NavigationBar, identifier:"Challenges").childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).elementBoundByIndex(2).tap()
    
    
    
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
    app.navigationBars["ChampySwift.FriendsView"].buttons["Other"].tap()
    //    Plus Button
    let cells = app.tables.cells
    sleep(1)
    cells.elementBoundByIndex(0).forceTapElement()
    sleep(2)
    cells.elementBoundByIndex(0).forceTapElement()
  }
  
  func testOpenCloseView() {
    
    let button = XCUIApplication().toolbars.containingType(.Button, identifier:"ChallengeActive").childrenMatchingType(.Button).elementBoundByIndex(2)
    button.tap()
    button.tap()
    
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
    app.toolbars.containingType(.Button, identifier:"ChallengeActive").childrenMatchingType(.Button).elementBoundByIndex(2).tap()
    app.buttons["SelfImprovement"].tap()
    app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).tap()
    app.buttons["addIcon"].tap()
    app.buttons["YES"].tap()
    
    let toolbarsQuery = app.toolbars
    toolbarsQuery.buttons["clock"].tap()
    toolbarsQuery.buttons["Challenge"].tap()
    
  }
  
  func testCreateWakeUp() {
    
    let app = XCUIApplication()
    app.toolbars.containingType(.Button, identifier:"ChallengeActive").childrenMatchingType(.Button).elementBoundByIndex(2).tap()
    app.buttons["Wake up"].tap()
    app.buttons["addIcon"].tap()
    app.buttons["YES"].tap()
    app.buttons["ExitIcon"].tap()
    
  }
  
  func testAdd10Challenges() {
    let app = XCUIApplication()
    for var i:Int in 0...iterationCount {
      app.toolbars.containingType(.Button, identifier:"ChallengeActive").childrenMatchingType(.Button).elementBoundByIndex(2).tap()
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
    
    let champyswiftFriendsviewNavigationBar = app.navigationBars["ChampySwift.FriendsView"]
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
    app.navigationBars["ChampySwift.FriendsView"].buttons["Other"].tap()
    let cells = app.tables.cells
    cells.elementBoundByIndex(0).forceTapElement()
    sleep(2)
    cells.elementBoundByIndex(0).forceTapElement()
    sleep(2)
    //    let button = app.buttons["plusicon"]
    
    //    button.forceTapElement()
  }
  
  func testrefreshFriendsView() {
    let app = XCUIApplication()
    app.toolbars.buttons["friends"].tap()
    let table = app.scrollViews.childrenMatchingType(.Table).element
    
    
    
    let champyswiftFriendsviewNavigationBar = app.navigationBars["ChampySwift.FriendsView"]
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
    app.toolbars.buttons["clock"].tap()
    
    let champyswiftHistoryviewNavigationBar = app.navigationBars["ChampySwift.HistoryView"]
    let winsButton = champyswiftHistoryviewNavigationBar.buttons["Wins"]
    winsButton.tap()
    
    let failedButton = champyswiftHistoryviewNavigationBar.buttons["Failed"]
    failedButton.tap()
    champyswiftHistoryviewNavigationBar.buttons["In progress"].tap()
    winsButton.tap()
    failedButton.tap()
    
    
    
    
  }
  
  func testrefreshHistoryView() {
    
    let app = XCUIApplication()
    app.toolbars.buttons["clock"].tap()
    
    let table = app.scrollViews.childrenMatchingType(.Table).element
    table.swipeDown()
    
    let champyswiftHistoryviewNavigationBar = app.navigationBars["ChampySwift.HistoryView"]
    champyswiftHistoryviewNavigationBar.buttons["Wins"].tap()
    app.tables["Empty list"].tap()
    champyswiftHistoryviewNavigationBar.buttons["Failed"].tap()
    table.swipeDown()
    
  }
  
  func testLogOutLogIn() {
    
  }
  
}

extension XCUIElement {
  
  func forceTapElement() {
    if self.hittable {
      self.tap()
    }
    else {
      let coordinate: XCUICoordinate = self.coordinateWithNormalizedOffset(CGVectorMake(0.0, 0.0))
      coordinate.tap()
    }
  }
}
