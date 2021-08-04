//
//  AppInfoHelper.swift
//  Predictions
//
//  Created by Hesham Haleem on 4/15/18.
//  Copyright © 2018 Sarmady. All rights reserved.
//

import Foundation
import SCLAlertView
import SIAlertView
class AppInfoHelper: NSObject {
    
    //MARK: - Sponsorship functions
    class func isCinemaSponsored(cinemaID: Int) -> Bool {
        for cinema in Helper.appInfo.cinemasSponsor {
            if cinemaID == cinema.itemId && cinema.isActive == 1{
                return true
            }
        }
        return false
    }
    
    class func isMovieSponsored(movieId: Int) -> Bool {
        for movie in Helper.appInfo.moviesSponsor {
            if movieId == movie.itemId && movie.isActive == 1{
                return true
            }
        }
        return false
    }
    class func isCountrySponsored(countryCode: Int) -> Bool {
         for code in  Helper.appInfo.countrySponsor{
        for ccode in code.countryCode {
           if ccode == (UserDefaults.standard.object(forKey: "UserCountry") as! String).lowercased() && Bool(code.isActive! as NSNumber) == true {
                return true
            }
        }
            
        }
        return false

    }
    
    class func getIntersitialPattern() -> [Int] {
        return Helper.appInfo.interstitialNumberOfActions
    }
    class func isCountrySplashSponsored() -> Bool {
        for countryCode in Helper.appInfo.countrySponsor{
            for code in countryCode.countryCode{
                if code == (UserDefaults.standard.object(forKey: "UserCountry") as! String).lowercased() && Bool(countryCode.isActive! as NSNumber) == true {
                    return true
                }
            }

        }
        return false
    }
    class func isAppSponsored() -> Bool {
        return Bool(Helper.appInfo.sponsor.isActive as NSNumber)
    }
    class func getCinemaSponsor(cinemaID: Int) -> URL {
        let scale = UIScreen.main.scale
        for cinema in Helper.appInfo.cinemasSponsor {
            if cinemaID == cinema.itemId{
            let sponsorImagePath = String(format: "%@strip@\(Int(scale))x.png",cinema.baseUrl!)
            return URL(string: sponsorImagePath)!
            }
        }
        return URL(string: "")!
    }
    class func getMovieSponsor(movieId: Int) -> URL {
        let scale = UIScreen.main.scale
        for cinema in Helper.appInfo.moviesSponsor {
            if movieId == cinema.itemId{
                let sponsorImagePath = String(format: "%@strip@\(Int(scale))x.png",cinema.baseUrl!)
                return URL(string: sponsorImagePath)!
            }
        }
        return URL(string: "")!
    }
    class func getSplashSponsorImageURL() -> URL {
        let scale = UIScreen.main.scale
        let sponsorImagePath = String(format: "%@Splash/splash@\(Int(scale))x.png",Helper.appInfo.sponsor.baseUrl!)
        return URL(string: sponsorImagePath)!
    }
    class func getCountrySplashSponsorImageURL() -> URL {
        let scale = UIScreen.main.scale
        var sponsorImagePath = String()
        for countryCode in Helper.appInfo.countrySponsor{
            for code in countryCode.countryCode{
        if code == (UserDefaults.standard.object(forKey: "UserCountry") as! String).lowercased() &&  countryCode.baseUrl != nil{
        sponsorImagePath = String(format: "%@Splash/splash@\(Int(scale))x.png",countryCode.baseUrl!)
        return URL(string:sponsorImagePath)!
        }
        }
    }
        return URL(string: "")!

    }
    
    class func getCountryStripSponsorImageURL() -> URL {
        let scale = UIScreen.main.scale
        var sponsorImagePath = String()
        for countryCode in Helper.appInfo.countrySponsor{
            for code in countryCode.countryCode{
                if code == (UserDefaults.standard.object(forKey: "UserCountry") as! String).lowercased() &&  countryCode.baseUrl != nil{
                    sponsorImagePath = String(format: "%@Strip/strip@\(Int(scale))x.png",countryCode.baseUrl!)
                    return URL(string:sponsorImagePath)!
                }
    
            }
        }
        return URL(string: "")!
    }
    
    class func getStripSponsorImageURL() -> URL {
        let scale = UIScreen.main.scale
        var imagePath = String()
        imagePath = String(format: "%@Strip/strip@\(Int(scale))x.png",Helper.appInfo.sponsor.baseUrl!)
        return URL(string:imagePath)!
    }
    
    class func getAPIBaseURL() -> String {
        if Helper.appInfo.apiBaseUrl != nil{
            return Helper.appInfo.apiBaseUrl+"api/"
        }
        else{
            return "https://apiv2.filbalad.com/"+"api/"
        }
        
    }

