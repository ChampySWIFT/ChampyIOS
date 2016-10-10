//
//  AppDelegate.swift
//  ChampySwift
//
//  Created by Molnar Kristian on 4/23/16.
//  Copyright © 2016 AzinecLLC. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  var CurrentUser:UserDefaults = UserDefaults.standard
  
  var window: UIWindow?
  var mainView:UIView! = nil
  var subscribed:Bool = false
  var historyViewController: HistoryViewController!   = nil
  var friendsViewController: FriendsViewController!   = nil
  var settingsViewController: SettingsViewController! = nil
  var mainViewController: MainViewController!         = nil
  var prototypeFriendCell:FriendCell!
  var table3:AllFriendsTableViewController! = nil
  var table2:PendingFriendsController! = nil
  var table1:FriendsTableViewController! = nil
  
  
  var historyTable1:InProgressTableViewController! = nil
  var historyTable2:WinsTableViewController! = nil
  var historyTable3:FailedTableViewController! = nil
  
  var mainViewCard:[String:UIView] = [:]
  weak var prototypeNoImage = #imageLiteral(resourceName: "noImageIcon")
  weak var winsPrototypeIcon = #imageLiteral(resourceName: "wins")
  weak var totalPrototypeIcon = #imageLiteral(resourceName: "Total")
  weak var inProgressPrototypeIcon = #imageLiteral(resourceName: "inProgressMiniImage")
  var unconfirmedChallenges:Int = 0
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    
    
    if UIApplication.shared.applicationState == .active {
      CHPush().clearBadgeNumber()
    }
  }
  
  override init() {
    // Firebase Init
    FIRApp.configure()
    
  }
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    registerForPushNotifications(application)
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.tokenRefreshNotification),  name: NSNotification.Name.firInstanceIDTokenRefresh, object: nil)
    
    CHPush().clearBadgeNumber()
    self.prototypeFriendCell = FriendCell()
    return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
  func tokenRefreshNotification(_ notification: Notification) {
    if let refreshedToken = FIRInstanceID.instanceID().token() {
      
      let params = [
        "APNIdentifier" : refreshedToken //deviceToken.description as String
      ]
      
      CHRequests().updateUserProfile(CHSession().currentUserId, params: params) { (result, json) in
        if result {
        
        }
      }
    }
    
    
    connectToFcm()
  }
  
  func registerForPushNotifications(_ application: UIApplication) {
    
    if #available(iOS 10.0, *){
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
        if (granted)
        {
          let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          UIApplication.shared.registerUserNotificationSettings(setting)
          UIApplication.shared.registerForRemoteNotifications()
        }
        else{
          //Do stuff if unsuccessful...
        }
      })
    }
      
    else{ //If user is not on iOS 10 use the old methods we've been using
      let notificationSettings = UIUserNotificationSettings(
        types: [.badge, .sound, .alert], categories: nil)
      application.registerUserNotificationSettings(notificationSettings)
      
    }
    
  }
  
  // [START connect_to_fcm]
  func connectToFcm() {
    FIRMessaging.messaging().connect { (error) in
      
    }
  }
  // [END connect_to_fcm]
  
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
    
  }
  
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let formatedDeviceToken:String = self.getSimpleDeviceToken("\(deviceToken)")
    UserDefaults.standard.set(deviceToken, forKey: "deviceToken")
    UserDefaults.standard.set(formatedDeviceToken, forKey: "deviceTokenString")
    
    CHPush().subscribeForNotifications()
    
  }
  
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    //Handle the notification
  }
  
//  @available(iOS 10.0, *)
//  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//    //Handle the notification
//    response.notificatio
//    CHPush().alertPush("GOT PUSH", type: "Warning")
//  
//  }
  
  
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    if response.notification.request.content.title == "Friend request" {
      CHPush().localPush("toFriends", object: self)
    }
  }
  
  func getSimpleDeviceToken(_ deviceToken:String)->String{
    var token:String = deviceToken.replacingOccurrences(of: " ", with: "")
    token = token.replacingOccurrences(of: "<", with: "")
    token = token.replacingOccurrences(of: ">", with: "")
    return token
  }
  
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print(error)
  }
  
 
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
  //        ////////print("success")
  //      }
  //    }
  //  }
  
  func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
    if notification.userInfo != nil {
      let data = notification.userInfo as! [String:String]
      
      if data["type"] == "WakeUp" {
        CHBanners().setTimeout(3.0, block: {
          CHPush().localPush("refreshIcarousel", object: self)
        })
        
      }
    }
    
  }
  
  
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    FIRMessaging.messaging().disconnect()
    ////////print("Disconnected from FCM.")
    CHWakeUpper().setUpWakeUp()
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    CHPush().localPush("refreshIcarousel", object: self)
    CHPush().clearBadgeNumber()
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    connectToFcm()
    CHPush().clearBadgeNumber()
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }
  
  // MARK: - Core Data stack
  
  lazy var applicationDocumentsDirectory: URL = {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "Azinec.ChampySwift" in the application's documents Application Support directory.
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
  }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    let modelURL = Bundle.main.url(forResource: "ChampySwift", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    } catch {
      // Report any error we got.
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
      dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
      
      dict[NSUnderlyingErrorKey] = error as NSError
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
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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

