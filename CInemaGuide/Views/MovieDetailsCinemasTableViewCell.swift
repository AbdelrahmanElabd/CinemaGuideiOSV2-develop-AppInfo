//
//  MovieDetailsCinemasTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/4/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher

class MovieDetailsCinemasTableViewCell: UITableViewCell {

    @IBOutlet weak var cinemaLogoImageView: UIImageView!
    @IBOutlet weak var cinemaNameLabel: UILabel!
    @IBOutlet weak var cinemaAddressLabel: UILabel!
    @IBOutlet weak var cinemaPricesLabel: UILabel!
    @IBOutlet weak var is3DCinemaImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCellWith(cinemaData: CinemaModel) {
        cinemaLogoImageView.kf.indicatorType = .activity
        let cinemaLogo = cinemaData.imageUrl
        let cinemLogoURLs = cinemaLogo?["url"] as! [String: Any]
        let cinemaLogoURL = URL(string: "\(AppInfoHelper.getMediaBaseURL())\(cinemLogoURLs["small"] ?? "")")
        cinemaLogoImageView.kf.setImage(with: cinemaLogoURL, placeholder: #imageLiteral(resourceName: "CinemaPlaceholder"), options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        cinemaNameLabel.text = cinemaData.name
        cinemaAddressLabel.text = cinemaData.address
        let defaultValue = NSLocalizedString("le", comment: "defaultCurrency");
        let currencey:String = (UserDefaults.standard.object(forKey: "Currency") ?? defaultValue.uppercased())as! String
         print(currencey)
        if !cinemaData.is3D {
            is3DCinemaImageView.isHidden = true
        } else {
            is3DCinemaImageView.isHidden = false
        }
        var showTimesString = ""
        var times = [String]()
        var price = "0"//0
        let prices = NSMutableArray()
        var timesString = ""
        for showTimeData in cinemaData.showTimes {
            times = showTimeData["times"] as! [String]
            price = localizeNum(showTimeData["price"] as! Int) ?? ""//showTimeData["price"] as! Int

            prices.add(price)
            if times.count != 0 {
                for aTime in times {
                    if timesString == "" {
                        timesString = localizeTim(aTime)!
                    } else {
                        timesString = timesString + " | " + localizeTim(aTime)!
                    }
                }
                if showTimesString == "" {
                    showTimesString = "\(price) \(NSLocalizedString(currencey, comment: ""))   \(timesString)"
                    
                } else {
                    //showTimesString = showTimesString + " - \(price)\(currencey) \(timesString)"
                    showTimesString = showTimesString + "\n\(price) \(NSLocalizedString(currencey, comment: ""))   \(timesString)"
                }
                timesString = String()
            }
        }
        let attributedString = NSMutableAttributedString(string: showTimesString)
        for aPrice in prices {
            let str = NSString(string: showTimesString)
            let range = str.range(of: "\(aPrice) \(NSLocalizedString(currencey, comment: ""))")
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 228.0 / 255.0, green: 70.0 / 255.0, blue: 72.0 / 255.0, alpha: 1.0), range: range)
        }
        cinemaPricesLabel.attributedText = attributedString
    }
}
