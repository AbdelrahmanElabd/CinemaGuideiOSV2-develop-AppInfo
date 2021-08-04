//
//  NearbyCinemasTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/11/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher

class NearbyCinemasTableViewCell: UITableViewCell {

    @IBOutlet weak var cinemaLogoImageView: UIImageView!
    @IBOutlet weak var cinemaNameLabel: UILabel!
    @IBOutlet weak var cinemaAddressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var numberOfMoviesLabel: UILabel!
    @IBOutlet weak var moviesLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    func initCellWith(cinemaData: CinemaModel) {
        //FIXME: Change indicator type
        cinemaLogoImageView.kf.indicatorType = .activity
        let cinemaImage = cinemaData.imageUrl
        let imageURLs = cinemaImage?["url"] as! [String : Any]
        let cinemaLogoURL = URL(string: "\(AppInfoHelper.getMediaBaseURL())\(imageURLs["large"] as? String ?? "")")
        cinemaLogoImageView.kf.setImage(with: cinemaLogoURL, placeholder: #imageLiteral(resourceName: "CinemaPlaceholder"), options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        cinemaNameLabel.text = cinemaData.name
        cinemaAddressLabel.text = cinemaData.address
        if cinemaData.distance >= 1000 {
            let distance = localizeNum(String(format: "%.2f", ceil(cinemaData.distance)/1000)) ?? ""
            if CinemaGuideLangs.currentAppleLanguage() == "ar" {
                distanceLabel.text = "\(distance) كم"
            } else {
                distanceLabel.text = "\(distance) KM"
            }
        } else {
            let distance = localizeNum(String(format: "%.2f", ceil(cinemaData.distance))) ?? ""
            if CinemaGuideLangs.currentAppleLanguage() == "ar" {
                distanceLabel.text = "\(distance) م"
            } else {
                distanceLabel.text = "\(distance) M"
            }
        }
        numberOfMoviesLabel.text = "\(cinemaData.moviesCount ?? 0)"
        if cinemaData.movies.count >= 1 {
            if CinemaGuideLangs.currentAppleLanguage() == "ar" {
                moviesLabel.text = "فيلم"
            } else {
                moviesLabel.text = "Movie"
            }
        } else {
            if CinemaGuideLangs.currentAppleLanguage() == "ar" {
                moviesLabel.text = "افلام"
            } else {
                moviesLabel.text = "Movies"
            }
        }
    }
}
