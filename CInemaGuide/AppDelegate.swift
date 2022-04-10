 //
//  AppDelegate.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/5/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//cfff

import UIKit
import UserNotifications
//import Fabric
//import Crashlytics
//import Instabug
import StoreKit
import AwesomeCache
import Firebase
 import AppTrackingTransparency

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var isUniversalLink = Bool()
    var universalLinkMovieID: Int!
    var universalLinkCinemaID: Int!
    var isMoviesList = Bool()
    var isCinemasList = Bool()
    var isPushNotification = Bool()
    var pushNotificationMovieID: String!
    var pushNotificationCinemaID: String!
    let comingSoonSelected = try! Cache<NSNumber>(name: "ComingSoonSelected")
  //  let interstaialIndex = try! Cache<NSNumber>(name: "InterstaialIndex")
    let genresCache = try! Cache<NSMutableArray>(name: "GenresArrayCache")
    let notificationState = try! Cache<NSNumber>(name: "NotificationState")
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if Helper.favCinemas == nil{
            Helper.favCinemas = []
        }
      //  interstaialIndex["InterstaialIndex"] = 0
        genresCache["GenresArrayCache"] = NSMutableArray()
        
        guard let gai = GAI.sharedInstance() else {
            assert(false, "Google Analytics not configured correctly")
            return true
        }
        
        // Remove before app release.
        gai.logger.logLevel = .verbose;
        
        gai.tracker(withTrackingId:  "UA-697331-74")
        // Optional: automatically report uncaught exceptions.
        gai.trackUncaughtExceptions = true
        GAI.sharedInstance().defaultTracker = gai.tracker(withTrackingId:  "UA-697331-74")

        CinemaGuideLocalizer.DoTheMagic()
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SegoeUI", size: 10)!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.5725490196, green: 0.5725490196, blue: 0.5725490196, alpha: 1)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont(name: "SegoeUI", size: 10)!, NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 0.7294117647, blue: 0.03137254902, alpha: 1)], for: .selected)
        UITabBar.appearance().backgroundImage = #imageLiteral(resourceName: "TabBarBackground")
        
        // Open app from notification
        if let remoteNotif = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary {
            if let type = remoteNotif["type"] {
                let pushType = type as! String
                if pushType == "1" {
                    if let id = remoteNotif["id"] {
                        pushNotificationMovieID = id as! String
                        isPushNotification = true
                    }
                } else if pushType == "2" {
                    if let id = remoteNotif["id"] {
                        pushNotificationCinemaID = id as! String
                        isPushNotification = true
                    }
                }
            }
        }
        
        if #available(iOS 14, *) {
           ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
          // Load ads here
           })
        } else {
          // Load ads here
        }
//        Fabric.with([Crashlytics.self])
        
//        if CinemaGuideLangs.currentAppleLanguage() == "ar" {
//            Instabug.setLocale(.arabic)
//        } else {
//            Instabug.setLocale(.english)
//        }
//        Instabug.start(withToken: "0078ee512f216a4c8817790221e84ed6", invocationEvent: .shake)
        
        //Effective Measure
        //let traker = EmTracker()
        //traker.configure("CinemaGuideMobileApp", tld: "filbalad.com", sdkKey: "2da9a01d-0fc7-4902-8d34-9f37d5bc55f6")
        //traker.trackDefault()
        //traker.verbose = true
        
