//
//  LanguagesAndCountriesTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 1/16/18.
//  Copyright © 2018 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher

class LanguagesAndCountriesTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var isSelectedImageView: UIImageView!
    @IBOutlet weak var cellImageWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        isSelectedImageView.isHidden = true
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func initCellWith(imageURL: String, labelText: String) {
        let url = URL(string: imageURL)
        if imageURL == "" {
            cellImageWidthConstraint.constant = 0
        } else {
            cellImageWidthConstraint.constant = 20
        }
        cellImageView.kf.indicatorType = .activity
        cellImageView.kf.setImage(with: url, placeholder: nil, options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        cellLabel.text = labelText
    }
}
