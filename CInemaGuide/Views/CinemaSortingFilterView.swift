//
//  CinemaSortingFilterView.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/17/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import AwesomeCache

@objc protocol CinemaSortingViewDelegate {
    func cinemaSortingOkButtonPressed(sortingType: String)
    func cinemaSortingCancelButtonPressed()
}

class CinemaSortingFilterView: UIView {

    @IBOutlet weak var azButton: UIButton!
    @IBOutlet weak var nearByButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: CinemaSortingViewDelegate?
    var selectedSortingType = ""
    let cinemaSortingLastState = try! Cache<NSString>(name: "CinemaSortingLastState")
    let isLocationEnabledCache = try! Cache<NSNumber>(name: "LocationEnabledCache")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let lastStateSort = cinemaSortingLastState["CinemaSortingLastState"] {
            if lastStateSort == "nearby" {
                setNearByButton()
            } else {
                setAZButton()
            }
        } else {
            if let isLocation = isLocationEnabledCache["LocationEnabledCache"] {
                let isLocationEnabled = Bool(isLocation)
                if isLocationEnabled {
                    setNearByButton()
                } else {
                    setAZButton()
                }
            } else {
                setAZButton()
            }
        }
    }
    
    @IBAction func azButtonPressed(_ sender: UIButton) {
        cinemaSortingLastState["CinemaSortingLastState"] = "az"
        setAZButton()
    }

    @IBAction func nearByButtonPressed(_ sender: UIButton) {
        if let isLocation = isLocationEnabledCache["LocationEnabledCache"] {
            let isLocationEnabled = Bool(isLocation)
            if isLocationEnabled {
                cinemaSortingLastState["CinemaSortingLastState"] = "nearby"
                setNearByButton()
            }
        }
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        delegate?.cinemaSortingOkButtonPressed(sortingType: selectedSortingType)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        delegate?.cinemaSortingCancelButtonPressed()
    }
    
    func setAZButton() {
        azButton.setTitleColor(#colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1), for: .normal)
        azButton.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
        nearByButton.setTitleColor(#colorLiteral(red: 0.5058823529, green: 0.5098039216, blue: 0.5176470588, alpha: 1), for: .normal)
        nearByButton.backgroundColor = #colorLiteral(red: 0.9120118022, green: 0.9053018689, blue: 0.8958137631, alpha: 1)
        selectedSortingType = "az"
    }
    
    func setNearByButton() {
        nearByButton.setTitleColor(#colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1), for: .normal)
        nearByButton.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
        azButton.setTitleColor(#colorLiteral(red: 0.5058823529, green: 0.5098039216, blue: 0.5176470588, alpha: 1), for: .normal)
        azButton.backgroundColor = #colorLiteral(red: 0.9120118022, green: 0.9053018689, blue: 0.8958137631, alpha: 1)
        selectedSortingType = "nearby"
    }
}
