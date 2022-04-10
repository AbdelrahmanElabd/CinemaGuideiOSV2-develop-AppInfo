//
//  SettingsViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/27/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import CustomizableActionSheet
import AwesomeCache
import UserNotifications
import Netmera
import GoogleMobileAds
//import Instabug

class SettingsViewController: BaseViewController, UIGestureRecognizerDelegate, UIActionSheetDelegate {

    //MARK: - Properties
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var navigationBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var appLanguageLabel: UILabel!
    @IBOutlet weak var appVersionLabel: UILabel!
    @IBOutlet weak var moreAppsView: UIView!
    @IBOutlet weak var notificationsSwitch: UISwitch!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var countryFlagImageView: UIImageView!
    @IBOutlet weak var CountryLabel: UILabel!
    @IBOutlet weak var countryNameLabel: UILabel!
    @IBOutlet weak var bannerMainView: UIView!
    @IBOutlet weak var adsAreaLabel: UILabel!
    var bannerView: GADBannerView!
    
    var selectedMovieID: Int!
    var selectedCinemaID: Int!
    var isPushMovie = false
    var isPushCinema = false
    var pushMovieID = Int()
    var pushCinemaID = Int()
    let genresCache = try! Cache<NSMutableArray>(name: "GenresArrayCache")
    let notificationState = try! Cache<NSNumber>(name: "NotificationState")
    var customActionSheet: CustomizableActionSheet?
    var selectedCountry = ""
    let favoriteCinemasIDsCache = try! Cache<NSMutableArray>(name: "FavoriteCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())")
    let favoriteCinemasArrayCache = try! Cache<NSMutableArray>(name: "FavoriteCinemasArray-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())")
    
