//
//  MediumRectTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/20/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import GoogleMobileAds

class MediumRectTableViewCell: UITableViewCell, GADBannerViewDelegate {

    @IBOutlet weak var mediumRectView: GADBannerView!
    @IBOutlet weak var adSpaceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCellWith(adUnitID: String) {
        mediumRectView.adSize = kGADAdSizeMediumRectangle
        mediumRectView.adUnitID = adUnitID
        mediumRectView.delegate = self
        mediumRectView.load(GADRequest())
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        adSpaceLabel.isHidden = true
    }
    
//    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        print(error.localizedDescription)
//        adSpaceLabel.isHidden = false
//    }
}
