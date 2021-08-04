//
//  MovieDetailsImagesCollectionViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/4/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher

class MovieDetailsImagesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func initCellWith(imageURL: String, imageCaption: String) {
        movieImageView.kf.indicatorType = .activity
        let imageURL = URL(string: imageURL)
        movieImageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "PlaceholderPortrait"), options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
    }
}
