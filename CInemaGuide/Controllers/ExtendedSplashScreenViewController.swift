//
//  ExtendedSplashScreenViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/17/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher
import Instabug
import GoogleMobileAds
@available(iOS 13.0, *)
class ExtendedSplashScreenViewController: UIViewController, UIGestureRecognizerDelegate , GADFullScreenContentDelegate {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var cinemaLogoImage: UIImageView!
    @IBOutlet weak var redDotImage: UIImageView!
    @IBOutlet weak var cinemaGuideLogo: UIImageView!
    @IBOutlet weak var sarmadyLogoImage: UIImageView!
    @IBOutlet weak var copywritesLable: UILabel!
    @IBOutlet weak var sponsorImageView: UIImageView!
    
    @IBOutlet weak var sponsorImgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sponsorImgHeightConstraint: NSLayoutConstraint!
    var isSponsorEnabled = false
    
    //@available(iOS 13.0, *)
    override func viewDidLoad() {
         super.viewDidLoad()
        
        self.initSplachViewController()
        self.setupIntersitalAd()
//        if UserDefaults.standard.bool(forKey: "defaultCountryAndLanguage"){
//            self.initSplachViewController()
//        }
//        else{
//           UserDefaults.standard.set(true, forKey: "defaultCountryAndLanguage")
//            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//            let languageAndCountryViewController = mainStoryboard.instantiateViewController(identifier: "LangsAndCountriesVC") as? LanguageAndCountriesViewController
//            self.present(languageAndCountryViewController!, animated: true, completion: nil)
//        }
        
         
//              let languagealert = UIAlertController(title: "Language", message: "Change Language", preferredStyle: .alert)
//                let languageEnglishAction = UIAlertAction(title: "عربي", style: .default) { [weak self] _ in
//                    if let self = self{
//                        APIConstants.URLs.locale = "ar"
//                        CinemaGuideLangs.setAppleLAnguageTo(lang: "ar")
//                        UserDefaults.standard.set(1, forKey: "FirstChangeLang")
//                        Instabug.setLocale(.arabic)
//
//                        //UI
//                        //Flip UIView
//                        MethodSwizzleGivenClassName(cls: UILabel.self, originalSelector: #selector(UILabel.layoutSubviews), overrideSelector: #selector(UILabel.cstmlayoutSubviews))
//                        if #available(iOS 9.0, *) {
//                            UIView.appearance().semanticContentAttribute = .forceRightToLeft
//                        } else {
//                            // Fallback on earlier versions
//                        }
//                    self.initSplachViewController()
//                    }
//                }
//                let languageArabicAction = UIAlertAction(title: "English", style: .default) { [weak self] _ in
//                    if let self = self{
//                        APIConstants.URLs.locale = "en"
//                        CinemaGuideLangs.setAppleLAnguageTo(lang: "en")
//                        Instabug.setLocale(.english)
//
//                        //UI
//                        //Flip UIView
//                        MethodSwizzleGivenClassName(cls: UILabel.self, originalSelector: #selector(UILabel.layoutSubviews), overrideSelector: #selector(UILabel.cstmlayoutSubviews))
//                        if #available(iOS 9.0, *) {
//                            UIView.appearance().semanticContentAttribute = .forceLeftToRight
//                        } else {
//                            // Fallback on earlier versions
//                        }
//                    self.initSplachViewController()
//                    }
//                       }
//                languagealert.addAction(languageEnglishAction)
//                languagealert.addAction(languageArabicAction)
//                self.present(languagealert, animated: true, completion: nil)
//
        
        
    }
    

    func initSplachViewController() {
        
        if #available(iOS 9.0, *) {
            self.view.semanticContentAttribute = .forceLeftToRight
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 9.0, *) {
            self.containerView.semanticContentAttribute = .forceLeftToRight
        } else {
            // Fallback on earlier versions
        }
        
        if UserDefaults.standard.object(forKey: "UserCountry") == nil{
            UserDefaults.standard.set("eg", forKey: "UserCountry")
        }
        self.cinemaLogoImage.alpha = 0.0
        self.redDotImage.alpha = 0.0
        self.cinemaGuideLogo.alpha = 0.0
        self.cinemaLogoImage.alpha = 0.0
        self.sarmadyLogoImage.alpha = 0.0
        self.copywritesLable.alpha = 0.0
        self.cinemaLogoImage.transform = CGAffineTransform(translationX: 0, y: 130)
        self.redDotImage.transform = CGAffineTransform(translationX: 0, y: 130)
        self.cinemaGuideLogo.transform = CGAffineTransform(translationX: 0, y: 300)

