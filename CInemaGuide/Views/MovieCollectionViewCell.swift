//
//  MovieCollectionViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/8/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher

class MovieCollectionViewCell: UICollectionViewCell {

    //MARK: - Properties
    @IBOutlet weak var moviePosterImageView: UIImageView!
    @IBOutlet weak var movieNameLabel: UILabel!
    @IBOutlet weak var isPopularImageView: UIImageView!
    
    //MARK: - Cell Lifecycle Function
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    //MARK: - Initializing Cell Function
    func initCellWith(movieData: MovieModel) {
        //FIXME: Change Indicator Type
        moviePosterImageView.kf.indicatorType = .activity
        let poster = movieData.poster
        let posterURLs = poster?["url"] as! [String : Any]
        let posterURL = URL(string: "\(AppInfoHelper.getMediaBaseURL())\(posterURLs["large"] as? String ?? "")")
        moviePosterImageView.kf.setImage(with: posterURL, placeholder: #imageLiteral(resourceName: "PlaceholderPortrait"), options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        movieNameLabel.text = movieData.title
        if !movieData.isRated {
            isPopularImageView.isHidden = true
        } else {
            isPopularImageView.isHidden = false
        }
    }
}
