//
//  SortingFilterView.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/14/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import AwesomeCache

@objc protocol SortingViewDelegate {
    func setSorting(sortingType: String)
    func okButtonPressed()
    func cancelButtonPressed()
}

class SortingFilterView: UIView {
    
    @IBOutlet weak var azButton: UIButton!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var releaseDateButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!

    weak var delegate: SortingViewDelegate?
    var selectedSortingType = ""
    let lastState = try! Cache<NSString>(name: "SortingLastState")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let lastStateSort = lastState["SortingLastState"] {
            if lastStateSort == "rate" {
                setRatingButton()
            } else if lastStateSort == "date" {
                setReleaseDateButton()
            } else {
                setAZButton()
            }
        } else {
            setAZButton()
        }
    }
    
    @IBAction func azButtonPressed(_ sender: UIButton) {
        lastState["SortingLastState"] = "az"
        setAZButton()
    }
    
    @IBAction func ratingButtonPressed(_ sender: UIButton) {
        lastState["SortingLastState"] = "rate"
        setRatingButton()
    }
    
    @IBAction func releaseDateButtonPressed(_ sender: UIButton) {
        lastState["SortingLastState"] = "date"
        setReleaseDateButton()
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        delegate?.okButtonPressed()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        delegate?.cancelButtonPressed()
    }
    
    
    func setAZButton() {
        azButton.setTitleColor(#colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1), for: .normal)
        azButton.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
        ratingButton.setTitleColor(#colorLiteral(red: 0.5058823529, green: 0.5098039216, blue: 0.5176470588, alpha: 1), for: .normal)
        ratingButton.backgroundColor = #colorLiteral(red: 0.9120118022, green: 0.9053018689, blue: 0.8958137631, alpha: 1)
        releaseDateButton.setTitleColor(#colorLiteral(red: 0.5058823529, green: 0.5098039216, blue: 0.5176470588, alpha: 1), for: .normal)
        releaseDateButton.backgroundColor = #colorLiteral(red: 0.9120118022, green: 0.9053018689, blue: 0.8958137631, alpha: 1)
        selectedSortingType = "az"
        delegate?.setSorting(sortingType: selectedSortingType)
    }
    
    func setRatingButton() {
        ratingButton.setTitleColor(#colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1), for: .normal)
        ratingButton.backgroundColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
        azButton.setTitleColor(#colorLiteral(red: 0.5058823529, green: 0.5098039216, blue: 0.5176470588, alpha: 1), for: .normal)
        azButton.backgroundColor = #colorLiteral(red: 0.9120118022, green: 0.9053018689, blue: 0.8958137631, alpha: 1)
        releaseDateButton.setTitleColor(#colorLiteral(red: 0.5058823529, green: 0.5098039216, blue: 0.5176470588, alpha: 1), for: .normal)
        releaseDateButton.backgroundColor = #colorLiteral(red: 0.9120118022, green: 0.9053018689, blue: 0.8958137631, alpha: 1)
        selectedSortingType = "rate"
        delegate?.setSorting(sortingType: selectedSortingType)
    }
    
    func setReleaseDateButton() {
        releaseDateButton.setTitleColor(#colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1), for: .normal)
        releaseDateButton.backgroundColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
        azButton.setTitleColor(#colorLiteral(red: 0.5058823529, green: 0.5098039216, blue: 0.5176470588, alpha: 1), for: .normal)
        azButton.backgroundColor = #colorLiteral(red: 0.9120118022, green: 0.9053018689, blue: 0.8958137631, alpha: 1)
        ratingButton.setTitleColor(#colorLiteral(red: 0.5058823529, green: 0.5098039216, blue: 0.5176470588, alpha: 1), for: .normal)
        ratingButton.backgroundColor = #colorLiteral(red: 0.9120118022, green: 0.9053018689, blue: 0.8958137631, alpha: 1)
        selectedSortingType = "date"
        delegate?.setSorting(sortingType: selectedSortingType)
    }
}
