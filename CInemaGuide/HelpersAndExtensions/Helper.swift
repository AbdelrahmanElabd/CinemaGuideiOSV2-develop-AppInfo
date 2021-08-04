//
//  Helper.swift
//  CInemaGuide
//
//  Created by Nada Gamal Mohamed on 7/12/18.
//  Copyright © 2018 Sarmady. All rights reserved.
//

import Foundation
import GoogleMobileAds
public struct Helper {
    static var intersistialPattern:[Int]!
    static var currentAdIndex = 0
    static var selectedIndex = 0 ;
    static var interstitial: GAMInterstitialAd!
    static var appInfo: AppInfo!
    static var favCinemas: [CinemaModel]!
}