    class func getMediaBaseURL() -> String {
        if Helper.appInfo.mediaBaseUrl != nil{
            return Helper.appInfo.mediaBaseUrl
        }
        else{
            return "https://media.filbalad.com/"
        }
        
    }
    
    //MARK: - Ads functions
    class func isInterstatialAdsEnabledForCurrentVersion() -> Bool {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        for aVersion in Helper.appInfo.interstitialAdsEnabledPerVersion! {
            if version == aVersion {
                return true
            }
        }
        return false
    }
    
    class func isVersionSponsorsed() -> Bool {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        for aVersion in Helper.appInfo.sponsorAdsEnabledPerVersion! {
            if version == aVersion {
                return true
            }
        }
        return false
    }
    
    class func isMpuEnabled() -> Bool {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        for aVersion in Helper.appInfo.mpuAdsEnabledPerVersion {
            if version == aVersion {
                return true
            }
        }
        return false
    }
    //MARK: - Messages functions
    class func isAppNeedsUpdate() -> Bool {
        let updateIsActiveNumber = NSNumber(value: (Helper.appInfo.app?.isActive)!)
        let isUpdateActive = Bool(exactly: updateIsActiveNumber)
        if isUpdateActive! {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                for aVersion in (Helper.appInfo.app?.versionsNeedUpdate!)! {
                    if version == aVersion {
                        return true
                    }
                }
            }
        }
        return false
    }
//    class func checkUpdateDate() -> Bool{
//        let savedDate = UserDefaults.standard.object(forKey: "lastUpdateDate") as! NSDate
//        let components = Calendar.current.dateComponents([.day,.month], from:savedDate as Date, to: Date())
//        
//        if components.day! > (Helper.appInfo.app?.days as! Int){
//            return true
//        }
//        return false
//    }
    class func isCoreUpdate() -> Bool {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                for aVersion in (Helper.appInfo.app?.versionsNeedCoreUpdate!)! {
                    if version == aVersion {
                        return true
                    }
                }
            }
        return false
    }
    
    class func getAppMessage() -> String {
        var msg = String()
        if CinemaGuideLangs.currentAppleLanguage() == "ar"{
            msg = Helper.appInfo.app.msg.ar
        }
        else{
            msg = Helper.appInfo.app.msg.en
        }
        return msg
    }
    class func shouldViewUpdateMessage() -> Bool {
        
        return Bool(Helper.appInfo.message.isActive as NSNumber)
    }
    
    class func saveLastUpdateMessageDate(){
        UserDefaults.standard.set(NSDate(), forKey: "lastUpdateDate")
        UserDefaults.standard.synchronize()
    }

    class func showAppMessage() {
        
        if Helper.appInfo.message?.isActive == 1{
            var msg = String()
            if CinemaGuideLangs.currentAppleLanguage() == "ar"{
                msg = Helper.appInfo.message.msg.ar
            }
            else{
                msg = Helper.appInfo.message.msg.en
            }
            let alertView=SIAlertView(title: "", andMessage: (msg))
           // alertView?.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1450980392, alpha: 1)
            alertView?.viewBackgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1450980392, alpha: 1)
            alertView?.buttonColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            alertView?.titleColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            alertView?.messageColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            alertView?.cornerRadius = 4.0;
            alertView?.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel Key"), type: .default, handler: { (alert) in
                alertView?.dismiss(animated: true)
            })
            if Helper.appInfo.message.msgUrl != "" && Helper.appInfo.message.msgUrl != nil{
                alertView?.addButton(withTitle: NSLocalizedString("Done", comment: "Done Key"), type: .default, handler: { (alert) in
                    UIApplication.shared.openURL(URL(string: (Helper.appInfo.message?.msgUrl)!)!)
                    
                })
            }
            alertView?.show()
        }
    }
    
    class func showUpdateMessage() {
        var msg = String()

        DispatchQueue.main.async {
            if msg.lowercased() == "ar"{
                msg = Helper.appInfo.app.msg.ar
            }
            else{
                msg = Helper.appInfo.app.msg.en
            }
            let alertView=SIAlertView(title: "", andMessage: (msg))
            // alertView?.backgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1450980392, alpha: 1)
            alertView?.viewBackgroundColor = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1450980392, alpha: 1)
            alertView?.buttonColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            alertView?.titleColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            alertView?.messageColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            alertView?.cornerRadius = 4.0;
            alertView?.addButton(withTitle: NSLocalizedString("Cancel", comment: "Cancel Key"), type: .default, handler: { (alert) in
                alertView?.dismiss(animated: true)
            })
            alertView?.addButton(withTitle: NSLocalizedString("Update", comment: "Update Key"), type: .default, handler: { (alert) in
                UIApplication.shared.openURL(URL(string: (Helper.appInfo.app?.storeUrl)!)!)
            })
            alertView?.show()
 
    }
}
}
