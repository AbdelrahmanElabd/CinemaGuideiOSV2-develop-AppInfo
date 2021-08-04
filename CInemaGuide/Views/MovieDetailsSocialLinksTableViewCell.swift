//
//  MovieDetailsSocialLinksTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/26/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class MovieDetailsSocialLinksTableViewCell: UITableViewCell {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var facebookButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var twitterButton: UIButton!
    @IBOutlet weak var twitterButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var urlButton: UIButton!
    @IBOutlet weak var urlButtonWidthConstraint: NSLayoutConstraint!
    
    var facebookURL: String!
    var twitterURL: String!
    var webURL: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        facebookButton.isHidden = true
        facebookButtonWidthConstraint.constant = 0
        twitterButton.isHidden = true
        twitterButtonWidthConstraint.constant = 0
        urlButton.isHidden = true
        urlButtonWidthConstraint.constant = 0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCellWith(socialURLs: [[String: Any]], webSiteURL: String) {
        if socialURLs.count != 0 {
            for aSocilalLink in socialURLs {
                let socialLink = aSocilalLink["abbriviation"] as! String
                if (socialLink.range(of: "fb") != nil) {
                    facebookButton.isHidden = false
                    facebookButtonWidthConstraint.constant = 46
                    facebookURL = aSocilalLink["link"] as! String
                    if aSocilalLink["link"] as! String == "" {
                        facebookButton.isHidden = true
                        facebookButtonWidthConstraint.constant = 0
                    }
                } else if (socialLink.range(of: "tw") != nil) {
                    twitterButton.isHidden = false
                    twitterButtonWidthConstraint.constant = 46
                    twitterURL = aSocilalLink["link"] as! String
                    if aSocilalLink["link"] as! String == "" {
                        twitterButton.isHidden = true
                        twitterButtonWidthConstraint.constant = 0
                    }
                }
            }
            if webSiteURL != "" {
                urlButton.isHidden = false
                urlButtonWidthConstraint.constant = 46
                webURL = webSiteURL
            } else {
                urlButton.isHidden = true
                urlButtonWidthConstraint.constant = 0
            }
        }
    }
    
    @IBAction func facebookButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("OpenMovieFacebookPage"), object: facebookURL)
    }
    
    @IBAction func twitterButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("OpenMovieTwitterPage"), object: twitterURL)
    }
    
    @IBAction func urlButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("OpenMovieWebPage"), object: webURL)
    }
}
