//
//  DefaultFilterTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/16/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class DefaultFilterTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var markImg: UIImageView!
    @IBOutlet weak var markWidthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        if CinemaGuideLangs.currentAppleLanguage() == "ar" && filterNameLabel.text != nil{
            filterNameLabel.textAlignment = .right
        }
        else{
            filterNameLabel.textAlignment = .left

        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
