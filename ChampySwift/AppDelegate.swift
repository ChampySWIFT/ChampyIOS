//
//  AppDelegate.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/23/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import CoreData
import Parse
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var CurrentUser:NSUserDefaults = NSUserDefaults.standardUserDefaults()
  
  var window: UIWindow?
  var mainView:UIView! = nil
  var subscribed:Bool = false
  var historyViewController: HistoryViewController!   = nil
  var friendsViewController: FriendsViewController!   = nil
  var settingsViewController: SettingsViewController! = nil
  var mainViewController: MainViewController!         = nil
  
  var table3:AllFriendsTableViewController! = nil
  var table2:PendingFriendsController! = nil
  var table1:FriendsTableViewController! = nil
  
  
  var historyTable1:InProgressTableViewController! = nil
  var historyTable2:WinsTableViewController! = nil
  var historyTable3:FailedTableViewController! = nil
  
  var mainViewCard:[String:UIView] = [:]
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                   fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    //print("Message ID: \(userInfo["gcm.message_id"]!)")
    
    // Print full message.
    //print("%@", userInfo)
  }
  
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    // Override point for customization after application launch.
    FIRApp.configure()
    if #available(iOS 8.0, *) {
      // [START register_for_notifications]
      let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
      application.registerUserNotificationSettings(settings)
      application.registerForRemoteNotifications()
      // [END register_for_notifications]
    } else {
      // Fallback
      let types: UIRemoteNotificationType = [.Alert, .Badge, .Sound]
      application.registerForRemoteNotificationTypes(types)
    }
    
    
    // Add observer for InstanceID token refresh callback.
    NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.tokenRefreshNotification),
                                                     name: kFIRInstanceIDTokenRefreshNotification, object: nil)
    //    FIRApp.configure()
    //    if application.applicationState != UIApplicationState.Background {
    //      
    //      let preBackgroundPush  = !application.respondsToSelector("backgroundRefreshStatus")
    //      let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
    //      var pushPayload        = false
    //      if let options         = launchOptions {
    //        pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
    //      }
    //      if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
    //        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
    //      }
    //    }
    //    if application.respondsToSelector("registerUserNotificationSettings:") {
    //      
    //      
    //      let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Badge, UIUserNotificationType.Alert, UIUserNotificationType.Sound]
    //      let settings              = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
    //      application.registerUserNotificationSettings(settings)
    //      application.registerForRemoteNotifications()
    //    } else {
    //      let types: UIRemoteNotificationType = [.Badge, .Alert, .Sound]
    //      application.registerForRemoteNotificationTypes(types)
    //    }
    
    
    //    Parse.setApplicationId("aSCb7zJ3X1UAItiXYuse6SPjdTKVbviyjUT6fuLp", clientKey: "JlK8LZH3ctKr8weIZ5JCf5is0oaqHK0UdgmMPdEt")
    //    CHPush().clearBadgeNumber()
    return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
  func tokenRefreshNotification(notification: NSNotification) {
    if let refreshedToken = FIRInstanceID.instanceID().token() {
      //print("InstanceID token: \(refreshedToken)")
      let params = [
        "APNIdentifier" : refreshedToken //deviceToken.description as String
      ]
      
      CHRequests().updateUserProfile(CHSession().currentUserId, params: params) { (result, json) in
        if result {
          //print("success")
        }
      }
    }
    
    // Connect to FCM since connection may have failed when attempted before having a token.
    connectToFcm()
  }
  
  // [START connect_to_fcm]
  func connectToFcm() {
    FIRMessaging.messaging().connectWithCompletion { (error) in
      if (error != nil) {
        //print("Unable to connect with FCM. \(error)")
      } else {
        //print("Connected to FCM.")
      }
    }
  }
  // [END connect_to_fcm]
  
  
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    let formatedDeviceToken:String = self.getSimpleDeviceToken("\(deviceToken)")
    CurrentUser.setObject(deviceToken, forKey: "deviceToken")
    CurrentUser.setObject(formatedDeviceToken, forKey: "deviceTokenString")
    
    if CHSession().logined {
      CHPush().subscribeUserTo(CHSession().currentUserId)
    } else {
      CHPush().subscribeUserTo(formatedDeviceToken)
    }
    
    CHPush().subscribeForNotifications()
    
    
    
  }
  
  func getSimpleDeviceToken(deviceToken:String)->String{
    var token:String = deviceToken.stringByReplacingOccurrencesOfString(" ", withString: "")
    token = token.stringByReplacingOccurrencesOfString("<", withString: "")
    token = token.stringByReplacingOccurrencesOfString(">", withString: "")
    return token
  }
  
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    print(error)
  }
  
  //  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
  //    <#code#>
  //  }
  
  //  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
  //    
  //    let characterSet: NSCharacterSet = NSCharacterSet(charactersInString: "<>")
  //    
  //    let deviceTokenString: String = (deviceToken.description as NSString)
  //      .stringByTrimmingCharactersInSet(characterSet)
  //      .stringByReplacingOccurrencesOfString( " ", withString: "") as String
  //    
  //    let params = [
  //      "APNIdentifier" : deviceTokenString//deviceToken.description as String
  //    ]
  //    
  //    CHRequests().updateUserProfile(CHSession().currentUserId, params: params) { (result, json) in
  //      if result {
  //        //print("success")
  //      }
  //    }
  //  }
  
  func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
    if notification.userInfo != nil {
      let data = notification.userInfo as! [String:String]
      
      if data["type"] == "WakeUp" {
        CHBanners().setTimeout(3.0, block: {
          CHPush().localPush("refreshIcarousel", object: [])
        })
        
      }
    }
    
  }
  
  
  
  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(application: UIApplication) {
    FIRMessaging.messaging().disconnect()
    //print("Disconnected from FCM.")
    CHWakeUpper().setUpWakeUp()
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(application: UIApplication) {
    CHPush().localPush("refreshIcarousel", object: [])
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(application: UIApplication) {
    connectToFcm()
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }
  
  // MARK: - Core Data stack
  
  lazy var applicationDocumentsDirectory: NSURL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "Azinec.ChampySwift" in the application's documents Application Support directory.
    let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    return urls[urls.count-1]
  }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = NSBundle.mainBundle().URLForResource("ChampySwift", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
  }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
    } catch {
      // Report any error we got.
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
      dict[NSLocalizedFailureReasonErrorKey] = failureReason
      
      dict[NSUnderlyingErrorKey] = error as! NSError
      let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      // Replace this with code to handle the error appropriately.
      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
      NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      abort()
    }
    
    return coordinator
  }()
  
  lazy var managedObjectContext: NSManagedObjectContext = {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    let coordinator = self.persistentStoreCoordinator
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
  }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    if managedObjectContext.hasChanges {
      do {
        try managedObjectContext.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
      }
    }
  }
  
}