    //MARK: - View lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                navBarHeightConstraint.constant = navBarHeightConstraint.constant + 20
            default:
                print("unknown")
            }
        }
        adsAreaLabel.text =  NSLocalizedString("adsarea", comment: "ads  Key")
        
        //Effective Measure
        //let tracker = EmTracker()
        //tracker.verbose = true
        //tracker.configure("CinemaGuideMobileApp", tld: "filbalad.com", sdkKey: "2da9a01d-0fc7-4902-8d34-9f37d5bc55f6")
        //tracker.trackDefault()
        
        if CinemaGuideLangs.currentAppleLanguage() == "ar" {
            appLanguageLabel.text = "العربية"
        } else {
            let sysLanguage = CinemaGuideLangs.currentAppleLanguage()
            appLanguageLabel.text = sysLanguage.uppercased()
        }
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersionLabel.text = version
        } else {
            appVersionLabel.text = ""
        }
        CountryLabel.text = NSLocalizedString("Country", comment: "CountryKey")
        if CinemaGuideLangs.currentAppleLanguage() == "ar" {
            if (UserDefaults.standard.object(forKey: "UserCountry") as! String).uppercased() == "SA" {
                countryNameLabel.text = "السعودية"
            } else {
                countryNameLabel.text = "مصر"
            }
        } else {
            let userCountry = UserDefaults.standard.object(forKey: "UserCountry") as? String ?? "EG"
            countryNameLabel.text = userCountry.uppercased()
        }
        if UserDefaults.standard.object(forKey: "UserCountry") as? String == nil {
            selectedCountry = "Eg"
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.moreAppsPressed(sender:)))
        moreAppsView.addGestureRecognizer(tap)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        self.addBannerView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Set Our Fake NavigationBar Header Background Height
        navigationBannerHeightConstraint?.constant = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMovie(notification:)), name: Notification.Name("OpenMovieFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinema(notification:)), name: Notification.Name("OpenCinemaFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMoviesList(notification:)), name: Notification.Name("OpenMoviesListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinemasList(notification:)), name: Notification.Name("OpenCinemasListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPushNotificationAlert(notification:)), name: Notification.Name("ShowPushNotificationAlert"), object: nil)
        
        if let notiState = self.notificationState["NotificationState"] {
            let toPush = Bool.init(notiState)
            if toPush {
                self.notificationsSwitch.isOn = true
            } else {
                UIApplication.shared.unregisterForRemoteNotifications()
                Netmera.setEnabledReceivingPushNotifications(false)
                self.notificationsSwitch.isOn = false
            }
        } else {
            if UIApplication.shared.isRegisteredForRemoteNotifications {
                self.notificationsSwitch.isOn = true
                Netmera.setEnabledReceivingPushNotifications(true)
            } else {
                self.notificationsSwitch.isOn = false
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let isUniversalLink = appDelegate.isUniversalLink
        if isUniversalLink {
            if let movieID = appDelegate.universalLinkMovieID {
                selectedMovieID = movieID
                self.performSegue(withIdentifier: "NavigateToMovieDetails", sender: self)
            } else if let cinemaID = appDelegate.universalLinkCinemaID {
                selectedCinemaID = cinemaID
                self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
            } else if appDelegate.isMoviesList {
                self.tabBarController?.selectedIndex = 1
            } else if appDelegate.isCinemasList {
                self.tabBarController?.selectedIndex = 2
            }
        }
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        screenName = "iOS-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())-\(CinemaGuideLangs.currentAppleLanguage())-Settings"
        
        AnalyticsHelper.GAsetScreenName(With: "Settings")
        AnalyticsHelper.firebaseSetScreenName(With: "Settings", className: "SettingsViewController.swift")
        AnalyticsHelper.firebaseLogEvent(itemID: "Settings View Controller", itemName: "Settings", cType: "View Settings", screenName: "Settings")
    }

    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        appDelegate.isUniversalLink=false
        NotificationCenter.default.removeObserver(self)
    }
    func addBannerView() -> Void {
        let shadowPath = UIBezierPath(rect:self.bannerMainView.bounds)
//        self.bannerMainView.layer.masksToBounds = false
//        self.bannerMainView.layer.shadowColor = UIColor.black.cgColor
//        self.bannerMainView.layer.shadowOffset = CGSize(width: 5.0, height: 10.0)
//        self.bannerMainView.layer.shadowOpacity = 0.5
//        self.bannerMainView.layer.shadowPath = shadowPath.cgPath
        bannerView=GADBannerView.init(adSize:  kGADAdSizeBanner, origin:CGPoint(x:(UIScreen.main.bounds.width-300)/2-10,y:0))//y: 5 y: 10
        bannerView.adUnitID = "ca-mb-app-pub-0868719255119470/6544059949"
        // DFPRequest().testDevices = [ "83abcd3168c1e7b1966378fd0f3f0cd0" ];
        bannerView.delegate = self;
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        self.bannerMainView.addSubview(bannerView)
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
    }
