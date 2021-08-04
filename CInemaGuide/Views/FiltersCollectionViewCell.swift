//
//  FiltersCollectionViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/20/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class FiltersCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var arrowDownImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func initCellWith(filter: String, isSelectable: Bool) {
        if !isSelectable {
            arrowDownImage.isHidden = true
        }
        filterLabel.text = filter
    }
}
