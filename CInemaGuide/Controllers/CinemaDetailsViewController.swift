//
//  CinemaDetailsViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/3/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import AwesomeCache
import TBEmptyDataSet
import CoreLocation
import MapKit
import GoogleMobileAds
//import Instabug
import Toast_Swift
class CinemaDetailsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate {

    //MARK: - Properties
    @IBOutlet weak var navigationBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var cinemaDetailsTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sponsorImageView: UIImageView!
    @IBOutlet weak var sponsorImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    var cinemaID: Int!
    var cinemaData: CinemaModel!
    var moviesArray = [MovieModel]()
    var cinemaLongitude: String!
    var cinemaLatitude: String!
    var phoneNumbers: [String]!
    var errorMessage = ""
    var favoriteCinemasIDsArray = [Int]()
    var selectedMovieId = 0
    var selectedCinemaID = 0
    var isCinemaSponsored = false
    var isPushMovie = false
    var isPushCinema = false
    var pushMovieID = Int()
    var pushCinemaID = Int()
    let activityIndicatorView = UINib(nibName: "CustomActivityIndicator", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? CustomActivityIndicator
    var isMPUEnabled = false
    var isInterestatialEnabled = false
    var isSponsorEnabled = false
    let dynamicView=UIView(frame: CGRect(x:0,y: 0, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                navBarHeightConstraint.constant = navBarHeightConstraint.constant + 20
            default:
                print("unknown")
            }
        }
        
        //Effective Measure
        //let tracker = EmTracker()
        //tracker.verbose = true
        //tracker.configure("CinemaGuideMobileApp", tld: "filbalad.com", sdkKey: "2da9a01d-0fc7-4902-8d34-9f37d5bc55f6")
        //tracker.trackDefault()
        
        cinemaDetailsTableView.register(UINib(nibName: "CinemaDetailsHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "CinemaDetailsHeaderCell")
        cinemaDetailsTableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
        cinemaDetailsTableView.register(UINib(nibName: "MovieDetailsHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieDetailsSectionHeader")
        cinemaDetailsTableView.register(UINib(nibName: "MediumRectTableViewCell", bundle: nil), forCellReuseIdentifier: "MediumRectCell")
        isMPUEnabled = AppInfoHelper.isMpuEnabled()

        cinemaDetailsTableView.isHidden = true
        let frame = CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50)
        activityIndicatorView?.frame = frame
        self.view.addSubview(activityIndicatorView!)
        if CinemaGuideLangs.currentAppleLanguage() == "ar" {
            backButton.setImage(#imageLiteral(resourceName: "ArabicBackButton"), for: .normal)
        }
        self.sponsorImageViewHeightConstraint.constant = 0
        if AppInfoHelper.isVersionSponsorsed(){
            if AppInfoHelper.isCinemaSponsored(cinemaID: cinemaID){
                self.sponsorImageView.isHidden = false
                sponsorImageView.kf.setImage(with: AppInfoHelper.getCinemaSponsor(cinemaID: cinemaID), placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: { (image, error, cahce, url) in
                    if (error != nil) {
                        self.sponsorImageView.isHidden = true
                        self.sponsorImageViewHeightConstraint.constant = 0
                    }
                    if (image != nil) {
                        self.sponsorImageViewHeightConstraint.constant = ((image?.size.height)!/UIScreen.main.scale)
                    }
                })
            }
            else if AppInfoHelper.isCountrySplashSponsored(){
                self.sponsorImageView.isHidden = false
                sponsorImageView.kf.setImage(with: AppInfoHelper.getCountryStripSponsorImageURL(), placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: { (image, error, cahce, url) in
                    if (error != nil) {
                        self.sponsorImageView.isHidden = true
                        self.sponsorImageViewHeightConstraint.constant = 0
                    }
                    if (image != nil) {
                        self.sponsorImageViewHeightConstraint.constant = ((image?.size.height)!/UIScreen.main.scale)
                    }
                })
            }
            else if AppInfoHelper.isAppSponsored(){
                self.sponsorImageView.isHidden = false
                sponsorImageView.kf.setImage(with: AppInfoHelper.getStripSponsorImageURL(), placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: { (image, error, cahce, url) in
                    if (error != nil) {
                        self.sponsorImageView.isHidden = true
                        self.sponsorImageViewHeightConstraint.constant = 0
                    }
                    if (image != nil) {
                        self.sponsorImageViewHeightConstraint.constant = ((image?.size.height)!/UIScreen.main.scale)
                    }
                })
            }
        }
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Set Our Fake NavigationBar Header Background Height
        navigationBannerHeightConstraint?.constant = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        pageTitleLabel.textAlignment = .center
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let isUniversalLink = appDelegate.isUniversalLink
        if isUniversalLink {
            if let movieID = appDelegate.universalLinkMovieID {
                selectedMovieId = movieID
                self.performSegue(withIdentifier: "NavigateToMovie", sender: self)
            } else if let cinemaID = appDelegate.universalLinkCinemaID {
                selectedCinemaID = cinemaID
                self.cinemaDetailsTableView.isHidden = true
                self.getCinemaDetails(cinemaID: self.selectedCinemaID)
            } else if appDelegate.isMoviesList {
                self.tabBarController?.selectedIndex = 1
            } else if appDelegate.isCinemasList {
                self.tabBarController?.selectedIndex = 2
            }
        }
        
        

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
       //NotificationCenter.default.addObserver(self, selector: #selector(self.addCinemaToFavorites(notification:)), name: Notification.Name("addCinemaToFavorites"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.navigateToCinema(notification:)), name: Notification.Name("navigateToCinema"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.callCinema(notification:)), name: Notification.Name("callCinema"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.shareCinema(notification:)), name: Notification.Name("shareCinema"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMovie(notification:)), name: Notification.Name("OpenMovieFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinema(notification:)), name: Notification.Name("OpenCinemaFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMoviesList(notification:)), name: Notification.Name("OpenMoviesListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinemasList(notification:)), name: Notification.Name("OpenCinemasListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPushNotificationAlert(notification:)), name: Notification.Name("ShowPushNotificationAlert"), object: nil)
        
//        screenName = "iOS-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())-\(CinemaGuideLangs.currentAppleLanguage())-Cinema Details-With ID \(cinemaID ?? 0)"
        
        AnalyticsHelper.GAsetScreenName(With: "Cinema Details-With ID \(cinemaID ?? 0)")
        AnalyticsHelper.firebaseSetScreenName(With: "Cinema Details-With ID \(cinemaID ?? 0)", className: "CinemaDetailsViewController.swift")
        AnalyticsHelper.firebaseLogEvent(itemID: "Cinema Details View Controller", itemName: "Cinema", cType: "View Cinema", screenName: "Cinema Details-With ID \(cinemaID ?? 0)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if UserDefaults.standard.object(forKey:"FavsCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())") != nil{
            let favorites = UserDefaults.standard.object(forKey:"FavsCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())") as! [Int]
            if favorites.count>0{
                favoriteCinemasIDsArray = favorites
            }
            else{
                favoriteCinemasIDsArray = []
            }
        }
        else{
            favoriteCinemasIDsArray = []
        }

        getCinemaDetails(cinemaID: cinemaID)


    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        appDelegate.isUniversalLink=false
        NotificationCenter.default.removeObserver(self)
    }
    @objc func getCinemaDetails(cinemaID: Int) {
        activityIndicatorView?.startActivityIndicator()
        APIManager.getCinemaDetails(cinemaID: cinemaID, success: { (cinema: CinemaModel) -> Void in
            if cinema.id != 0{
            self.cinemaData = cinema
            self.moviesArray = self.cinemaData.movies
            self.pageTitleLabel.text = self.cinemaData.name
            self.cinemaDetailsTableView.isHidden = false
            self.cinemaDetailsTableView.reloadData()
            DispatchQueue.main.async {
                self.activityIndicatorView?.stopActivityIndicator()
            }
            }
            else{
//                let alert = UIAlertController(title: "", message:NSLocalizedString("No data found, please try again later", comment: "No Data Found") , preferredStyle: UIAlertController.Style.alert)
//                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Key"), style: UIAlertAction.Style.default, handler: nil))
//                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.async {
                    self.activityIndicatorView?.stopActivityIndicator()
                    self.getCinemaDetails(cinemaID: self.selectedCinemaID)
                    
                }
            }
        }) { (error: NSError?) -> Void in
            print(error?.description ?? "")
            
            self.activityIndicatorView?.stopActivityIndicator()
            
            let width = UIScreen.main.bounds.width
            
            let label = UILabel(frame: CGRect(x:0,y: UIScreen.main.bounds.midY, width:width, height:20))
            let tryaginBTN = UIButton(frame: CGRect(x:0,y: (UIScreen.main.bounds.midY + 40), width:width, height:20))
            tryaginBTN.addTarget(self, action: #selector(self.loadAgain), for: .touchUpInside)
               let emptyImage = UIImage(named: "NoDataIcon")
               let emptyImageView = UIImageView(frame: CGRect(x:0,y: 160, width:width, height:120))
               emptyImageView.image = emptyImage
            emptyImageView.contentMode = .scaleAspectFit
            self.dynamicView.addSubview(emptyImageView)
            
            let attributedString = NSMutableAttributedString(string: NSLocalizedString("No data found, please try again later", comment: ""))
            let range = (self.errorMessage as NSString).range(of: "No internet connection, please try again later")
            let font = UIFont(name: "SegoeUI-Bold", size: 16)
            attributedString.addAttributes([NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.init(red: 30/255, green: 46/255, blue: 56/255, alpha: 1)], range: range)
            label.text = attributedString.string
            tryaginBTN.setTitle("Try again", for: .normal)
            tryaginBTN.setTitleColor(.gray, for: .normal)
            self.dynamicView.backgroundColor=UIColor.clear
            label.textAlignment = .center
            self.dynamicView.addSubview(label)
            self.dynamicView.addSubview(tryaginBTN)
            self.view.addSubview(self.dynamicView)
            self.getCinemaDetails(cinemaID: self.selectedCinemaID)
            
//            Instabug.ibgLog(error?.description ?? "")

        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func loadAgain()  {
        self.dynamicView.removeFromSuperview()
        self.getCinemaDetails(cinemaID: self.selectedCinemaID)
    }
    //MARK: - Table view functions
    func numberOfSections(in tableView: UITableView) -> Int {
        if cinemaData != nil {
            return 3
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return moviesArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cinemaDetailsHeaderCell = tableView.dequeueReusableCell(withIdentifier: "CinemaDetailsHeaderCell", for: indexPath) as! CinemaDetailsHeaderTableViewCell
            cinemaDetailsHeaderCell.initHeaderCellWith(cinemaData: cinemaData)
            cinemaDetailsHeaderCell.addToFavoritesButton .addTarget(self, action: #selector(addtoFavoritesBtnAction), for: .touchUpInside)
            cinemaDetailsHeaderCell.addToFavoritesButton.setImage(UIImage(named: "AddToFavoriteIcon"), for: .normal)

            if favoriteCinemasIDsArray.count != 0 {
                for id in favoriteCinemasIDsArray {
                    if cinemaID == id {
                        cinemaDetailsHeaderCell.addToFavoritesButton.setImage(UIImage(named: "AddedToFavorites"), for: .normal)
                        cinemaDetailsHeaderCell.addToFavoritesButton.tag = 2
                    }
                }
            }
            else{
                cinemaDetailsHeaderCell.addToFavoritesButton.setImage(#imageLiteral(resourceName: "AddToFavoriteIcon"), for: .normal)

            }
            return cinemaDetailsHeaderCell
        } else if indexPath.section == 1 {
            let mediumRectAdCell = tableView.dequeueReusableCell(withIdentifier: "MediumRectCell", for: indexPath) as! MediumRectTableViewCell
            if isMPUEnabled {
                mediumRectAdCell.mediumRectView.rootViewController = self
                mediumRectAdCell.initCellWith(adUnitID: "/7524/Mobile-FilBalad.com/Cinema-Guide-MPU")
            } else {
                mediumRectAdCell.adSpaceLabel.isHidden = true
            }
            return mediumRectAdCell
        } else {
            let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
            let defaultValue = NSLocalizedString("le", comment: "defaultCurrency");
            let currencey:String = (UserDefaults.standard.object(forKey: "Currency") ?? defaultValue.uppercased())as! String
            movieCell.initCellWithData(movieData: moviesArray[indexPath.row])
            movieCell.playingInLabel.text = ""
            var showTimesString = ""
            var times = [String]()
            var price = "" //0
            var prices = [String]() //[Int]() //NSMutableArray()
            var timesString = ""
            for showTimeData in moviesArray[indexPath.row].showtimes {
                times = showTimeData["times"] as! [String]
                price = localizeNum(showTimeData["price"] as! Int)! //showTimeData["price"] as! Int
                prices.append(price)
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
                let range = str.range(of: "\(aPrice) \(NSLocalizedString(currencey, comment: ""))") //str.range(of: "\(aPrice)LE")
                attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(red: 228.0 / 255.0, green: 70.0 / 255.0, blue: 72.0 / 255.0, alpha: 1.0), range: range)
            }
            //movieCell.movieActorsLabel.font = UIFont(name: "SegoeUI-Bold", size: 10)
            movieCell.movieActorsLabel.attributedText = attributedString
            return movieCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 440
        } else if indexPath.section == 1 {
            if !isMPUEnabled {
                return 0
            }
            return 266
        } else {
           return 155
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 1 {
            return 0.000000001
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            return 49
        }
        return 0.00000001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderCell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailsSectionHeader") as! MovieDetailsHeaderTableViewCell
        if section == 2 {
            sectionHeaderCell.sectionHeaderLabel.text = NSLocalizedString("Now Playing", comment: "Now Playing Movies")
        } else {
            sectionHeaderCell.sectionHeaderLabel.text = ""
        }
        return sectionHeaderCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
                let theCount = count as! NSNumber
                var countInt = Int(theCount)
                countInt = countInt + 1
                UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
            }
            let movie = cinemaData.movies[indexPath.row]
            selectedMovieId = movie.id
            self.performSegue(withIdentifier: "NavigateToMovie", sender: self)
        }
    }
    func getFavoriteCinemaIndex(cinemaId:Int) -> Int {
        for index in 0 ... (Helper.favCinemas?.count)!-1{
            let cinema = Helper.favCinemas![index]
            if cinema.id == cinemaId{
                return index
            }
        }
        return 0
    }
    
    
    
    
    //MARK: - Actions and navigations
    
    
    @objc func addtoFavoritesBtnAction(sender:UIButton){
        func Alert(message: String) {
            let alert = UIAlertController(title: message, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        if sender.tag == 1 {
            sender.setImage(#imageLiteral(resourceName: "AddedToFavorites"), for: .normal)
            sender.tag = 2
            let defaults = UserDefaults.standard
            favoriteCinemasIDsArray.append(cinemaID)
            defaults.set(favoriteCinemasIDsArray, forKey: "FavsCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())")
            defaults.synchronize()
            Helper.favCinemas.append(cinemaData)
            Alert(message: NSLocalizedString("Cinema is added to favorites successfully", comment: "Cinema is added to favorites successfully"))
        } else if sender.tag == 2 {
            sender.setImage(#imageLiteral(resourceName: "AddToFavoriteIcon"), for: .normal)
            sender.tag = 1
            var isAdded = false
            for id in favoriteCinemasIDsArray {
                if cinemaID == id {
                   let defaults = UserDefaults.standard
                    var index = getFavoriteCinemaIndex(cinemaId: cinemaID)
                    Helper.favCinemas.remove(at: index)
                    favoriteCinemasIDsArray.remove(at: index)
                    defaults.set(favoriteCinemasIDsArray, forKey: "FavsCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())")
                    defaults.synchronize()
                    isAdded = true
                    break

                }
            }
            Alert(message: NSLocalizedString("Cinema is removed from favorites", comment: "Cinema is removed from favorites"))
        }
        
        AnalyticsHelper.GALogEventWith(name: "Cinema Details-With ID \(cinemaID) Add To Favorites Button", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Cinema Details", itemName: "Cinema Details-With ID \(cinemaID) Add To Favorites Button", cType: "Button Action", screenName: "Cinema Details")
    }

    @objc func navigateToCinema(notification: Notification) {
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        
        
        let alert = UIAlertController(title: NSLocalizedString("Selection", comment: "Selection Key"), message: NSLocalizedString("Select Navigation App", comment: "Select Nav Key"), preferredStyle: .actionSheet)
        let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { (openAppleMaps) in
            let cinemaCoordinates = notification.object as! [String: Any]
            let latitude = Double(cinemaCoordinates["Latitude"] as! String)
            let longitude = Double(cinemaCoordinates["Longitude"] as! String)
            let regionDistance:CLLocationDistance = 10000
            if longitude != nil && latitude != nil {
                let coordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
                let regionSpan = MKCoordinateRegion.init(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = self.cinemaData.name
                mapItem.openInMaps(launchOptions: options)
            }
        }
        alert.addAction(appleMapsAction)
        let cinemaCoordinates = notification.object as! [String: Any]
        let latitude = Double(cinemaCoordinates["Latitude"] as! String)
        let longitude = Double(cinemaCoordinates["Longitude"] as! String)
        let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latitude ?? 0),\(longitude ?? 0)&directionsmode=driving")
        if UIApplication.shared.canOpenURL(url!) {
            let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default) { (openGoogleMaps) in
                UIApplication.shared.openURL(url!)
            }
            alert.addAction(googleMapsAction)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Key"), style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
        AnalyticsHelper.GALogEventWith(name: "Cinema Details-With ID \(cinemaID) Navigate To Cinema Button", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Cinema Details", itemName: "Cinema Details-With ID \(cinemaID) Navigate To Cinema Button", cType: "Button Action", screenName: "Cinema Details")
    }
    
    @objc func callCinema(notification: Notification) {
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        let actionSheet = UIActionSheet(title: "Call Cinema", delegate: self, cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel Key"), destructiveButtonTitle: nil)
        for phoneNumber in cinemaData.phoneNumbers {
            if phoneNumber != "" {
                actionSheet.addButton(withTitle: phoneNumber)
            }
        }
        actionSheet.show(in: self.view)
    }
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex != 0 {
            let phonesArray = NSMutableArray()
            for phoneNumber in cinemaData.phoneNumbers {
                if phoneNumber != "" {
                    phonesArray.add(phoneNumber)
                }
            }
            if let url = URL(string: "tel://\(phonesArray[buttonIndex - 1])"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
                
                AnalyticsHelper.GALogEventWith(name: "Cinema Details-With ID \(cinemaID) Call Cinema Button", category: "Button Action")
                AnalyticsHelper.firebaseLogEvent(itemID: "Cinema Details", itemName: "Cinema Details-With ID \(cinemaID) Call Cinema Button", cType: "Button Action", screenName: "Cinema Details")
            }
        }
    }
    
    @objc func shareCinema(notification: Notification) {
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        let shareImage = notification.object as! UIImage
        let shareText = "Check out \(cinemaData.name ?? "") cienma on filbalad.com"
        let shareURL = URL(string: "https://www.filbalad.com/ar/eg/cinemas/details/\(cinemaData.id ?? 0)")
        print(shareURL)
        let vc = UIActivityViewController(activityItems: [shareText , shareURL ?? "", shareImage], applicationActivities: [])
        present(vc, animated: true, completion: nil)
        
        AnalyticsHelper.GALogEventWith(name: "Cinema Details-With ID \(cinemaID) Share Cinema Button", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Cinema Details", itemName: "Cinema Details-With ID \(cinemaID) Share Cinema Button", cType: "Button Action", screenName: "Cinema Details")
    }
    
    @objc func openMovie(notification: Notification) {
        selectedMovieId = notification.object as! Int
        self.performSegue(withIdentifier: "NavigateToMovie", sender: self)
    }
    
    @objc func openCinema(notification: Notification) {
        selectedCinemaID = notification.object as! Int
        cinemaDetailsTableView.isHidden = true
        getCinemaDetails(cinemaID: selectedCinemaID)
    }
    
    @objc func openMoviesList(notification: Notification) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc func openCinemasList(notification: Notification) {
        self.tabBarController?.selectedIndex = 2
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NavigateToMovie" {
            let destination = segue.destination as! MovieDetailsViewController
            destination.movieID = selectedMovieId
        }
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Recieved push
    @objc func showPushNotificationAlert(notification: Notification) {
        let userInfo = notification.object as! [String: Any]
        let pushData = userInfo["aps"] as! [String: Any]
        let alertData = pushData["alert"] as! [String: Any]
        let notificationBody = alertData["body"] as! String
        var alertTitle = NSLocalizedString("Notification", comment: "Notification Key")
        if let type = userInfo["type"] {
            let pushType = type as! String
            if pushType == "1" {
                alertTitle = NSLocalizedString("Movie", comment: "Movie Key")
                if let id = userInfo["id"] {
                    pushMovieID = Int(id as! String)!
                    isPushMovie = true
                    isPushCinema = false
                }
            } else if pushType == "2" {
                if let id = userInfo["id"] {
                    alertTitle = NSLocalizedString("Cinema", comment: "A Cinema Key")
                    pushCinemaID = Int(id as! String)!
                    isPushMovie = false
                    isPushCinema = true
                }
            }
        }
        let alertController = UIAlertController(title: alertTitle, message: notificationBody, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Key"), style: .cancel) { (cancelAction : UIAlertAction) in
            alertController.dismiss(animated: true, completion: nil)
        }
        let showAction = UIAlertAction(title: NSLocalizedString("Show", comment: "Show Key"), style: .default) { (showAction: UIAlertAction) in
            if self.isPushMovie {
                self.selectedMovieId = self.pushMovieID
                self.performSegue(withIdentifier: "NavigateToMovie", sender: self)
            }
            if self.isPushCinema {
                self.selectedCinemaID = self.pushCinemaID
                self.cinemaDetailsTableView.isHidden = true
                self.getCinemaDetails(cinemaID: self.selectedCinemaID)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(showAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
   
}
