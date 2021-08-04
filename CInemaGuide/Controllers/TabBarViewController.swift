//
//  TabBarViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/12/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import AwesomeCache

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        let indexOfTab = self.viewControllers?.firstIndex(of: viewController)
        if indexOfTab == 0 {
            AnalyticsHelper.GALogEventWith(name: "Tab Bar-Selected Home", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Tab Bar", itemName: "Tab Bar-Selected Home", cType: "Button Action", screenName: "")
        } else if indexOfTab == 1 {
            AnalyticsHelper.GALogEventWith(name: "Tab Bar-Selected Movies", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Tab Bar", itemName: "Tab Bar-Selected Movies", cType: "Button Action", screenName: "")
        } else if indexOfTab == 2 {
            AnalyticsHelper.GALogEventWith(name: "Tab Bar-Selected Cinemas", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Tab Bar", itemName: "Tab Bar-Selected Cinemas", cType: "Button Action", screenName: "")
        } else if indexOfTab == 3 {
            AnalyticsHelper.GALogEventWith(name: "Tab Bar-Selected Favorite Cinemas", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Tab Bar", itemName: "Tab Bar-Selected Favorite Cinemas", cType: "Button Action", screenName: "")
        } else if indexOfTab == 4 {
            AnalyticsHelper.GALogEventWith(name: "Tab Bar-Selected Settings", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Tab Bar", itemName: "Tab Bar-Selected Settings", cType: "Button Action", screenName: "")
        }
    }
}
