//
//  ParentViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 2/12/18.
//  Copyright © 2018 HeshamHaleem. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ParentViewController: GAITrackedViewController , GADBannerViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func setBannerViewFooter(_ keywords: [Any], andPosition postions: [String], andScreenName screenName: String?) -> UIView? {
        
        let contentView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 270))
        contentView.backgroundColor = .clear
        
        let labelSponserArea = UILabel(frame: CGRect(x: contentView.frame.minX, y: contentView.frame.minY, width: contentView.frame.width, height: contentView.frame.height))
        labelSponserArea.text = NSLocalizedString("adsarea", comment: "ads  Key") 
        labelSponserArea.textAlignment = .center
        contentView.addSubview(labelSponserArea)
        
        
        let bannerAdView = GAMBannerView(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
        bannerAdView.center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: contentView.frame.size.height / 2 - 10)
        bannerAdView.adSize = kGADAdSizeMediumRectangle
        bannerAdView.adUnitID = "/7524/Mobile-FilBalad.com/Cinema-Guide-MPU"
        bannerAdView.rootViewController = self
        bannerAdView.delegate = self
        bannerAdView.load(GADRequest())
        contentView.addSubview(bannerAdView)
    
       
//
//        let customAdSize = GADAdSize(size: CGSize(width: 300, height: 250), flags: 1)
//        let bannerView : DFPBannerView = DFPBannerView(adSize: customAdSize, origin: CGPoint(x: ((self.view.frame.width - 300)/2 - 10), y: 0))
//        bannerView.backgroundColor = .clear
//        bannerView.delegate = self
//        bannerView.rootViewController = self
//        bannerView.adSize = customAdSize
//
//        let request = DFPRequest()
//        request.keywords = keywords
//        request.customTargeting = NSDictionary(objects:[keywords, postions], forKeys:["Keyword", "Position"] as [NSCopying]) as Dictionary
//        bannerView.load(request)
//        contentView.addSubview(bannerView)
        return contentView
    }
 
//    -(UIView*)setBannerViewFooter :(NSArray*)keywords andPosition:(NSArray<NSString*>*)postions andScreenName:(NSString*)screenName
//    {
//        UIView * footerView=[[UIView alloc]initWithFrame:CGRectMake(0,0, Screenwidth, 270)];
//        [footerView setBackgroundColor:[UIColor clearColor]];
//        GADAdSize customAdSize = GADAdSizeFromCGSize(CGSizeMake(300, 250));
//        self.bannerView=[[DFPBannerView alloc]initWithAdSize:customAdSize origin:CGPointMake((Screenwidth-300)/2-10, 0)];
//
//        //if (postions.count>0) { self.bannerView.adUnitID = MeduimRectangle_AD_UNIT_ID; }
//        //else { self.bannerView.adUnitID = MeduimRectangle_Admob_AdUnit;}
//        if ([postions containsObject:@"Pos1"] || [postions containsObject:@"Pos2"]) {
//            self.bannerView.adUnitID = MeduimRectangle_AD_UNIT_ID;
//        } else {
//            self.bannerView.adUnitID = MeduimRectangle_Admob_AdUnit;
//        }
//
//        self.bannerView.delegate = self;
//        self.bannerView.adSize=customAdSize;
//        self.bannerView.rootViewController = self;
//        DFPRequest *request = [DFPRequest request];
//        request.keywords = keywords;
//        request.customTargeting = NSDictionary(objects:[keywords, postions], forKeys:["Keyword", "Position"] as [NSCopying]) as Dictionary
//        // Initiate a generic request to load it with an ad.
//        [self.bannerView loadRequest:request];
//        [footerView addSubview:self.bannerView];
//        [self setscreenAnalyticsMetricsWithScreenName:screenName andKeywords:[keywords componentsJoinedByString:@"," ]];
//
//        return footerView;
//    }
}