        APIManager.getAppInfo(success: { (appInfo: AppInfo) in
            Helper.intersistialPattern = appInfo.interstitialNumberOfActions

            if AppInfoHelper.isCoreUpdate() != true {
                UIView.animate(withDuration: 0.5,
                               delay: 0.0,
                               options: .curveEaseIn,
                               animations: {
                                self.cinemaLogoImage.alpha = 0.5
                                self.redDotImage.alpha = 0.5
                                self.cinemaGuideLogo.alpha = 0.5
                                self.cinemaLogoImage.transform = CGAffineTransform(translationX: 0, y: -50)
                                self.redDotImage.transform = CGAffineTransform(translationX: 0, y: -50)
                                self.cinemaGuideLogo.transform = CGAffineTransform(translationX: 0, y: -50)
                }) {(finished) in
                    if AppInfoHelper.isVersionSponsorsed(){
                        if AppInfoHelper.isCountrySplashSponsored(){
                            self.sponsorImageView.isHidden = false
                            self.sponsorImageView.kf.setImage(with: AppInfoHelper.getCountrySplashSponsorImageURL(), placeholder: nil, options: [.transition(.fade(0.7))], progressBlock: nil, completionHandler: { (image, error, cache, url) in
                                if error == nil{
                                    self.sponsorImgHeightConstraint.constant = (image?.size.height)!
                                    self.sponsorImgWidthConstraint.constant = (image?.size.width)!
                                }
                            })
                        }
                        else if AppInfoHelper.isAppSponsored(){
                            self.sponsorImageView.isHidden = false
                            self.sponsorImageView.kf.setImage(with: AppInfoHelper.getSplashSponsorImageURL(), placeholder: nil, options: [.transition(ImageTransition.fade(0.7)),.forceRefresh], progressBlock: nil, completionHandler: { (image, error, cache, url) in
                                if error == nil{
                                    self.sponsorImgHeightConstraint.constant = (image?.size.height)!
                                    self.sponsorImgWidthConstraint.constant = (image?.size.width)!
                                }
                            })

                        }
                        else {
                            self.sponsorImageView.isHidden = true
                        }
                    } else {
                        self.sponsorImageView.isHidden = true
                    }
                    UIView.animate(withDuration: 0.3,
                                   delay: 0.0,
                                   options: .curveEaseIn,
                                   animations: {
                                    self.cinemaLogoImage.alpha = 1
                                    self.redDotImage.alpha = 1
                                    self.cinemaGuideLogo.alpha = 1
                                    self.sarmadyLogoImage.alpha = 1
                                    self.copywritesLable.alpha = 1
                    }, completion: { (finished) in
                        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
                        rotationAnimation.fromValue = 360.0
                        rotationAnimation.toValue = 0.0
                        rotationAnimation.duration = 2.47
                        self.cinemaLogoImage.layer.add(rotationAnimation, forKey: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//                            if UserDefaults.standard.object(forKey: "UserCountry") != nil {
//
                                
                                if UserDefaults.standard.bool(forKey: "defaultCountryAndLanguage"){
                                     self.performSegue(withIdentifier: "NavigateToTabBar", sender: self)
                                }
                                else{
                                   UserDefaults.standard.set(true, forKey: "defaultCountryAndLanguage")
                                    self.performSegue(withIdentifier: "NavigateToLanguagesView", sender: self)
//                                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
//                                    let languageAndCountryViewController = mainStoryboard.instantiateViewController(identifier: "LangsAndCountriesVC") as? LanguageAndCountriesViewController
//                                    self.present(languageAndCountryViewController!, animated: true, completion: nil)
                                }
                                
                                
                                
                               
//                            } else {
//                              //  self.performSegue(withIdentifier: "NavigateToLanguagesView", sender: self)
//                            }
                        }
                    })
                }
            } else {

                let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error Key"), message: AppInfoHelper.getAppMessage(), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Key"), style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }) { (error: NSError?) in
            Instabug.ibgLog(error?.description ?? "")
            print(error?.description ?? "unkown error")
            var errorMessage = ""
            if error?.code == -1009 {
                errorMessage = NSLocalizedString("No internet connection, check your connection and try again", comment: "No Internet Connection")
            } else if error?.code == -1001 {
                errorMessage = NSLocalizedString("There is a problem in the connection, check your connection and try again", comment: "Error Internet Connection")
            } else {
                errorMessage = NSLocalizedString("Sorry , The server is under maintenance, thanks for your patience.", comment: "Error Message Key")
            }
            let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error Key"), message: errorMessage, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Key"), style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    func setupIntersitalAd() {
        Helper.interstitial = GAMInterstitialAd()
        Helper.interstitial.fullScreenContentDelegate = self
        let request = GAMRequest()
//        Helper.interstitial.load(request)
        
        GAMInterstitialAd.load(withAdManagerAdUnitID: "/7524/Mobile-FilBalad.com/New-Cinema-Guide-Interstitial", request: request) { (ads, error) in
            if (error != nil){
                Helper.currentAdIndex = 0
                print(error.debugDescription)
            }
            else{
                Helper.interstitial = ads;
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
