//
//  GoogleAnalyticsHelper.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 2/13/18.
//  Copyright © 2018 HeshamHaleem. All rights reserved.
//

import UIKit
import Firebase

class AnalyticsHelper: NSObject {
    
    class func GAsetScreenName(With name: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "iOS-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())-\(CinemaGuideLangs.currentAppleLanguage())-\(name)")
        let build = (GAIDictionaryBuilder.createScreenView().build() as NSDictionary) as! [AnyHashable: Any]
        tracker?.send(build)
    }
    
    class func GALogEventWith(name: String, category: String) {
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        guard let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: "iOS-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())-\(CinemaGuideLangs.currentAppleLanguage())-\(name)", label: nil, value: nil) else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    class func firebaseSetScreenName(With screenName: String, className: String) {
        Analytics.setScreenName("\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())-\(CinemaGuideLangs.currentAppleLanguage())-\(screenName)", screenClass: className)
    }
    
    class func firebaseLogEvent(itemID: String, itemName: String, cType: String, screenName: String) {
        Analytics.logEvent(AnalyticsEventViewItem, parameters: [
            AnalyticsParameterItemID: "id-\(itemID)" as NSObject,
            AnalyticsParameterItemName: itemName as NSObject,
            AnalyticsParameterContentType: cType as NSObject,
            "OS": "iOS" as NSObject,
            "Locale": "\(CinemaGuideLangs.currentAppleLanguage())" as NSObject,
            "Country": "\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())" as NSObject,
            "Screen Name": screenName as NSObject
            ])
    }
}
