//
//  CinemasViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/20/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import CoreLocation
import TBEmptyDataSet
import CustomizableActionSheet
import AwesomeCache
import GoogleMobileAds
//import Instabug
import Toast_Swift

struct FilterItem {
    let id: String
    var title: String
    var value: String
}

class CinemasViewController: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDelegate, UITableViewDataSource, TBEmptyDataSetDelegate, TBEmptyDataSetDataSource, CLLocationManagerDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate {

    //MARK: - Properties
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var navigationBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cinemasTableView: UITableView!
    @IBOutlet weak var sponsorImageView: UIImageView!
    @IBOutlet weak var sponsorImageViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var cinemasSearchBar: UISearchBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerMainView: UIView!
    @IBOutlet weak var adsAreaLabel: UILabel!
    var bannerView: GADBannerView!
    var filtersArray : [String]!
    var cinemasArray = [CinemaModel]()
    var pageNumber = 1
    var errorMessage = ""
    let locationManager = CLLocationManager()
    var isLocationEnabled : Bool!
    var gotUserLocation : Bool!
    var userLongitude : Double!
    var userLatitude : Double!
    var selectedCinemaID = 0
    var customActionSheet: CustomizableActionSheet?
    var sortingType = ""
    let isLocationEnabledCache = try! Cache<NSNumber>(name: "LocationEnabledCache")
    let cinemaSortingLastState = try! Cache<NSString>(name: "CinemaSortingLastState")
    var is3DFilter = ""
    let selectedPriceRangeCache = try! Cache<NSNumber>(name: "SelectedPriceRange")
    let priceRangesCache = try! Cache<NSMutableArray>(name: "PriceRangesArrayCache")
    var selectedPriceRange = Int()
    var isPriceRangeSelected = Bool()
    var priceRangesArray = [Int]()
    let appInfoCache = try! Cache<NSDictionary>(name: "AppInfoCache")
    var selectedMovieID = Int()
    var isPushMovie = false
    var isPushCinema = false
    var pushMovieID = Int()
    var pushCinemaID = Int()
    let activityIndicatorView = UINib(nibName: "CustomActivityIndicator", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? CustomActivityIndicator
    var searchQuery = ""
    var mpuIndex = 0
    var cinemasArrayWithAds = [AnyObject]()
    var isMPUEnabled = false
    var isSponsorEnabled = false
    
    //MARK: - View lifecycle functions
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
        adsAreaLabel.text =  NSLocalizedString("adsarea", comment: "ads  Key")
        
        if #available(iOS 9.0, *) {
             if CinemaGuideLangs.currentAppleLanguage() == "ar" {
                 //moviesSearchBar.setValue("الغاء", forKey:"_cancelButtonText")
                     UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "الغاء"
             } else {
                 //moviesSearchBar.setValue("Cancel", forKey:"_cancelButtonText")
                 UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Cancel"
             }
         }
        
        //Effective Measure
        //let tracker = EmTracker()
        //tracker.verbose = true
        //tracker.configure("CinemaGuideMobileApp", tld: "filbalad.com", sdkKey: "2da9a01d-0fc7-4902-8d34-9f37d5bc55f6")
        //tracker.trackDefault()
        
        startTheIndicator()
        
        /*
        if CinemaGuideLangs.currentAppleLanguage() == "en" {
            filtersArray = ["Sort By:", "3D", "Price Range"]
        } else {
            filtersArray = ["ترتيب :", "ثلاثى الابعاد", "السعر"]
        }*/
        if CinemaGuideLangs.currentAppleLanguage() == "en" {
            filtersArray = ["Sort By:", "3D", "Price Range"]
        } else {
            filtersArray = ["ترتيب :", "ثلاثى الابعاد", "السعر"]
        }
        
