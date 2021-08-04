//
//  BaseViewController.swift
//  Predictions
//
//  Created by Nada Gamal on 4/30/18.
//  Copyright © 2018 Sarmady. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Toast_Swift
class BaseViewController: GAITrackedViewController , GADFullScreenContentDelegate , GADBannerViewDelegate{
   // var timer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
//        setupIntersitalAd()
        if AppInfoHelper.isInterstatialAdsEnabledForCurrentVersion(){
            if Helper.intersistialPattern != nil && Helper.intersistialPattern.count == 0{
                Helper.intersistialPattern = Helper.appInfo.interstitialNumberOfActions
            }
            Helper.currentAdIndex += 1
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        if AppInfoHelper.isInterstatialAdsEnabledForCurrentVersion(){
            for index in Helper.intersistialPattern! {
                if index == Helper.currentAdIndex+1 {
                    Helper.intersistialPattern!.remove(at: 0)
                    Helper.currentAdIndex = 0
                    break
                }
            }
        }
    

        
    }

    override func viewDidAppear(_ animated: Bool) {

        if AppInfoHelper.isInterstatialAdsEnabledForCurrentVersion(){
            if (Helper.currentAdIndex == Helper.intersistialPattern?[Helper.selectedIndex]){
            if Helper.interstitial != nil{
                    let counterDownLabel = UILabel(frame: CGRect(x: ((self.view.bounds.width/2) - 110), y: UIScreen.main.bounds.height - 150, width: 200, height: 70))
                    var count = 3
                    counterDownLabel.textAlignment = .center
                    counterDownLabel.backgroundColor = .black
                    counterDownLabel.textColor = .white
                    counterDownLabel.layer.cornerRadius =  35
                    counterDownLabel.clipsToBounds = true
                    counterDownLabel.numberOfLines = 2
                    self.view.window?.addSubview(counterDownLabel)
                self.view.window?.bringSubviewToFront(counterDownLabel)
                    let countString = String(count)
                    counterDownLabel.text = " إعلان بعد \(countString) ثانيه " + "\n" + " ads after \(countString) seconds"
            //            + "\n" + " ads after \(countString) seconds"
                
                    if #available(iOS 10.0, *) {
                    Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
                        
                        count -= 1
                        counterDownLabel.textAlignment = .center
                        counterDownLabel.backgroundColor = .black
                        counterDownLabel.textColor = .white
                        counterDownLabel.layer.cornerRadius =  35
                        counterDownLabel.clipsToBounds = true
                        counterDownLabel.numberOfLines = 2
                        let countString = String(count)
                        counterDownLabel.text = " إعلان بعد \(countString) ثانيه " + "\n" + " ads after \(countString) seconds"
                            if count <= 0{
                                timer.invalidate()
                                counterDownLabel.removeFromSuperview()
                                if  Helper.selectedIndex < Helper.intersistialPattern.count{
                                    Helper.selectedIndex += 1
                                }
                                    if Helper.interstitial != nil{
                                        let topViewController = UIApplication.shared.keyWindow?.rootViewController
                                        if topViewController != nil{
                                            Helper.interstitial .present(fromRootViewController: topViewController!)
                                        }
                                        else{
                                            Helper.interstitial .present(fromRootViewController: topViewController!)
                                        }
                                    }
                            }

                        }
//                && Helper.interstitial.isReady{
//                self.view.makeToast("Ad will show after 3 seconds", duration: 3.0, position: .bottom, title: "  سوف يظهر إعلان بعد ٣ ثواني  ", image: nil, style: ToastStyle()) { (didTap) in
//                    DispatchQueue.main.async {
//                       // let appDelegate:AppDelegate=UIApplication.shared.delegate as! AppDelegate
//                        let topViewController = UIApplication.shared.keyWindow?.rootViewController
//                        if didTap {
//                            if Helper.interstitial != nil{
//                                Helper.interstitial .present(fromRootViewController: topViewController!)
//                            }
//
//                        } else {
//                            if Helper.interstitial != nil{
//                                let topViewController = UIApplication.shared.keyWindow?.rootViewController
//                                if topViewController != nil{
//                                    Helper.interstitial .present(fromRootViewController: topViewController!)
//                                }
//                                else{
//                                    Helper.interstitial .present(fromRootViewController: topViewController!)
//                                }
//                            }
//                        }
//                        Helper.interstitial = nil
//                    }
                }

            }
            }
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
    // MARK :- Intersitial Delegates
//    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
//       // interstitial = ad
//    }
//    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
//
//        print(error)
//    }
    
    
    func setBannerView(_ keywords: [Any], andPosition postions: [String], andScreenName screenName: String?) -> UIView? {
      
       
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 270))
        contentView.backgroundColor = .clear
        
        let labelSponserArea = UILabel(frame: CGRect(x: contentView.frame.minX, y: contentView.frame.minY, width: contentView.frame.width, height: contentView.frame.height))
        labelSponserArea.text =  NSLocalizedString("adsarea", comment: "ads  Key") 
        labelSponserArea.textAlignment = .center
        contentView.addSubview(labelSponserArea)
        
        
        let bannerAdView = GAMBannerView(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
        bannerAdView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: contentView.frame.size.height / 2 - 10)
        bannerAdView.adSize = kGADAdSizeMediumRectangle
        bannerAdView.adUnitID = "/7524/Mobile-FilBalad.com/Cinema-Guide-MPU"
        bannerAdView.rootViewController = self
        bannerAdView.delegate = self
        let request = GADRequest()
        request.keywords = keywords
        
        bannerAdView.load(request)
        contentView.addSubview(bannerAdView)
    
//          let contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 270))
//          contentView.backgroundColor = .clear
//          let customAdSize = GADAdSize(size: CGSize(width: 300, height: 250), flags: 1)
//          let bannerView : DFPBannerView = DFPBannerView(adSize: customAdSize, origin: CGPoint(x: ((self.view.frame.width - 300)/2 - 10), y: 0))
//          bannerView.backgroundColor = .clear
//          bannerView.delegate = self
//          bannerView.rootViewController = self
//          bannerView.adSize = customAdSize
//          bannerView.adUnitID = "/7524/Mobile-FilBalad.com/Cinema-Guide-MPU"
//
//          let request = DFPRequest()
//          request.keywords = keywords
//          request.customTargeting = NSDictionary(objects:[keywords, postions], forKeys:["Keyword", "Position"] as [NSCopying]) as Dictionary
//          bannerView.load(request)
//          contentView.addSubview(bannerView)
          return contentView
      }
    

}
