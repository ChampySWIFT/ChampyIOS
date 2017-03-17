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
import Async
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  
  // MARK: - Simple Parameters
  var CurrentUser:UserDefaults = UserDefaults.standard
  var window: UIWindow?
  var mainView:UIView! = nil
  var subscribed:Bool = false
  
  // MARK: - View Controllers
  
  var historyViewController: HistoryViewController!   = nil
  var friendsViewController: FriendsViewController!   = nil
  var settingsViewController: SettingsViewController! = nil
  var table3:AllFriendsTableViewController! = nil
  var table2:PendingFriendsController! = nil
  var table1:FriendsTableViewController! = nil
  var mainViewController: MainViewController!         = nil
  
  // MARK: - TableViewControllers
  
  var historyTable1:HistoryTableViewController! = nil
  var historyTable2:HistoryTableViewController! = nil
  var historyTable3:HistoryTableViewController! = nil
  
  // MARK: - Other variables
  var mainViewCard:[String:UIView] = [:]
  var friendCells:[String:UITableViewCell] = [:]
  var unconfirmedChallenges:Int = 0
  var prototypeFriendCell:FriendCell!
  
  // MARK: - weak variables
  
  weak var prototypeNoImage = #imageLiteral(resourceName: "noImageIcon")
  weak var winsPrototypeIcon = #imageLiteral(resourceName: "wins")
  weak var totalPrototypeIcon = #imageLiteral(resourceName: "Total")
  weak var inProgressPrototypeIcon = #imageLiteral(resourceName: "inProgressMiniImage")
  
  
  
  
  
  override init() {
    FIRApp.configure()
  }
  
  // MARK: - UIApplication Methods
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if UIApplication.shared.applicationState == .active {
      CHPush().clearBadgeNumber()
    }
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
  
  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) { }
  
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
  
  func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) { }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let formatedDeviceToken:String = self.getSimpleDeviceToken("\(deviceToken)")
    UserDefaults.standard.set(deviceToken, forKey: "deviceToken")
    UserDefaults.standard.set(formatedDeviceToken, forKey: "deviceTokenString")
    CHPush().subscribeForNotifications()
  }
  
  // MARK: - Notification methods
  
  @available(iOS 10.0, *)
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {}
   
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
  
  func tokenRefreshNotification(_ notification: Notification) {
    if let refreshedToken = FIRInstanceID.instanceID().token() {
      let params = [
        "APNIdentifier" : refreshedToken //deviceToken.description as String
      ]
      CHRequests().updateUserProfile(CHSession().currentUserId, params: params) { (result, json) in
        if result {}
      }
    }
    connectToFcm()
  }
  
  func registerForPushNotifications(_ application: UIApplication) {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
      UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .sound, .alert], completionHandler: {(granted, error) in
        if (granted) {
          let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          UIApplication.shared.registerUserNotificationSettings(setting)
          UIApplication.shared.registerForRemoteNotifications()
        }
      })
    } else {
      let notificationSettings = UIUserNotificationSettings( types: [.badge, .sound, .alert], categories: nil)
      application.registerUserNotificationSettings(notificationSettings)
      application.registerForRemoteNotifications()
    }
  }
  
  func connectToFcm() {
    FIRMessaging.messaging().connect { (error) in }
  }
  
  
  // MARK: - LifeCycle methods
  
  func applicationWillResignActive(_ application: UIApplication) { }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    FIRMessaging.messaging().disconnect()
    CHWakeUpper().setUpWakeUp()
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    CHPush().localPush("refreshIcarousel", object: self)
    CHPush().clearBadgeNumber()
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    connectToFcm()
    CHPush().clearBadgeNumber()
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    self.saveContext()
  }
  
  // MARK: - Core Data stack
  
  lazy var applicationDocumentsDirectory: URL = {
    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return urls[urls.count-1]
  }()
  
  lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = Bundle.main.url(forResource: "ChampySwift", withExtension: "momd")!
    return NSManagedObjectModel(contentsOf: modelURL)!
  }()
  
  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
    var failureReason = "There was an error creating or loading the application's saved data."
    do {
      try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
    } catch {
      var dict = [String: AnyObject]()
      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
      dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
      dict[NSUnderlyingErrorKey] = error as NSError
      let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
      NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
      abort()
    }
    
    return coordinator
  }()
  
  lazy var managedObjectContext: NSManagedObjectContext = {
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
        let nserror = error as NSError
        NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
        abort()
      }
    }
  }
  
}