        filtersCollectionView.register(UINib(nibName: "FiltersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FiltersCell")
        cinemasTableView.register(UINib(nibName: "NearbyCinemasTableViewCell", bundle: nil), forCellReuseIdentifier: "NearbyCinemasCell")
        cinemasTableView.register(UINib(nibName: "MediumRectTableViewCell", bundle: nil), forCellReuseIdentifier: "MediumRectCell")
        filtersCollectionView.scrollsToTop = false
        if AppInfoHelper.isMpuEnabled(){
            mpuIndex = Helper.appInfo.mpuListingRepeatCount
            isMPUEnabled = true
        }
        cinemasTableView.isHidden = true
        self.filtersCollectionView.isHidden = true
        self.cinemasSearchBar.isHidden = true
        
        setuplocationManager()
        
        self.sponsorImageViewHeightConstraints.constant = 0

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
        
        AnalyticsHelper.GAsetScreenName(With: "Cinemas")
        AnalyticsHelper.firebaseSetScreenName(With: "Cinemas", className: "CinemasViewController.swift")
        AnalyticsHelper.firebaseLogEvent(itemID: "Cinemas View Controller", itemName: "Cinemas", cType: "View Cinemas", screenName: "Cinemas")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Set Our Fake NavigationBar Header Background Height
        navigationBannerHeightConstraint?.constant = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMovie(notification:)), name: Notification.Name("OpenMovieFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinema(notification:)), name: Notification.Name("OpenCinemaFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMoviesList(notification:)), name: Notification.Name("OpenMoviesListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinemasList(notification:)), name: Notification.Name("OpenCinemasListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPushNotificationAlert(notification:)), name: Notification.Name("ShowPushNotificationAlert"), object: nil)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        self.addBannerView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        appDelegate.isUniversalLink=false
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Setup
    func setuplocationManager() {
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            gotUserLocation = false
            isLocationEnabled = true
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        } else {
            isLocationEnabled = false
            //startTheIndicator()
            var priceRange = ""
            if selectedPriceRange != 0 {
                priceRange = "\(selectedPriceRange)"
            }
            getCinemas(pageNumber: pageNumber, longitude: userLongitude ?? 0.0, latitude: userLatitude ?? 0.0, sortingType: sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
        }
        if isLocationEnabled {
            isLocationEnabledCache["LocationEnabledCache"] = 1
            sortingType = "nearby"
            cinemaSortingLastState["CinemaSortingLastState"] = "nearby"
        } else {
            isLocationEnabledCache["LocationEnabledCache"] = 0
            sortingType = "az"
        }
    }
        
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    //MARK: - deticting user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !gotUserLocation {
            userLongitude = manager.location?.coordinate.longitude ?? 0.0
            userLatitude = manager.location?.coordinate.latitude ?? 0.0
            gotUserLocation = true
            //startTheIndicator()
            var priceRange = ""
            if selectedPriceRange != 0 {
                priceRange = "\(selectedPriceRange)"
            }
            getCinemas(pageNumber: pageNumber, longitude: userLongitude ?? 0.0, latitude: userLatitude ?? 0.0, sortingType: sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        isLocationEnabled = false
        userLongitude = manager.location?.coordinate.longitude ?? 0.0
        userLatitude = manager.location?.coordinate.latitude ?? 0.0
        sortingType = "az"
        cinemaSortingLastState["CinemaSortingLastState"] = "az"
        isLocationEnabledCache["LocationEnabledCache"] = 0
        var priceRange = ""
        if selectedPriceRange != 0 {
            priceRange = "\(selectedPriceRange)"
        }
        getCinemas(pageNumber: pageNumber, longitude: userLongitude ?? 0.0, latitude: userLatitude ?? 0.0, sortingType: sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
    }
    func initalizeBannerAds(withItemsList items: [CinemaModel], andRepeatCount repeatCount: Int) -> [AnyObject] {
        var itemsList = [AnyObject]()
        itemsList = items
        let numOfAdsOnPager = (repeatCount > 0) ? itemsList.count / repeatCount : 0
        for i in 0..<numOfAdsOnPager {
            itemsList.insert(GADBannerView.init(), at: i + repeatCount + repeatCount * i)
        }
        return itemsList
    }
    //MARK: - Getting cinemas data
    func getCinemas(pageNumber: Int, longitude: Double, latitude: Double, sortingType: String, is3D: String, priceRange: String, searchQuery: String) {
        startTheIndicator()
        APIManager.getAllCinemas(pageNumber: pageNumber, pageSize: 10, longitude: longitude, latitude: latitude, sorting: sortingType, is3D: is3D, priceRange: priceRange, searchQuery: searchQuery, success: { (responseObject) -> Void in
            let checkingArray = responseObject
            if checkingArray.count != 0 {
                self.cinemasArray.append(contentsOf: checkingArray)
                self.cinemasArrayWithAds = self .initalizeBannerAds(withItemsList: self.cinemasArray, andRepeatCount: self.mpuIndex)
                self.cinemasTableView.isHidden = false
                self.filtersCollectionView.isHidden = false
                self.cinemasSearchBar.isHidden = false
                self.cinemasTableView.tableFooterView = UIView()
                self.cinemasTableView.reloadData()
                self.filtersCollectionView.reloadData()
                self.cinemasTableView.emptyDataSetDelegate = self
                self.cinemasTableView.emptyDataSetDataSource = self
                self.errorMessage = NSLocalizedString("No data found, please try again later", comment: "No Data Found")
                DispatchQueue.main.async {
                    self.activityIndicatorView?.stopActivityIndicator()
                    self.activityIndicatorView?.removeFromSuperview()
                }

            } else {
                DispatchQueue.main.async {
                    self.activityIndicatorView?.stopActivityIndicator()
                    self.activityIndicatorView?.removeFromSuperview()
                }
                if self.cinemasArray.count == 0 {
                    self.errorMessage = NSLocalizedString("No data found, please try again later", comment: "No Data Found")
                    self.cinemasTableView.emptyDataSetDelegate = self
                    self.cinemasTableView.emptyDataSetDataSource = self
                    self.cinemasTableView.isHidden = false
                    self.filtersCollectionView.isHidden = false
                    self.cinemasSearchBar.isHidden = false
                    self.cinemasTableView.reloadData()
                  
                    self.filtersCollectionView.reloadData()
                }
            }
        }) { (error: NSError?) -> Void in
            self.activityIndicatorView?.stopActivityIndicator()
//            Instabug.ibgLog(error?.description ?? "")
            self.activityIndicatorView?.removeFromSuperview()
            if error?.description == "The Internet connection appears to be offline." {
                self.errorMessage = NSLocalizedString("No internet connection, check your connection and try again", comment: "No Internet Connection")
            } else {
                self.errorMessage = NSLocalizedString("No data found, please try again later", comment: "No Data Found")
            }
            self.cinemasTableView.emptyDataSetDelegate = self
            self.cinemasTableView.emptyDataSetDataSource = self
            self.filtersCollectionView.isHidden = true
//            self.cinemasSearchBar.isHidden = true
            self.cinemasTableView.isHidden = false
            self.cinemasTableView.reloadData()
        }
    }
    
    func getPriceRanges() {
        APIManager.getMoviesFilter(success: { (movieFilterModel: MoviesFiltersModel) -> Void in
            self.priceRangesArray = movieFilterModel.priceRanges
            self.priceRangesCache["PriceRangesArrayCache"] = NSMutableArray(array: self.priceRangesArray)
        }) { (error: NSError?) -> Void in
//            Instabug.ibgLog(error?.description ?? "")
            print(error?.description ?? "")
        }
    }
    
    //MARK: - Collection view functions
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiltersCell", for: indexPath) as! FiltersCollectionViewCell
        if indexPath.row == 0 {
            filterCell.arrowDownImage.image = #imageLiteral(resourceName: "ArrowDownIconSelected")
            filterCell.containerView.backgroundColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
            let SortingKey = NSLocalizedString("Sort by:", comment: "Sort by")
            if CinemaGuideLangs.currentAppleLanguage() == "ar" {
                if sortingType == "nearby" {
                    filterCell.filterLabel.text = SortingKey + " الاقرب "
                } else if sortingType == "az" {
                    filterCell.filterLabel.text = SortingKey + " ابجدى "
                }
            } else {
                filterCell.filterLabel.text = SortingKey + "\(sortingType)"
            }
            filterCell.arrowDownImage.isHidden = false
            filterCell.filterLabel.textColor = #colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1)
        } else if indexPath.row == 1 {
            filterCell.arrowDownImage.isHidden = true
            filterCell.filterLabel.text = NSLocalizedString("3D", comment: "3D Key")
            if is3DFilter != "" {
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1)
            } else {
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8823529412, blue: 0.8705882353, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6549019608, blue: 0.6588235294, alpha: 1)
            }
        } else if indexPath.row == 2 {
            filterCell.arrowDownImage.isHidden = false
            print(selectedPriceRange)
            filterCell.filterLabel.text =  "\(NSLocalizedString("Price Range", comment: "Price Range Key")): \(localizeNum(selectedPriceRange) ?? "0")" //NSLocalizedString("Price Range", comment: "Price Range Key")
            if isPriceRangeSelected {
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1)
                filterCell.arrowDownImage.image = #imageLiteral(resourceName: "ArrowDownIconSelected")
            } else {
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8823529412, blue: 0.8705882353, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6549019608, blue: 0.6588235294, alpha: 1)
                filterCell.arrowDownImage.image = #imageLiteral(resourceName: "ArrowDownIcon")
                  selectedPriceRangeCache["SelectedPriceRange"] = 0
                 priceRangesCache["PriceRangesArrayCache"] = NSMutableArray()
            }

        }
        return filterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {
            let font = UIFont(name: "SegoeUI", size: 24)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let localizedText = NSLocalizedString("Sort by:", comment: "Sort by")
            let myText = localizedText + ": \(sortingType)"
            let size = (myText as NSString).size(withAttributes: fontAttributes)
            if sortingType == "az" {
                return CGSize(width: size.width+30, height: 40)
            }
            else{
                return CGSize(width: size.width, height: 40)
            }
        } else if indexPath.row == 1 {
            let font = UIFont(name: "SegoeUI", size: 24)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let myText = NSLocalizedString("3D", comment: "3D Key")
            let size = (myText as NSString).size(withAttributes: fontAttributes)
            if CinemaGuideLangs.currentAppleLanguage() == "ar"{
                return CGSize(width: size.width - 10, height: 40)
            }
            return CGSize(width: size.width + 20, height: 40)
        } else {
            let font = UIFont(name: "SegoeUI", size: 24)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let myText = "\(NSLocalizedString("Price Range", comment: "Price Range Key")): \(selectedPriceRange)" //NSLocalizedString("Price Range", comment: "Price Range Key")
            let size = (myText as NSString).size(withAttributes: fontAttributes)
            if CinemaGuideLangs.currentAppleLanguage() == "ar"{
                return CGSize(width: size.width + 30, height: 40)
            }
            return CGSize(width: size.width, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var items = [CustomizableActionSheetItem]()
        if indexPath.row == 0 {
            if let view = self.tabBarController?.view {
                let sortingView = UINib(nibName: "CinemaSortingFilterView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? CinemaSortingFilterView
                sortingView?.delegate = self
                let sortingViewItem = CustomizableActionSheetItem(type: .view, height: 170)
                sortingViewItem.view = sortingView
                items.append(sortingViewItem)
                customActionSheet = CustomizableActionSheet()
                customActionSheet?.showInView(view , items: items)
            }
        } else if indexPath.row == 1 {
            if is3DFilter == "" {
                pageNumber = 1
                is3DFilter = "true"
                cinemasTableView.isHidden = true
                cinemasArray = []
//                startTheIndicator()
                var priceRange = ""
                if selectedPriceRange != 0 {
                    priceRange = "\(selectedPriceRange)"
                }
                getCinemas(pageNumber: pageNumber, longitude: userLongitude ?? 0.0, latitude: userLatitude ?? 0.0, sortingType: sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
                
                AnalyticsHelper.GALogEventWith(name: "Cinemas-Filter By 3D", category: "Button Action")
                AnalyticsHelper.firebaseLogEvent(itemID: "Filters", itemName: "Cinemas-Filter By 3D", cType: "Button Action", screenName: "Cinemas")
            } else {
                pageNumber = 1
                is3DFilter = ""
                cinemasTableView.isHidden = true
                cinemasArray = []
//                startTheIndicator()
                var priceRange = ""
                if selectedPriceRange != 0 {
                    priceRange = "\(selectedPriceRange)"
                }
                getCinemas(pageNumber: pageNumber, longitude: userLongitude ?? 0.0, latitude: userLatitude ?? 0.0, sortingType: sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
            }
        } else if indexPath.row == 2 {
            if let view = self.tabBarController?.view {
                let priceRangesView = UINib(nibName: "CinemaFilterPriceRangesView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? CinemaFilterPriceRangesView
                priceRangesView?.delegate = self
                let priceRangeViewItem = CustomizableActionSheetItem(type: .view, height: 300)
                priceRangeViewItem.view = priceRangesView
                items.append(priceRangeViewItem)
                customActionSheet = CustomizableActionSheet()
                customActionSheet?.showInView(view , items: items)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    //MARK: - Table view functions
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cinemasArray.count != 0 {
            return cinemasArrayWithAds.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cinemaData = cinemasArrayWithAds[indexPath.row]
        if cinemaData.isKind(of: CinemaModel.self) {
            let cinemaCell = tableView.dequeueReusableCell(withIdentifier: "NearbyCinemasCell", for: indexPath) as! NearbyCinemasTableViewCell
            cinemaCell.initCellWith(cinemaData: cinemaData as! CinemaModel)
            if !isLocationEnabled {
                cinemaCell.distanceLabel.isHidden = true
            }
            if cinemasArrayWithAds.count > 2 && indexPath.row == cinemasArrayWithAds.count - 2 {
                pageNumber = pageNumber + 1
                var priceRange = ""
                if selectedPriceRange != 0 {
                    priceRange = "\(selectedPriceRange)"
                }
                getCinemas(pageNumber: pageNumber, longitude: userLongitude ?? 0.0, latitude: userLatitude ?? 0.0, sortingType: sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
                self.activityIndicatorView?.removeFromSuperview()
            }
            return cinemaCell
        } else {
            let mediumRectAdCell = tableView.dequeueReusableCell(withIdentifier: "MediumRectCell", for: indexPath) as! MediumRectTableViewCell
            let mediumRectCell = UITableViewCell()
            if isMPUEnabled {
                var position = String()
                if (indexPath.row/Helper.appInfo.mpuListingRepeatCount == 1 || indexPath.row/Helper.appInfo.mpuListingRepeatCount == 2){
                    position = "Pos" + String(indexPath.row/Helper.appInfo.mpuListingRepeatCount)
                }
                else{
                    position = ""
                }
                
                print(position)
                mediumRectAdCell.adSpaceLabel.isHidden = true
                mediumRectCell.addSubview(self.setBannerView(["Home"], andPosition: [position], andScreenName : "Home")!)
                
//                mediumRectAdCell.mediumRectView.rootViewController = self
//                mediumRectAdCell.initCellWith(adUnitID: "/7524/Mobile-FilBalad.com/Cinema-Guide-MPU")
            } else {
                mediumRectAdCell.adSpaceLabel.isHidden = true
            }
            return mediumRectCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cinemaData = cinemasArrayWithAds[indexPath.row]
        if cinemaData.isKind(of: CinemaModel.self) {
        return 60
        }
        else{
            return 266
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.000001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 49
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCinema = cinemasArrayWithAds[indexPath.row]
        if selectedCinema.isKind(of: CinemaModel.self) {
            if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
                let theCount = count as! NSNumber
                var countInt = Int(theCount)
                countInt = countInt + 1
                UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
            }
            let cinemaData = selectedCinema as! CinemaModel
            selectedCinemaID = cinemaData.id
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
        cinemasTableView.isHidden = true
        self.filtersCollectionView.isHidden = true
//        startTheIndicator()
        var priceRange = ""
        if selectedPriceRange != 0 {
            priceRange = "\(selectedPriceRange)"
        }
        getCinemas(pageNumber: pageNumber, longitude: userLongitude ?? 0.0, latitude: userLatitude ?? 0.0, sortingType: sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
    }
    
    //MARK: - Segue
    @objc func openMovie(notification: Notification) {
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
    
    //MARK: - Search functions
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            self.view.endEditing(true)
            searchQuery = searchBar.text!
            pageNumber = 1
            cinemasArray = []
            cinemasTableView.isHidden = true
//            startTheIndicator()
            var priceRange = ""
            if selectedPriceRange != 0 {
                priceRange = "\(selectedPriceRange)"
            }
            getCinemas(pageNumber: pageNumber, longitude: userLongitude, latitude: userLatitude, sortingType: self.sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            searchQuery = searchBar.text!
            pageNumber = 1
            cinemasArray = []
            cinemasTableView.isHidden = true
            searchBar.showsCancelButton = false
//            startTheIndicator()
            var priceRange = ""
            if selectedPriceRange != 0 {
                priceRange = "\(selectedPriceRange)"
            }
            getCinemas(pageNumber: pageNumber, longitude: userLongitude, latitude: userLatitude, sortingType: self.sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchQuery = ""
        pageNumber = 1
        cinemasArray = []
        cinemasTableView.isHidden = true
        searchBar.showsCancelButton = true
//        startTheIndicator()
        var priceRange = ""
        if selectedPriceRange != 0 {
            priceRange = "\(selectedPriceRange)"
        }
        getCinemas(pageNumber: pageNumber, longitude: userLongitude, latitude: userLatitude, sortingType: self.sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            searchQuery = searchBar.text!
            pageNumber = 1
            cinemasArray = []
            //cinemasTableView.isHidden = true
            //startTheIndicator()
            var priceRange = ""
            if selectedPriceRange != 0 {
                priceRange = "\(selectedPriceRange)"
            }
            getCinemas(pageNumber: pageNumber, longitude: userLongitude, latitude: userLatitude, sortingType: self.sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
        }
    }
    
    //MARK: - Activity Indicator
    func startTheIndicator() {
        let frame = CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50)
        activityIndicatorView?.frame = frame
        self.view.addSubview(activityIndicatorView!)
        activityIndicatorView?.startActivityIndicator()
    }
}

extension CinemasViewController: CinemaSortingViewDelegate {
    func cinemaSortingOkButtonPressed(sortingType: String) {
        pageNumber = 1
        cinemasArray = []
        self.sortingType = sortingType
        cinemasTableView.isHidden = true
        self.filtersCollectionView.isHidden = true
        filtersCollectionView.reloadData()
//        startTheIndicator()
        var priceRange = ""
        if selectedPriceRange != 0 {
            priceRange = "\(selectedPriceRange)"
        }
        getCinemas(pageNumber: pageNumber, longitude: userLongitude ?? 0.0, latitude: userLatitude ?? 0.0, sortingType: self.sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
        customActionSheet?.dismiss()
        
        AnalyticsHelper.GALogEventWith(name: "Cinemas-Sorted By \(sortingType)", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Filters", itemName: "Cinemas-Sorted By \(sortingType)", cType: "Button Action", screenName: "Cinemas")
    }
    
    func cinemaSortingCancelButtonPressed() {
        customActionSheet?.dismiss()
    }
}

extension CinemasViewController: PriceRangesFilterDelegate {
    func priceRangesOkPressed(selectedRange: Int) {
        if selectedRange != 0 {
            selectedPriceRange = selectedRange
            isPriceRangeSelected = true
            pageNumber = 1
            cinemasArray = []
            cinemasTableView.isHidden = true
            self.filtersCollectionView.isHidden = true
//            startTheIndicator()
            var priceRange = ""
            if selectedPriceRange != 0 {
                priceRange = "\(selectedPriceRange)"
            }
            getCinemas(pageNumber: pageNumber, longitude: userLatitude, latitude: userLatitude, sortingType: sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
            customActionSheet?.dismiss()
            
            AnalyticsHelper.GALogEventWith(name: "Cinemas-Filter With Price Range \(selectedRange)", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Filters", itemName: "Cinemas-Filter With Price Range \(selectedRange)", cType: "Button Action", screenName: "Cinemas")
        } else {
            isPriceRangeSelected = false
            pageNumber = 1
            cinemasArray = []
            cinemasTableView.isHidden = true
            selectedPriceRange = 0
//            startTheIndicator()
            var priceRange = ""
            if selectedPriceRange != 0 {
                priceRange = "\(selectedPriceRange)"
            }
            getCinemas(pageNumber: pageNumber, longitude: userLatitude, latitude: userLatitude, sortingType: sortingType, is3D: is3DFilter, priceRange: priceRange, searchQuery: searchQuery)
            customActionSheet?.dismiss()
        }
    }
    
    func priceRangesCancelPressed() {
        customActionSheet?.dismiss()
    }
    func addBannerView() -> Void {
        let shadowPath = UIBezierPath(rect:self.bannerMainView.bounds)
//        self.bannerMainView.layer.masksToBounds = false
//        self.bannerMainView.layer.shadowColor = UIColor.black.cgColor
//        self.bannerMainView.layer.shadowOffset = CGSize(width: 5.0, height: 10.0)
//        self.bannerMainView.layer.shadowOpacity = 0.5
//        self.bannerMainView.layer.shadowPath = shadowPath.cgPath
        bannerView=GADBannerView.init(adSize:  kGADAdSizeBanner, origin:CGPoint(x:(UIScreen.main.bounds.width-300)/2-10,y:0)) //y: 5 y: 10
        bannerView.adUnitID = "ca-mb-app-pub-0868719255119470/6544059949"
        // DFPRequest().testDevices = [ "83abcd3168c1e7b1966378fd0f3f0cd0" ];
        bannerView.delegate = self;
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        self.bannerMainView.addSubview(bannerView)
    }
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
    }
//    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        
//    }
}
