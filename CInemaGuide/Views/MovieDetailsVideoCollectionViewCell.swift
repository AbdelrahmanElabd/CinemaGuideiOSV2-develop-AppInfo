//
//  MovieDetailsVideoCollectionViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/4/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher

class MovieDetailsVideoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var videoThumbImageView: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var selectedTrailerURL = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        overlayView.isHidden = true
    }

    func initCellWith(videoThumbURLString: String, videoURLString: String) {
        selectedTrailerURL = videoURLString
        videoThumbImageView.kf.indicatorType = .activity
        let imageURL = URL(string: videoThumbURLString)
        videoThumbImageView.kf.setImage(with: imageURL, placeholder: #imageLiteral(resourceName: "PlaceholderPortrait"), options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        overlayView.isHidden = false
    }
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("OpenTrailerVideo"), object: selectedTrailerURL)
    }
}
