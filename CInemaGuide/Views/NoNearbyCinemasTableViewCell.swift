//
//  NoNearbyCinemasTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/17/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class NoNearbyCinemasTableViewCell: UITableViewCell {

    @IBOutlet weak var dataLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
