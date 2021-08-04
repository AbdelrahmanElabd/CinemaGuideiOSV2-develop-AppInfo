//
//  CinemaDetailsHeaderTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/2/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Kingfisher
import Device
import CenterAlignedCollectionViewFlowLayout

class CinemaDetailsHeaderTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var cinemaLogo: UIImageView!
    @IBOutlet weak var is3DCinema: UIImageView!
    @IBOutlet weak var cinemaTitle: UILabel!
    @IBOutlet weak var showTimesCollectionView: UICollectionView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    @IBOutlet weak var navigateToCinemaButton: UIButton!
    @IBOutlet weak var callCinemaButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var callCinemaButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var navigateToCinemaButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressFixedLabel: UILabel!
    @IBOutlet weak var showTimesFixedLabel: UILabel!
    @IBOutlet weak var buttonsContainerView: UIView!
    @IBOutlet weak var buttonsContainerViewTrailing: NSLayoutConstraint!
    @IBOutlet weak var showTimesCollectionViewHeightConstraint: NSLayoutConstraint!
    
    var showTimesArray = [[String: Any]]()
    var cinemaID = Int()
    var phoneNumbers = [String]()
    var cinemaLongtude: String!
    var cinemaLatitude: String!
    var numberOfSections = 0
    var showtimes = [String]()
    let deviceModel = Device.version()
    var timesArray = [[String]]()
    var longestArray = [String]()
    var times = [[String]]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        showTimesCollectionView.register(UINib(nibName: "ShowtimesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ShowtimesCollectionCell")
        showTimesCollectionView.delegate = self
        showTimesCollectionView.dataSource = self
        if #available(iOS 9.0, *) {
           // buttonsContainerView.semanticContentAttribute = .forceLeftToRight
           // UIView.appearance().semanticContentAttribute = .forceLeftToRight
        } else {
            // Fallback on earlier versions
        }
        var isLangChange = 0
        if let isChange = UserDefaults.standard.object(forKey: "FirstChangeLang") {
            isLangChange = Int(isChange as! NSNumber)
        }
        if CinemaGuideLangs.currentAppleLanguage() == "ar"{
            switch deviceModel {
                case .iPhone5: buttonsContainerViewTrailing.constant = self.showTimesCollectionView.frame.size.width - buttonsContainerView.frame.size.width + 20
                case .iPhone5S: buttonsContainerViewTrailing.constant = self.showTimesCollectionView.frame.size.width - buttonsContainerView.frame.size.width + 20
                case .iPhone5C: buttonsContainerViewTrailing.constant = self.showTimesCollectionView.frame.size.width - buttonsContainerView.frame.size.width + 20
                case .iPhone6: buttonsContainerViewTrailing.constant = self.showTimesCollectionView.frame.size.width - buttonsContainerView.frame.size.width + 60
                case .iPhone6S: buttonsContainerViewTrailing.constant = self.showTimesCollectionView.frame.size.width - buttonsContainerView.frame.size.width + 60
                case .iPhone7: buttonsContainerViewTrailing.constant = self.showTimesCollectionView.frame.size.width - buttonsContainerView.frame.size.width + 60
            case .iPhone6Plus: buttonsContainerViewTrailing.constant = self.showTimesCollectionView.frame.size.width - buttonsContainerView.frame.size.width + 100
            case .iPhone6SPlus: buttonsContainerViewTrailing.constant = self.showTimesCollectionView.frame.size.width - buttonsContainerView.frame.size.width + 100
            case .iPhone7Plus: buttonsContainerViewTrailing.constant = self.showTimesCollectionView.frame.size.width - buttonsContainerView.frame.size.width + 100

            default:   buttonsContainerViewTrailing.constant = self.showTimesCollectionView.frame.size.width - buttonsContainerView.frame.size.width + 80

            }
        }
        
        showTimesCollectionView.collectionViewLayout = CenterAlignedCollectionViewFlowLayout()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initHeaderCellWith(cinemaData: CinemaModel) {
        cinemaTitle.textAlignment = .center
        addressLabel.textAlignment = .center
        let imageURLsDict = cinemaData.imageUrl
        if imageURLsDict?["url"] != nil{
        let imageURLs = imageURLsDict?["url"] as! [String: Any]
        let cinemaImageURL = URL(string: "\(AppInfoHelper.getMediaBaseURL())\(imageURLs["large"] as! String)")
        cinemaLogo.kf.setImage(with: cinemaImageURL, placeholder: #imageLiteral(resourceName: "CinemaPlaceholder"), options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        }
        if !cinemaData.is3D {
            is3DCinema.isHidden = true
        }
        cinemaID = cinemaData.id
        cinemaTitle.text = cinemaData.name
        addressLabel.text = cinemaData.address
        showTimesArray = cinemaData.showTimes
        phoneNumbers = cinemaData.phoneNumbers
        cinemaLongtude = cinemaData.longitude
        cinemaLatitude = cinemaData.latitude
        
        if cinemaData.latitude == "" || cinemaData.longitude == "" {
            navigateToCinemaButton.isHidden = true
            navigateToCinemaButtonWidthConstraint.constant = 0
        }
        
        var phoneNums = ""
        for aNumber in cinemaData.phoneNumbers {
            if aNumber != "" {
                phoneNums = aNumber
            }
        }
        if phoneNums == "" {
            callCinemaButton.isHidden = true
            callCinemaButtonWidthConstraint.constant = 0
        }
        if showTimesArray.count != 0 {
            for item in showTimesArray {
                if item["times"] != nil{
                let times = item["times"] as! [String]
                timesArray.append(times)
                }
            }
            if timesArray != nil && timesArray.count>0{
            longestArray = timesArray.max(by: { $0.count < $1.count })!
            }
            for item in showTimesArray {
                if item["times"] != nil{
                var time = item["times"] as! [String]
                time = time.compactMap { localizeTim($0) }
                if time.count >= 5 {
                    showTimesCollectionViewHeightConstraint.constant = CGFloat(((showTimesArray.count + 1) * 20)) + 50
                } else {
                    showTimesCollectionViewHeightConstraint.constant = CGFloat((showTimesArray.count * 20) + 40)
                }
                for i in 0 ... longestArray.count {
                    if longestArray.count != time.count {
                        time.append("")
                    } else {
                        times.append(time)
                        break
                    }
                }
            }
        }
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return showTimesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return longestArray.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let headerCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowtimesCollectionCell", for: indexPath) as! ShowtimesCollectionViewCell
            let aShowTime = showTimesArray[indexPath.section]
            if aShowTime["price"] != nil{
                let price = aShowTime["price"] as! Int
                headerCell.cellBackgroundView.backgroundColor = #colorLiteral(red: 0.9239932299, green: 0.368311584, blue: 0.3515627384, alpha: 1)
                headerCell.cellLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                let defaultValue = NSLocalizedString("le", comment: "defaultCurrency");
                let currencey:String = (UserDefaults.standard.object(forKey: "Currency") ?? defaultValue.uppercased()) as! String
                headerCell.cellLabel.text = "\(localizeNum(price)!) \(NSLocalizedString(currencey, comment: ""))"
            }
            return headerCell
        }
        let showtimeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowtimesCollectionCell", for: indexPath) as! ShowtimesCollectionViewCell
        showtimes = times[indexPath.section]
        if showtimes[indexPath.row - 1] == "" {
            showtimeCell.cellBackgroundView?.backgroundColor = Color.clear
            showtimeCell.cellLabel.text = ""
        } else {
            showtimeCell.cellBackgroundView?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            showtimeCell.cellLabel.text = showtimes[indexPath.row - 1]
        }
        return showtimeCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSize(width: 50, height: 20)
        }
        return CGSize(width: 60, height: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
    
    @IBAction func addCinemaToFavoritesButtonPressed(_ sender: UIButton) {
//        if sender.tag == 1 {
//            sender.setImage(#imageLiteral(resourceName: "AddedToFavorites"), for: .normal)
//            sender.tag = 2
//        } else if sender.tag == 2 {
//            sender.setImage(#imageLiteral(resourceName: "AddToFavoriteIcon"), for: .normal)
//            sender.tag = 1
//        }
//        NotificationCenter.default.post(name: Notification.Name("addCinemaToFavorites"), object: cinemaID, userInfo: ["Button":sender])
//        //NotificationCenter.default.post(name: Notification.Name("addCinemaToFavorites"), object: cinemaID)
    }
    
    @IBAction func navigateToCinemaButtonPressed(_ sender: UIButton) {
        let cinemaCoordinates = ["Longitude": cinemaLongtude, "Latitude": cinemaLatitude]
        NotificationCenter.default.post(name: Notification.Name("navigateToCinema"), object: cinemaCoordinates)
    }
    
    @IBAction func callCinemaButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("callCinema"), object: phoneNumbers)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name("shareCinema"), object: cinemaLogo.image)
    }
}
