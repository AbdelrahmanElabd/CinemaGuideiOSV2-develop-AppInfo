//
//  HomeViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/12/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import CoreLocation
import TBEmptyDataSet
import AwesomeCache
import GoogleMobileAds
import Kingfisher
//import PullToRefreshSwift
import PullToRefresh
import Instabug
import Firebase
import Toast_Swift

class HomeViewController:BaseViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, TBEmptyDataSetDelegate, TBEmptyDataSetDataSource, UIGestureRecognizerDelegate {

    //MARK: - Properties
    @IBOutlet weak var cinemaGuideNavLogo: UIImageView!
    @IBOutlet weak var navigationBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var HomeTableView: UITableView!
    @IBOutlet weak var bannerMainView: UIView!
    var bannerView: GAMBannerView!
    @IBOutlet weak var sponsorImageView: UIImageView!
    @IBOutlet weak var sponsorImageViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var adsAreaLabel: UILabel!
    let refresher = PullToRefresh()
    
    var nowPlayingMoviesArray: [MovieModel]!
    var featuredMoviesArray: [MovieModel]!
    var nearbayCinemasArray: [CinemaModel]!
    var comingSoonMoviesArray: [MovieModel]!
    let locationManager = CLLocationManager()
    var userLongitude: Double!
    var userLatitude: Double!
    var gotUserLocation: Bool!
    var isLocationEnabled: Bool!
    var responseData: [String: Any]!
    var errorMessage = ""
    var selectedMovieID: Int!
    var selectedCinemaID: Int!
    var favoriteCinemasArray=[CinemaModel]()
    var favoriteCinemasIDsArray = [Int]()
    let comingSoonSelected = try! Cache<NSNumber>(name: "ComingSoonSelected")
    let isNavigatingFromSectionHeader = try! Cache<NSNumber>(name: "IsNavigatingFromSectionHeader")
    var isPushMovie = false
    var isPushCinema = false
    var pushMovieID = Int()
    var pushCinemaID = Int()
    let activityIndicatorView = UINib(nibName: "CustomActivityIndicator", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? CustomActivityIndicator
    let favoriteCinemasIDsCache = try! Cache<NSMutableArray>(name: "FavoriteCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())")
    var isMPUEnabled = false
    
    //MARK: - View lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addBannerView()
        if Helper.appInfo != nil && AppInfoHelper.isAppNeedsUpdate(){
            AppInfoHelper.showUpdateMessage()
        }
        if Helper.appInfo != nil{
            AppInfoHelper.showAppMessage()
        }
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                navBarHeightConstraint.constant = navBarHeightConstraint.constant + 20
            default:
                print("unknown")
            }
        }
        adsAreaLabel.text =  NSLocalizedString("adsarea", comment: "ads  Key")
        
        //Effective Measure
        //let emTracker = EmTracker()
        //emTracker.verbose = true
        //emTracker.configure("CinemaGuideMobileApp", tld: "filbalad.com", sdkKey: "2da9a01d-0fc7-4902-8d34-9f37d5bc55f6")
        //emTracker.trackDefault()
        
        let frame = CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50)
        activityIndicatorView?.frame = frame
        self.view.addSubview(activityIndicatorView!)
        
        HomeTableView.register(UINib(nibName: "HomeHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "HomeHeaderCell")
        HomeTableView.register(UINib(nibName: "MoviesTableViewCell", bundle: nil), forCellReuseIdentifier: "MoviesTableViewCell")
        HomeTableView.register(UINib(nibName: "FeaturedMoviesTableViewCell", bundle: nil), forCellReuseIdentifier: "FeaturedMoviesCell")
        HomeTableView.register(UINib(nibName: "NearbyCinemasTableViewCell", bundle: nil), forCellReuseIdentifier: "NearbyCinemasCell")
        HomeTableView.register(UINib(nibName: "FavoriteCinemasTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoriteCinemaCell")
        HomeTableView.register(UINib(nibName: "NoNearbyCinemasTableViewCell", bundle: nil), forCellReuseIdentifier: "NoDataCell")
        HomeTableView.register(UINib(nibName: "MediumRectTableViewCell", bundle: nil), forCellReuseIdentifier: "MediumRectCell")
        HomeTableView.isHidden = true
        DispatchQueue.main.async {
            self.HomeTableView.addPullToRefresh(self.refresher) { [weak self] in
                self?.checkLocation()
                self?.HomeTableView.endAllRefreshing() //self?.HomeTableView.stopPullRefreshEver()
                self?.HomeTableView.reloadData()
            }
        }

        self.locationManager.requestWhenInUseAuthorization()
        
        self.sponsorImageViewHeightConstraints.constant = 0

        isMPUEnabled = AppInfoHelper.isMpuEnabled()
        if AppInfoHelper.isVersionSponsorsed(){
            if AppInfoHelper.isCountrySplashSponsored(){
                self.sponsorImageView.isHidden = false
                sponsorImageView.kf.setImage(with: AppInfoHelper.getCountryStripSponsorImageURL(), placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: { (image, error, cahce, url) in
                    if (error != nil) {
                        self.sponsorImageView.isHidden = true
                        self.sponsorImageViewHeightConstraints.constant = 0
                    }
                    if (image != nil) {
                        self.sponsorImageViewHeightConstraints.constant = ((image?.size.height)!/UIScreen.main.scale)
                    }
                })
            }
            else if AppInfoHelper.isAppSponsored(){
                self.sponsorImageView.isHidden = false
                sponsorImageView.kf.setImage(with: AppInfoHelper.getStripSponsorImageURL(), placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: { (image, error, cahce, url) in
                    if (error != nil) {
                        self.sponsorImageView.isHidden = true
                        self.sponsorImageViewHeightConstraints.constant = 0
                    }
                    if (image != nil) {
                        self.sponsorImageViewHeightConstraints.constant = ((image?.size.height)!/UIScreen.main.scale)
                    }
                })
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let isUniversalLink = appDelegate.isUniversalLink
        if isUniversalLink {
            if let movieID = appDelegate.universalLinkMovieID {
                selectedMovieID = movieID
                self.performSegue(withIdentifier: "NavigateToMovieDetails", sender: self)
            } else if let cinemaID = appDelegate.universalLinkCinemaID {
                selectedCinemaID = cinemaID
                self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
            } else if appDelegate.isMoviesList {
                self.tabBarController?.selectedIndex = 1
            } else if appDelegate.isCinemasList {
                self.tabBarController?.selectedIndex = 2
            }
        }
        
        let isPushNotification = appDelegate.isPushNotification
        if isPushNotification {
            if let movieID = appDelegate.pushNotificationMovieID {
                selectedMovieID = Int(movieID)
                appDelegate.isPushNotification = false
                self.performSegue(withIdentifier: "NavigateToMovieDetails", sender: self)
            }
            if let cinemaID = appDelegate.pushNotificationCinemaID {
                selectedCinemaID = Int(cinemaID)
                appDelegate.isPushNotification = false
                self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Set Our Fake NavigationBar Header Background Height
        navigationBannerHeightConstraint?.constant = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        
        if let favorites = favoriteCinemasIDsCache["FavoriteCinemasIDs"] {
            favoriteCinemasIDsArray = favorites as! [Int]
        }
                
        HomeTableView.scrollsToTop = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMovie(notification:)), name: Notification.Name("openMovie"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMovie(notification:)), name: Notification.Name("OpenMovieFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinema(notification:)), name: Notification.Name("OpenCinemaFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMoviesList(notification:)), name: Notification.Name("OpenMoviesListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinemasList(notification:)), name: Notification.Name("OpenCinemasListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPushNotificationAlert(notification:)), name: Notification.Name("ShowPushNotificationAlert"), object: nil)
        
        AnalyticsHelper.GAsetScreenName(With: "Home")
        AnalyticsHelper.firebaseSetScreenName(With: "Home", className: "HomeViewController.swift")
        AnalyticsHelper.firebaseLogEvent(itemID: "Home View Controller", itemName: "Home", cType: "View Home", screenName: "Home")
        
        Analytics.setScreenName("Home", screenClass: "HomeViewController")

    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        favoriteCinemasArray = Helper.favCinemas
        if let favs = UserDefaults.standard.object(forKey: "FavsCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())") {
            let theFavs = favs as! NSArray
            favoriteCinemasIDsArray = theFavs as! [Int]
        }
        
        checkLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        appDelegate.isUniversalLink=false
        NotificationCenter.default.removeObserver(self)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    @objc func deleteFavoriteCinema(_ sender: UIButton) {
        func getFavoriteCinemaIndex(cinemaId:Int) -> Int {
            favoriteCinemasArray = Helper.favCinemas
            for index in 0 ... (Helper.favCinemas?.count)!-1{
                let cinema = Helper.favCinemas![index]
                if cinema.id == cinemaId{
                    return index
                }
            }
            return 0
        }
        func getCinemaIndex(cinemaId:Int) -> Int {
            for index in 0 ... favoriteCinemasIDsArray.count-1{
                let idd = favoriteCinemasIDsArray[index]
                if cinemaId == idd{
                    return index
                }
            }
            return 0
        }

        let cellIndex = sender.tag
        let cinema = favoriteCinemasArray[cellIndex]
        
        let alert = UIAlertController(title: "", message: "Do you want to remove \(cinema.name ?? String())?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let remove = UIAlertAction(title: "Remove", style: .destructive) { alert in
            let index = getFavoriteCinemaIndex(cinemaId: self.favoriteCinemasArray[cellIndex].id )
            self.favoriteCinemasIDsArray.remove(at: getCinemaIndex(cinemaId: self.favoriteCinemasArray[cellIndex].id) )
            self.favoriteCinemasArray.remove(at: index)
            Helper.favCinemas.remove(at: index)

            let defaults = UserDefaults.standard
            defaults.set(self.favoriteCinemasIDsArray, forKey: "FavsCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())")
            defaults.synchronize()
            
            self.HomeTableView.reloadData()
        }
        [remove, cancel].forEach { alert.addAction($0) }
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - deticting user location
    func checkLocation() {
        if CLLocationManager.locationServicesEnabled() {
            gotUserLocation = false
            isLocationEnabled = true
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            isLocationEnabled = false
            var cinemasIDs = ""
            if favoriteCinemasIDsArray.count != 0 {
                for id in favoriteCinemasIDsArray {
                    if cinemasIDs == "" {
                        cinemasIDs = "\(id)"
                    } else {
                        cinemasIDs = cinemasIDs + ",\(id)"
                    }
                }
                getHomeData(longtide: 0.0, latitude: 0.0, cinemasIDs: cinemasIDs)
            } else {
                getHomeData(longtide: 0.0, latitude: 0.0, cinemasIDs: "")
            }
        }
        HomeTableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !gotUserLocation {
            userLongitude = manager.location?.coordinate.longitude ?? 0.0
            userLatitude = manager.location?.coordinate.latitude ?? 0.0
            gotUserLocation = true
            var cinemasIDs = ""
            if favoriteCinemasIDsArray.count != 0 {
                for id in favoriteCinemasIDsArray {
                    if cinemasIDs == "" {
                        cinemasIDs = "\(id)"
                    } else {
                        cinemasIDs = cinemasIDs + ",\(id)"
                    }
                }
                getHomeData(longtide: userLongitude, latitude: userLatitude, cinemasIDs: cinemasIDs)
            } else {
                getHomeData(longtide: userLongitude, latitude: userLatitude, cinemasIDs: cinemasIDs)
            }
        }
        Netmera.requestLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLocationEnabled = false
        userLongitude = manager.location?.coordinate.longitude ?? 0.0
        userLatitude = manager.location?.coordinate.latitude ?? 0.0
        var cinemasIDs = ""
        if favoriteCinemasIDsArray.count != 0 {
            for id in favoriteCinemasIDsArray {
                if cinemasIDs == "" {
                    cinemasIDs = "\(id)"
                } else {
                    cinemasIDs = cinemasIDs + ",\(id)"
                }
            }
        }
        getHomeData(longtide: userLongitude, latitude: userLatitude, cinemasIDs: cinemasIDs)
    }
    
    //MARK: - Getting data
    func getHomeData(longtide: Double, latitude: Double, cinemasIDs: String) {
        APIManager.getHomeData(longtide: longtide, latitude: latitude, CinemasIDs: cinemasIDs, success: { (responseObject: [String: Any]) -> Void in
            self.responseData = responseObject
            self.nowPlayingMoviesArray = responseObject["nowPlayingMovies"] as! [MovieModel]
            self.featuredMoviesArray = responseObject["featuredMovies"] as! [MovieModel]
            self.comingSoonMoviesArray = responseObject["comingSoonMovies"] as! [MovieModel]
            self.nearbayCinemasArray = responseObject["nearbyCinemas"] as! [CinemaModel]
            if let favoritesArray = responseObject["favoriteCinemas"] {
                Helper.favCinemas = favoritesArray as! [CinemaModel]
                self.favoriteCinemasArray = Helper.favCinemas
            }
            DispatchQueue.main.async {
                self.HomeTableView.reloadData()
            }
            self.errorMessage = NSLocalizedString("No data found, please try again later", comment: "No Data Found")
            self.HomeTableView.isHidden = false
            self.HomeTableView.emptyDataSetDelegate = self
            self.HomeTableView.emptyDataSetDataSource = self
            self.activityIndicatorView?.stopActivityIndicator()
            activityIndicator.removeFromSuperview()
        }) { (error: NSError?) -> Void in
            if error?.description == "The Internet connection appears to be offline." {
                self.errorMessage = NSLocalizedString("No internet connection, check your connection and try again", comment: "No Internet Connection")
            } else {
                self.errorMessage = NSLocalizedString("No data found, please try again later", comment: "No Data Found")
            }
            Instabug.ibgLog(error?.description ?? "")

            self.HomeTableView.emptyDataSetDelegate = self
            self.HomeTableView.emptyDataSetDataSource = self
            self.HomeTableView.isHidden = false
            self.HomeTableView.reloadData()
            self.activityIndicatorView?.stopActivityIndicator()
            activityIndicator.removeFromSuperview()
        }
    }
    
    
    
    //MARK: - Tableview functions
    func numberOfSections(in tableView: UITableView) -> Int {
        if responseData != nil {
            return 6
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return featuredMoviesArray.count
        } else if section ==  2 {
            return 1
        } else if section == 3 {
            if nearbayCinemasArray.count != 0 && isLocationEnabled {
                return nearbayCinemasArray.count
            }
            return 1
        } else if section == 4 {
            return 1
        } else if section == 5 {
            return favoriteCinemasArray.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let moviesCell = tableView.dequeueReusableCell(withIdentifier: "MoviesTableViewCell", for: indexPath) as! MoviesTableViewCell
            moviesCell.initCellWith(movies: nowPlayingMoviesArray)
            return moviesCell
        } else if indexPath.section == 1 {
            let featuredMoviesCell = tableView.dequeueReusableCell(withIdentifier: "FeaturedMoviesCell", for: indexPath) as! FeaturedMoviesTableViewCell
            featuredMoviesCell.initCellWith(movieData: featuredMoviesArray[indexPath.row])
            return featuredMoviesCell
        } else if indexPath.section == 2 {
            //let mediumRectAdCell = tableView.dequeueReusableCell(withIdentifier: "MediumRectCell", for: indexPath) as! MediumRectTableViewCell
            let mediumRectCell = UITableViewCell()
            if isMPUEnabled {
                
                mediumRectCell.addSubview(self.setBannerView(["Home"], andPosition: ["Pos1"], andScreenName : "Home")!)
                mediumRectCell.selectionStyle = .none
                mediumRectCell.backgroundColor = .clear
                mediumRectCell.contentView.backgroundColor = .clear
                let view = UIView(frame: CGRect(x: 10, y: 10, width: (self.view.frame.width - 25), height: 250))
                view.backgroundColor = .clear
                let title = UILabel(frame: CGRect(x: 0, y: view.frame.midY, width: view.frame.width, height: 40))
                title.textAlignment = .center
                title.backgroundColor = .clear
                title.textColor = .black
//                mediumRectAdCell.mediumRectView.rootViewController = self
//                mediumRectAdCell.initCellWith(adUnitID: "/7524/Mobile-FilBalad.com/Cinema-Guide-MPU")
            } else {
              //  mediumRectAdCell.adSpaceLabel.isHidden = true
            }
            return mediumRectCell
            //return mediumRectAdCell
        } else if indexPath.section == 3 {
            if nearbayCinemasArray.count != 0 && isLocationEnabled {
                let nearbyCinemasCell = tableView.dequeueReusableCell(withIdentifier: "NearbyCinemasCell", for: indexPath) as! NearbyCinemasTableViewCell
                nearbyCinemasCell.initCellWith(cinemaData: nearbayCinemasArray[indexPath.row])
                return nearbyCinemasCell
            } else {
                let noDataCell = tableView.dequeueReusableCell(withIdentifier: "NoDataCell", for: indexPath) as! NoNearbyCinemasTableViewCell
                if !isLocationEnabled {
                    noDataCell.dataLabel.text = NSLocalizedString("Please enable location services to get your nearby cinemas", comment: "Enable Location Services")
                } else {
                    noDataCell.dataLabel.text = NSLocalizedString("No nearby cinemas", comment: "No Nearby Cinemas Key")
                }
                return noDataCell
            }
        } else if indexPath.section == 4 {
            let moviesCell = tableView.dequeueReusableCell(withIdentifier: "MoviesTableViewCell", for: indexPath) as! MoviesTableViewCell
            moviesCell.initCellWith(movies: comingSoonMoviesArray)
            return moviesCell
        } else {
            let favoriteCinemasCell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCinemaCell", for: indexPath) as! FavoriteCinemasTableViewCell
            favoriteCinemasCell.deleteButton.tag = indexPath.row
            favoriteCinemasCell.deleteButton.addTarget(self, action: #selector(deleteFavoriteCinema(_:)), for: .touchUpInside)
            let aCinema = favoriteCinemasArray[indexPath.row]
            if aCinema.isKind(of: CinemaModel.self) {
                let cinema = aCinema 
                favoriteCinemasCell.initCellWith(movies: cinema.movies, cinemaName: cinema.name)
            } else {
                let theCinema = favoriteCinemasArray[indexPath.row] as! NSDictionary
                let cinema = CinemaModel(fromDictionary: theCinema as! [String: Any])
                favoriteCinemasCell.initCellWith(movies: cinema.movies, cinemaName: cinema.name)
            }
            return favoriteCinemasCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if nowPlayingMoviesArray.count != 0 {
                return 205
            }
        } else if indexPath.section == 1 {
            if featuredMoviesArray.count != 0 {
                return 134
            }
        } else if indexPath.section == 2 {
            if !isMPUEnabled {
                return 0
            }
            return 266
        } else if indexPath.section == 3 {
            return 60
        } else if indexPath.section == 4 {
            if comingSoonMoviesArray.count != 0 {
                return 205
            }
        } else if indexPath.section == 5 {
            if favoriteCinemasArray.count != 0 {
                return 155
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            if nowPlayingMoviesArray.count != 0 {
                return 40
            }
            return 0.0000001
        } else if section == 1 {
            if featuredMoviesArray.count != 0 {
                return 40
            }
            return 0.0000001
        } else if section == 2 {
            return 0.00001
        } else if section == 3 {
            return 40
        } else if section == 4 {
            if comingSoonMoviesArray.count != 0 {
                return 40
            }
            return 0.00000000001
        } else if section == 5 {
            if favoriteCinemasArray.count != 0 {
                return 40
            }
            return 0.0000001
        }
        return 0.0000001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "HomeHeaderCell") as! HomeHeaderTableViewCell
        if section == 0 {
            if nowPlayingMoviesArray.count != 0 {
                headerCell.titleLabel.text = NSLocalizedString("Now Playing", comment: "Now Playing Movies")
            } else {
                headerCell.titleLabel.isHidden = true
                headerCell.moreButton.isHidden = true
            }
        } else if section == 1 {
            if featuredMoviesArray.count != 0 {
                headerCell.titleLabel.text = NSLocalizedString("Featured", comment: "Featured Movies")
                headerCell.moreButton.isHidden = true
            } else {
                headerCell.titleLabel.isHidden = true
                headerCell.moreButton.isHidden = true
            }
        } else if section == 2 {
            headerCell.titleLabel.text = ""
            headerCell.moreButton.isHidden = true
        } else if section == 3 {
            headerCell.titleLabel.text = NSLocalizedString("Nearby Cinemas", comment: "Nearby Cinemas Key")
        } else if section == 4 {
            if comingSoonMoviesArray.count != 0 {
                headerCell.titleLabel.text = NSLocalizedString("Coming Soon", comment: "Coming Soon Movies")
            } else {
                headerCell.titleLabel.isHidden = true
                headerCell.moreButton.isHidden = true
            }
        } else if section == 5 {
            if favoriteCinemasArray.count != 0 {
                headerCell.titleLabel.text = NSLocalizedString("My Favorite Cinemas", comment: "My Favorite Cinemas Key")
            } else {
                headerCell.moreButton.isHidden = true
            }
        }
        headerCell.delegate = self
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 5 {
            return 49
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        if indexPath.section == 1 {
            let selectedMovie = featuredMoviesArray[indexPath.row]
            selectedMovieID = selectedMovie.id
            self.performSegue(withIdentifier: "NavigateToMovieDetails", sender: self)
        }
        else if indexPath.section == 3 {
            if isLocationEnabled {
                selectedCinemaID = nearbayCinemasArray[indexPath.row].id
                self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
            }
//            } else {
////                if let url = URL(string: "App-Prefs:root=Privacy&path=LOCATION") {
////                    UIApplication.shared.openURL(url)
//                }
//}
        }
    else if indexPath.section == 5 {
            let selectedCinema = favoriteCinemasArray[indexPath.row] as AnyObject
            if selectedCinema.isKind(of: CinemaModel.self) {
                let cinema = selectedCinema as! CinemaModel
                selectedCinemaID = cinema.id
            } else {
                let cinema = selectedCinema as! NSDictionary
                selectedCinemaID = cinema["id"] as! Int
            }
            self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
        }
    }
    
    // MARK: - Empty data set functions
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage.init(named: "NoDataIcon")
    }
    
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: self.errorMessage)
        let range = (self.errorMessage as NSString).range(of: self.errorMessage)
        let font = UIFont(name: "SegoeUI-Bold", size: 16)
        attributedString.addAttributes([NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.init(red: 30/255, green: 46/255, blue: 56/255, alpha: 1)], range: range)
        return attributedString
    }
    
    func descriptionForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let tryAgain = NSLocalizedString("\n Try again", comment: "Try Again")
        let attributedString = NSMutableAttributedString(string: tryAgain)
        let range = (tryAgain as NSString).range(of: tryAgain)
        let font = UIFont(name: "SegoeUI", size: 14)
        attributedString.addAttributes([NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.init(red: 35/255, green: 54/255, blue: 66/255, alpha: 1)], range: range)
        return attributedString
    }
    
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetTapEnabled(in scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetDidTapEmptyView(in scrollView: UIScrollView) {
        HomeTableView.isHidden = true
        getHomeData(longtide: userLongitude, latitude: userLatitude, cinemasIDs: "0")
    }
    
    //MARK: - Observers functions
    @objc func openMovie(notification: Notification) {
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        selectedMovieID = notification.object as! Int
        self.performSegue(withIdentifier: "NavigateToMovieDetails", sender: self)
    }
    
    @objc func openCinema(notification: Notification) {
        selectedCinemaID = notification.object as! Int
        self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
    }
    
    @objc func openMoviesList(notification: Notification) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @objc func openCinemasList(notification: Notification) {
        self.tabBarController?.selectedIndex = 2
    }
    
    //MARK: - Preparing for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NavigateToMovieDetails" {
            let destination = segue.destination as! MovieDetailsViewController
            destination.movieID = selectedMovieID
        } else if segue.identifier == "NavigateToCinema" {
            let destination = segue.destination as! CinemaDetailsViewController
            destination.cinemaID = selectedCinemaID
        }
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
                self.selectedMovieID = self.pushMovieID
                self.performSegue(withIdentifier: "NavigateToMovieDetails", sender: self)
            }
            if self.isPushCinema {
                self.selectedCinemaID = self.pushCinemaID
                self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(showAction)
        self.present(alertController, animated: true, completion: nil)
    }
    //MARK: - Banner ad
    func addBannerView() {
//        let shadowPath = UIBezierPath(rect:self.bannerMainView.bounds)
////        self.bannerMainView.layer.masksToBounds = false
////        self.bannerMainView.layer.shadowColor = UIColor.black.cgColor
////        self.bannerMainView.layer.shadowOffset = CGSize(width: 5.0, height: 10.0)
////        self.bannerMainView.layer.shadowOpacity = 0.5
////        self.bannerMainView.layer.shadowPath = shadowPath.cgPath
//        bannerView=GAMBannerView.init()
//        bannerView.adSize = kGADAdSizeBanner
////        (adSize:  kGADAdSizeBanner, origin:CGPoint(x:(UIScreen.main.bounds.width-300)/2-10,y:0)) //y: 5 y: 10
//        bannerView.adUnitID = "ca-mb-app-pub-0868719255119470/6544059949"
//        // DFPRequest().testDevices = [ "83abcd3168c1e7b1966378fd0f3f0cd0" ];
//        bannerView.delegate = self;
//        bannerView.rootViewController = self
//        bannerView.load(GADRequest())
//        self.bannerMainView.addSubview(bannerView)
//
  
        let labelSponserArea = UILabel(frame: CGRect(x: bannerMainView.frame.minX, y: bannerMainView.frame.minY, width: bannerMainView.frame.width, height: bannerMainView.frame.height))
        labelSponserArea.text = NSLocalizedString("adsarea", comment: "ads  Key") 
        labelSponserArea.textAlignment = .center
        bannerMainView.addSubview(labelSponserArea)
        
        
        let bannerAdView = GAMBannerView(frame: CGRect(x: 0, y: 0 ,  width: self.bannerMainView.frame.width, height: self.bannerMainView.frame.height))
        bannerAdView.center = CGPoint(x: self.bannerMainView.frame.size.width / 2, y: bannerMainView.frame.size.height / 2 )
        bannerAdView.adSize = kGADAdSizeBanner
        bannerAdView.adUnitID = "/7524/Mobile-FilBalad.com/Cinema-Guide-MPU"
        bannerAdView.rootViewController = self
        bannerAdView.delegate = self
        let request = GADRequest()
//        request.keywords = keywords
        
        bannerAdView.load(request)
        bannerMainView.addSubview(bannerAdView)
        
        
        
        
        
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
    }
    
//    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//    }
    
    //MARK: - Tabbar controller delegate functions
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let indexOfTab = tabBarController.viewControllers?.firstIndex(of: viewController)
        if indexOfTab == 0 {
            AnalyticsHelper.GALogEventWith(name: "Tab Bar-Selected Home", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Tab Bar", itemName: "Tab Bar-Selected Home", cType: "Button Action", screenName: "")
        } else if indexOfTab == 1 {
            AnalyticsHelper.GALogEventWith(name: "Tab Bar-Selected Movies", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Tab Bar", itemName: "Tab Bar-Selected Movies", cType: "Button Action", screenName: "")
        } else if indexOfTab == 2 {
            AnalyticsHelper.GALogEventWith(name: "Tab Bar-Selected Cinemas", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Tab Bar", itemName: "Tab Bar-Selected Cinemas", cType: "Button Action", screenName: "")
        } else if indexOfTab == 3 {
            AnalyticsHelper.GALogEventWith(name: "Tab Bar-Selected Favorite Cinemas", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Tab Bar", itemName: "Tab Bar-Selected Favorite Cinemas", cType: "Button Action", screenName: "")
        } else if indexOfTab == 4 {
            AnalyticsHelper.GALogEventWith(name: "Tab Bar-Selected Settings", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Tab Bar", itemName: "Tab Bar-Selected Settings", cType: "Button Action", screenName: "")
        }
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
    }

}

extension HomeViewController: HomeSelectedHeaderDelegate {
    func selectHeader(headerTitle: String) {
        if headerTitle == NSLocalizedString("Now Playing", comment: "Now Playing Movies") {
            isNavigatingFromSectionHeader["IsNavigatingFromSectionHeader"] = 1
            comingSoonSelected["ComingSoonSelected"] = 0
            self.tabBarController?.selectedIndex = 1
        } else if headerTitle == NSLocalizedString("Nearby Cinemas", comment: "Nearby Cinemas Key") {
            self.tabBarController?.selectedIndex = 2
        } else if headerTitle == NSLocalizedString("Coming Soon", comment: "Coming Soon Movies") {
            isNavigatingFromSectionHeader["IsNavigatingFromSectionHeader"] = 1
            comingSoonSelected["ComingSoonSelected"] = 1
           self.tabBarController?.selectedIndex = 1
        } else if headerTitle == NSLocalizedString("My Favorite Cinemas", comment: "My Favorite Cinemas Key") {
            self.tabBarController?.selectedIndex = 3
        }
        
        AnalyticsHelper.GALogEventWith(name: "Home-Selected \(headerTitle) button", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Home", itemName: "Home-Selected \(headerTitle) button", cType: "Button Action", screenName: "Home")
        
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
    }
}
