//
//  MovieTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/12/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher

class MovieTableViewCell: UITableViewCell {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var heighlyRatedImage: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieGenersLabel: UILabel!
    @IBOutlet weak var movieActorsLabel: UILabel!
    @IBOutlet weak var reviewedView: UIView!
    @IBOutlet weak var playingInLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    func initCellWithData(movieData: MovieModel) {
        //FIXME: Change indicator type
        movieImageView.kf.indicatorType = .activity
        let poster = movieData.poster
        let posterURLs = poster?["url"] as! [String : Any]
        let posterURL = URL(string: "\(AppInfoHelper.getMediaBaseURL())\(posterURLs["large"] as? String ?? "")")
        movieImageView.kf.setImage(with: posterURL, placeholder: #imageLiteral(resourceName: "PlaceholderPortrait"), options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        if movieData.isRated {
            heighlyRatedImage.isHidden = false
        } else {
            heighlyRatedImage.isHidden = true
        }
        if movieData.isReviewed {
            reviewedView.isHidden = false
        } else {
            reviewedView.isHidden = true
        }
        movieTitleLabel.text = movieData.title
        var genresString = ""
        for genre in movieData.genres {
            let theGenre = genre as! [String: Any]
            if genresString != "" {
                genresString = genresString + " / \(theGenre["name"] ?? "")"
            } else {
                genresString = theGenre["name"] as? String ?? ""
            }
        }
        movieGenersLabel.text = genresString
        var actorsString = ""
        for actor in movieData.actors {
            if actorsString != "" {
                actorsString = actorsString + ", \(actor["name"] ?? "")"
            } else {
                actorsString = actor["name"] as? String ?? ""
            }
        }
        movieActorsLabel.text = actorsString
        let playingAtString = NSLocalizedString("Playing in", comment: "Playing At Key")
        var cinemasString = ""
        if movieData.numberOfCinemas == 1 {
            cinemasString = NSLocalizedString("cinema", comment: "Cinema Key")
        } else {
            cinemasString = NSLocalizedString("cinemas", comment: "Cinemas Key")
        }
        playingInLabel.text = playingAtString + " \(localizeNum( movieData.numberOfCinemas) ?? String()) " + cinemasString
    }
}
