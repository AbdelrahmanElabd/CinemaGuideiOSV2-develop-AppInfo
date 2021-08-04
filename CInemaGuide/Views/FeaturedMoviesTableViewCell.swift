//
//  FeaturedMoviesTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/11/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher

class FeaturedMoviesTableViewCell: UITableViewCell {

    @IBOutlet weak var movieCoverImageView: UIImageView!
    @IBOutlet weak var reviewedView: UIView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        movieTitleLabel.sizeToFit()
        reviewedView.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    func initCellWith(movieData: MovieModel) {
        //FIXME: Change Indicator Type
        movieCoverImageView.kf.indicatorType = .activity
        let poster = movieData.poster
        let posterURLs = poster?["url"] as! [String : Any]
        let posterURL = URL(string: "\(AppInfoHelper.getMediaBaseURL())\(posterURLs["large"] as? String ?? "")")
        movieCoverImageView.kf.setImage(with: posterURL, placeholder: #imageLiteral(resourceName: "PlaceholderLabdscape"), options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        movieTitleLabel.text = movieData.title
        if movieData.isReviewed {
            reviewedView.isHidden = true
        } else {
            reviewedView.isHidden = false
        }
    }
}