//    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        
//    }
    //MARK: - View controller functions
    @IBAction func notificationSwiftValueChanged(_ sender: UISwitch) {
        if let notifState = notificationState["NotificationState"] {
            let isNotificationregistered = Bool.init(notifState)
            if isNotificationregistered {
                notificationImage.image = #imageLiteral(resourceName: "NotificationOffIcon")
                
                AnalyticsHelper.GALogEventWith(name: "Settings-Notifications Deactivated", category: "Button Action")
                AnalyticsHelper.firebaseLogEvent(itemID: "Settings", itemName: "Settings-Notifications Deactivated", cType: "Button Action", screenName: "Settings")
                
                UIApplication.shared.unregisterForRemoteNotifications()
                Netmera.setEnabledReceivingPushNotifications(false)

                notificationState["NotificationState"] = 0
            } else {
                notificationImage.image = #imageLiteral(resourceName: "NotificationOnIcon")
                AnalyticsHelper.GALogEventWith(name: "Settings-Notifications Activated", category: "Button Action")
                AnalyticsHelper.firebaseLogEvent(itemID: "Settings", itemName: "Settings-Notifications Activated", cType: "Button Action", screenName: "Settings")
                Netmera.setEnabledReceivingPushNotifications(true)
                UIApplication.shared.registerForRemoteNotifications()
                notificationState["NotificationState"] = 1
            }
        }
    }
    
    @objc func moreAppsPressed(sender: UITapGestureRecognizer? = nil) {
        UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/us/artist/sarmady-communications-company/id374210176?mt=8&ign-mpt=uo%3D2")!)
        
        AnalyticsHelper.GALogEventWith(name: "Settings-More Apps", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Settings", itemName: "Settings-More Apps", cType: "Button Action", screenName: "Settings")
    }
    
    @IBAction func changeLanguageButtonPressed(_ sender: UIButton) {
        let actionSheet = UIActionSheet(title: NSLocalizedString("Choose Language", comment: "Choose Language Key"), delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel Key"), destructiveButtonTitle: nil, otherButtonTitles: "English", "العربية") 
        actionSheet.show(in: self.view)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 1 {
            var transition: UIView.AnimationOptions = .transitionFlipFromLeft
            if CinemaGuideLangs.currentAppleLanguage() == "en" {
                actionSheet.dismiss(withClickedButtonIndex: 1, animated: true)
            } else {
                APIConstants.URLs.locale = "en"
                CinemaGuideLangs.setAppleLAnguageTo(lang: "en")
                genresCache["GenresArrayCache"] = NSMutableArray()
//                Instabug.setLocale(.english)

                //UI
                //Flip UIView
                MethodSwizzleGivenClassName(cls: UILabel.self, originalSelector: #selector(UILabel.layoutSubviews), overrideSelector: #selector(UILabel.cstmlayoutSubviews))
                if #available(iOS 9.0, *) {
                    UIView.appearance().semanticContentAttribute = .forceLeftToRight
                } else {
                    // Fallback on earlier versions
                }
                
                //Restart App From Root
                let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
                rootviewcontroller.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainNav")
                
                //Flip Transition - Animation
                let mainwindow = (UIApplication.shared.delegate?.window!)!
                transition = .transitionFlipFromRight
                UIView.transition(with: mainwindow, duration: 0.55001, options: transition, animations: { () -> Void in
                }) { (finished) -> Void in
                    AnalyticsHelper.GALogEventWith(name: "Settings-App Changed To English", category: "Button Action")
                    AnalyticsHelper.firebaseLogEvent(itemID: "Settings", itemName: "Settings-App Changed To English", cType: "Button Action", screenName: "Settings")
                }
            }
        } else if buttonIndex == 2 {
            var transition: UIView.AnimationOptions = .transitionFlipFromLeft
            if CinemaGuideLangs.currentAppleLanguage() == "en" {
                APIConstants.URLs.locale = "ar"
                CinemaGuideLangs.setAppleLAnguageTo(lang: "ar")
                UserDefaults.standard.set(1, forKey: "FirstChangeLang")
                genresCache["GenresArrayCache"] = NSMutableArray()
//                Instabug.setLocale(.arabic)
                
                //UI
                //Flip UIView
                MethodSwizzleGivenClassName(cls: UILabel.self, originalSelector: #selector(UILabel.layoutSubviews), overrideSelector: #selector(UILabel.cstmlayoutSubviews))
                if #available(iOS 9.0, *) {
                    UIView.appearance().semanticContentAttribute = .forceRightToLeft
                } else {
                    // Fallback on earlier versions
                }
                
                //Restart App From Root
                let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
                rootviewcontroller.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainNav")
                
                //Flip Transition - Animation
                let mainwindow = (UIApplication.shared.delegate?.window!)!
                transition = .transitionFlipFromLeft
                UIView.transition(with: mainwindow, duration: 0.55001, options: transition, animations: { () -> Void in
                }) { (finished) -> Void in
                    AnalyticsHelper.GALogEventWith(name: "Settings-App Changed To Arabic", category: "Button Action")
                    AnalyticsHelper.firebaseLogEvent(itemID: "Settings", itemName: "Settings-App Changed To Arabic", cType: "Button Action", screenName: "Settings")
                }
            } else {
                actionSheet.dismiss(withClickedButtonIndex: 2, animated: true)
            }
        }
    }
    
    @IBAction func changeCountryButtonPressed(_ sender: UIButton) {
        var items = [CustomizableActionSheetItem]()
        if let view = self.tabBarController?.view {
            let changeCountryView = UINib(nibName: "ChangeCountryView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? ChangeCountryView
            changeCountryView?.delegate = self
            let changeCountryViewItem = CustomizableActionSheetItem(type: .view, height: 160)
            changeCountryViewItem.view = changeCountryView
            items.append(changeCountryViewItem)
            customActionSheet = CustomizableActionSheet()
            customActionSheet?.showInView(view , items: items)
        }
    }
    
    @objc func openMovie(notification: Notification) {
        selectedMovieID = notification.object as! Int
        self.performSegue(withIdentifier: "NavigateToMovieDetails", sender: self)
    }
    
    @objc func openCinema(notification: Notification) {
        selectedCinemaID = notification.object as! Int
        self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
    }
    
    @objc func openMoviesList(notification: Notification) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc func openCinemasList(notification: Notification) {
        self.tabBarController?.selectedIndex = 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NavigateToMovieDetails" {
            let destination = segue.destination as! MovieDetailsViewController
            destination.movieID = selectedMovieID
        } else if segue.identifier == "NavigateToCinema" {
            let destination = segue.destination as! CinemaDetailsViewController
            destination.cinemaID = selectedCinemaID
        }
    }
    
    //MARK: - Recieved push
    @objc func showPushNotificationAlert(notification: Notification) {
        let userInfo = notification.object as! [String: Any]
        let pushData = userInfo["aps"] as! [String: Any]
        let alertData = pushData["alert"] as! [String: Any]
        let notificationBody = alertData["body"] as! String
        var alertTitle = NSLocalizedString("Notification", comment: "Notification Key")
        if let type = userInfo["type"] {
            let pushType = type as! String
            if pushType == "1" {
                alertTitle = NSLocalizedString("Movie", comment: "Movie Key")
                if let id = userInfo["id"] {
                    pushMovieID = Int(id as! String)!
                    isPushMovie = true
                    isPushCinema = false
                }
            } else if pushType == "2" {
                if let id = userInfo["id"] {
                    alertTitle = NSLocalizedString("Cinema", comment: "A Cinema Key")
                    pushCinemaID = Int(id as! String)!
                    isPushMovie = false
                    isPushCinema = true
                }
            }
        }
        let alertController = UIAlertController(title: alertTitle, message: notificationBody, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (cancelAction : UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        let showAction = UIAlertAction(title: NSLocalizedString("Show", comment: "Show Key"), style: .default) { (showAction: UIAlertAction) in
            if self.isPushMovie {
                self.selectedMovieID = self.pushMovieID
                self.performSegue(withIdentifier: "NavigateToMovieDetails", sender: self)
            }
            if self.isPushCinema {
                self.selectedCinemaID = self.pushCinemaID
                self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(showAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension SettingsViewController: ChangeUserCountryDelegate {
    func changeCountryOkPressed(selectedCountry: String) {
        self.selectedCountry = selectedCountry
        UserDefaults.standard.set(selectedCountry, forKey: "UserCountry")

        UserDefaults.standard.synchronize()
        self.countryNameLabel.text = selectedCountry
        customActionSheet?.dismiss()
        
        let transition: UIView.AnimationOptions = .transitionFlipFromLeft
        let rootviewcontroller: UIWindow = ((UIApplication.shared.delegate?.window)!)!
        rootviewcontroller.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "MainNav")
        let mainwindow = (UIApplication.shared.delegate?.window!)!
        UIView.transition(with: mainwindow, duration: 0.55, options: transition, animations: { () -> Void in
        }) { (finished) -> Void in
            AnalyticsHelper.GALogEventWith(name: "Settings-App Country Changed", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Settings", itemName: "Settings-App Country Changed", cType: "Button Action", screenName: "Settings")
        }
    }
    
    func changeCountryCancelPressed() {
        customActionSheet?.dismiss()
    }
}
