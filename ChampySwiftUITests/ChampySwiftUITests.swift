//
//  ChampySwiftUITests.swift
//  ChampySwiftUITests
//
//  Created by Molnar Kristian on 4/23/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import XCTest

class ChampySwiftUITests: XCTestCase {
  
  let iterationCount:Int = 30
  
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
  
  func testExample() {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
  }
  
  func testToHistory() {
    let toolbarsQuery = XCUIApplication().toolbars
    
    for var i:Int in 0...iterationCount {
      toolbarsQuery.buttons["clock"].tap()
      toolbarsQuery.buttons["Challenge"].tap()
      
    }
  }
  
  func testToFrinds() {
    let toolbarsQuery = XCUIApplication().toolbars
    
    for var i:Int in 0...iterationCount {
      toolbarsQuery.buttons["friends"].tap()
      toolbarsQuery.buttons["Challenge"].tap()
      
    }
  }
  
  func testToSettings() {
    let toolbarsQuery = XCUIApplication().toolbars
    
    for var i:Int in 0...iterationCount {
      toolbarsQuery.buttons["settings"].tap()
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
    pendingButton.tap()
    champyswiftFriendsviewNavigationBar.buttons["Friends"].tap()
    pendingButton.tap()
    otherButton.tap()
    
    
  }
  
  
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
  
  func testOpenCloseView() {
    
    let button = XCUIApplication().toolbars.containingType(.Button, identifier:"ChallengeActive").childrenMatchingType(.Button).elementBoundByIndex(2)
    button.tap()
    button.tap()
    
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
  
  func testLogInLogOut() {
    
   
    
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
    
    let minusiconButton = app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button).matchingIdentifier("minusicon").elementBoundByIndex(1)
    minusiconButton.tap()
    minusiconButton.tap()
    app.buttons["addIcon"].tap()
    app.buttons["YES"].tap()
    
    let toolbarsQuery = app.toolbars
    toolbarsQuery.buttons["clock"].tap()
    toolbarsQuery.buttons["Challenge"].tap()
    
  }
  
  func testChangeName() {
    
    let app = XCUIApplication()
    app.toolbars.buttons["settings"].tap()
    
    let nameButton = app.tables.buttons["Name"]
    nameButton.tap()
    
    let collectionViewsQuery = app.alerts["Would you like to change your name?"].collectionViews
    collectionViewsQuery.textFields["Enter your name"].tap()
    collectionViewsQuery.textFields["Enter your name"]
    collectionViewsQuery.buttons["Change"].tap()
    nameButton.tap()
    collectionViewsQuery.textFields["Enter your name"]
    
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
  
  
  
  
}