//        if #available(iOS 10.3, *) {
//            SKStoreReviewController.requestReview()
//        } else {
//            SwiftRater.daysUntilPrompt = 7
//            SwiftRater.showLaterButton = true
//            SwiftRater.debugMode = true
//            SwiftRater.appLaunched()
//        }
        
        if let notiState = self.notificationState["NotificationState"] {
            let toPush = Bool.init(notiState)
            if toPush {
                Netmera.start()
                Netmera.setAPIKey("JvW2qzZ6xCjx8B-8P2Vrju5dghrFrSGgMTDCmK0Q1CINNVs5PHPZ9w")
                Netmera.setEnabledPopupPresentation(false)
                Netmera.setLogLevel(NetmeraLogLevel.debug)
                //Register push notifications
                if #available(iOS 10.0, *) {
                    UNUserNotificationCenter.current().delegate = self
                    let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
                    UNUserNotificationCenter.current().requestAuthorization(
                        options: authOptions,
                        completionHandler: {_, _ in })
                    application.registerForRemoteNotifications()
                } else {
                    let settings: UIUserNotificationSettings =
                        UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
                    application.registerUserNotificationSettings(settings)
                }
            } else {
                if #available(iOS 10.0, *) {
                   application.unregisterForRemoteNotifications()
                } else {
                    application.unregisterForRemoteNotifications()
                }
            }
        } else {
            Netmera.start()
            Netmera.setAPIKey("JvW2qzZ6xCjx8B-8P2Vrju5dghrFrSGgMTDCmK0Q1CINNVs5PHPZ9w")
            Netmera.setEnabledPopupPresentation(false)
            Netmera.setLogLevel(NetmeraLogLevel.debug)
            notificationState["NotificationState"] = 1
            //Register push notifications
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().delegate = self
                let authOptions: UNAuthorizationOptions = [.alert, .sound, .badge]
                UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: {_, _ in })
                application.registerForRemoteNotifications()
            } else {
                let settings: UIUserNotificationSettings =
                    UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
                application.registerUserNotificationSettings(settings)
            }
        }
        
        FirebaseApp.configure()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        UserDefaults.standard.set(0, forKey: "ClickCountCache")
        UserDefaults.standard.set(0, forKey: "FirstChangeLang")
        comingSoonSelected.removeAllObjects()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.

    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        UserDefaults.standard.set(0, forKey: "ClickCountCache")
        UserDefaults.standard.set(0, forKey: "FirstChangeLang")
        comingSoonSelected.removeAllObjects()
        
        if var topViewController = UIApplication.shared.windows.first?.rootViewController {
            while (true) {
                if topViewController.presentedViewController != nil {
                    topViewController = topViewController.presentedViewController!
                } else if topViewController is UINavigationController {
                    topViewController = (topViewController as! UINavigationController).topViewController!
                } else if topViewController is UITabBarController {
                    topViewController = (topViewController as! UITabBarController).selectedViewController!
                } else {
                    break;
                }
            }
            //For ticket Bug #22737 (1)
            if let topViewController = topViewController as? CinemasViewController {
                topViewController.setuplocationManager()
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.set(0, forKey: "ClickCountCache")
        UserDefaults.standard.set(0, forKey: "FirstChangeLang")
        comingSoonSelected.removeAllObjects()
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            print("application(_:continue:restorationandler:)")
            let urlToOpen = (userActivity.webpageURL?.absoluteString)!
            if (urlToOpen.range(of: "movies/details/") != nil) {
                var urlStringArr = urlToOpen.components(separatedBy: "details/")
                let idFullString = urlStringArr[1] 
                let idStringArr = idFullString.components(separatedBy: "/")
                let movieID = Int(idStringArr[0])
                isUniversalLink = true
                universalLinkMovieID = movieID!
                if application.applicationState == .background || application.applicationState == .inactive {
                    NotificationCenter.default.post(name: Notification.Name("OpenMovieFromDeepLink"), object: universalLinkMovieID)
                }
            }
            if (urlToOpen.range(of: "cinemas/details/") != nil) {
                var urlStringArr = urlToOpen.components(separatedBy: "details/")
                let idFullString = urlStringArr[1]
                let idStringArr = idFullString.components(separatedBy: "/")
                let cinemaID = Int(idStringArr[0])
                isUniversalLink = true
                universalLinkCinemaID = cinemaID!
                if application.applicationState == .background || application.applicationState == .inactive {
                    NotificationCenter.default.post(name: Notification.Name("OpenCinemaFromDeepLink"), object: universalLinkCinemaID)
                }
            }
            
            if (urlToOpen.range(of: "movies/index") != nil) {
                isUniversalLink = true
                isMoviesList = true
                if application.applicationState == .background || application.applicationState == .inactive {
                    NotificationCenter.default.post(name: Notification.Name("OpenMoviesListFromDeepLink"), object: nil)
                }
            }
            
            if (urlToOpen.range(of: "cinemas/index") != nil) {
                isUniversalLink = true
                isCinemasList = true
                if application.applicationState == .background || application.applicationState == .inactive {
                    NotificationCenter.default.post(name: Notification.Name("OpenCinemasListFromDeepLink"), object: nil)
                }
            }
        }

        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        if let messageID = userInfo[""] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
       // completionHandler(UIBackgroundFetchResult.newData)
        NotificationCenter.default.post(name: Notification.Name("ShowPushNotificationAlert"), object: userInfo)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        let user = NetmeraUser()
        user.userId = token
        //user.userId = "55"
        if let country = UserDefaults.standard.object(forKey: "UserCountry") {
            user.country = country as! String
        } else {
            user.country = "eg"
        }
        
//        Instabug.ibgLog(token)
//        Instabug.ibgLog(user.country ?? "")
        Netmera.update(user)
    }
    
    // Receive displayed notifications for iOS 10 devices.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        NotificationCenter.default.post(name: Notification.Name("ShowPushNotificationAlert"), object: userInfo)
        
        if let messageID = userInfo[""] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[""] {
            print("Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler()
    }
}

