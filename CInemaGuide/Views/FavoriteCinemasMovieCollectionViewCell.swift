//
//  FavoriteCinemasMovieCollectionViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/12/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher

class FavoriteCinemasMovieCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var moviePosterImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layoutIfNeeded()
        moviePosterImageView.clipsToBounds = true
        moviePosterImageView.layer.masksToBounds = true
        moviePosterImageView.layer.cornerRadius = 8
    }

    func initCellWith(posterURLString: String) {
        let posterURL = URL(string: "\(AppInfoHelper.getMediaBaseURL())\(posterURLString)")
        moviePosterImageView.kf.indicatorType = .activity
        moviePosterImageView.kf.setImage(with: posterURL, placeholder: #imageLiteral(resourceName: "PlaceholderPortrait"), options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
    }
}
