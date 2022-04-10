//
//  MoviesViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/20/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import TBEmptyDataSet
import CustomizableActionSheet
import AwesomeCache
import GoogleMobileAds
//import Instabug
import Toast_Swift
class MoviesViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TBEmptyDataSetDelegate, TBEmptyDataSetDataSource, UIGestureRecognizerDelegate, UISearchBarDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var moviesSegmentedControl: UISegmentedControl!
    @IBOutlet weak var navigationBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var filtersCollectionView: UICollectionView!
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var sponsorImageView: UIImageView!
    @IBOutlet weak var sponsorImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerMainView: UIView!
    @IBOutlet weak var adsAreaLabel: UILabel!
    var bannerView: GADBannerView!
    var filtersArray : [String]!
    var errorMessage = ""
    var selectedMovieID : Int!
    var customActionSheet: CustomizableActionSheet?
    let lastState = try! Cache<NSString>(name: "SortingLastState")
    var sortingType = "date"
    var isGenreSelected = Bool()
    var selectedGenres = ""
    let selectedGenresCache = try! Cache<NSMutableArray>(name: "SelectedGenres")
    let genresCache = try! Cache<NSMutableArray>(name: "GenresArray")
    var genresArray = [[String: Any]]()
    var languagesArray = [[String: Any]]()
    var pgsArray = [[String: Any]]()
    let selectedLanguageCache = try! Cache<NSNumber>(name: "SelectedLanguage")
    let languagesCache = try! Cache<NSMutableArray>(name: "languagesArrayCache")
    var isLanguageSelected = Bool()
    var genresString = ""
    var selectedLanguageID = Int()
    let selectedPGCache = try! Cache<NSString>(name: "SelectedPG")
    let PGsCache = try! Cache<NSMutableArray>(name: "PGsArrayCache")
    var selectedPGID = ""
    var isPGSelected = Bool()
    let comingSoonSelected = try! Cache<NSNumber>(name: "ComingSoonSelected")
    let isNavigatingFromSectionHeader = try! Cache<NSNumber>(name: "IsNavigatingFromSectionHeader")
    var selectedCinemaID = Int()
    var isPushMovie = false
    var isPushCinema = false
    var pushMovieID = Int()
    var pushCinemaID = Int()
    let activityIndicatorView = UINib(nibName: "CustomActivityIndicator", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? CustomActivityIndicator
    var searchQuery = ""
    var mpuIndex = 0
    var moviesArrayWithAds = [AnyObject]()
    var isMPUEnabled = false
    var isInterestatialEnabled = false
    var isSponsorEnabled = false
    var oldMpuIndex = 0
    var isViewLoadedd = false
    
    
    //Service
    var moviesArray = [MovieModel]()
    var pageNumber : Int = 1
    var pageSize : Int = 50
    var inCinema : Bool!
    var is3DFilter = ""
    var sortingDirection = "asc"

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
                UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = NSLocalizedString("Cancel", comment: "Cancel Key")
            }
        }
        if AppInfoHelper.isMpuEnabled(){
            mpuIndex = Helper.appInfo.mpuListingRepeatCount
            isMPUEnabled = true
        }
        //Effective Measure
        //let emTracker = EmTracker()
        //emTracker.verbose = true
        //emTracker.configure("CinemaGuideMobileApp", tld: "filbalad.com", sdkKey: "2da9a01d-0fc7-4902-8d34-9f37d5bc55f6")
        //emTracker.trackDefault()
        
        filtersArray = ["Sort by", "3D", "Genre", "Language", "PG"]
        
        filtersCollectionView.register(UINib(nibName: "FiltersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FiltersCell")
        filtersCollectionView.scrollsToTop = false
        
        moviesTableView.register(UINib(nibName: "MovieTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieTableViewCell")
        moviesTableView.register(UINib(nibName: "MediumRectTableViewCell", bundle: nil), forCellReuseIdentifier: "MediumRectCell")
        moviesTableView.isHidden = true
        
        startTheIndicator()
        
        pageNumber = 1
        pageSize = 50
        inCinema = true
        getMoviesFilters()
        print(comingSoonSelected["ComingSoonSelected"])
        if let comingSoon = comingSoonSelected["ComingSoonSelected"] {
            let isComingSoon = Bool(comingSoon)
            if isComingSoon {
                inCinema = false
                moviesSegmentedControl.selectedSegmentIndex = 1
                sortingDirection = "asc"
                getMovies(pg: selectedPGID, searchQuery: searchQuery)
            } else {
                sortingDirection = "desc"
                getMovies(pg: selectedPGID, searchQuery: searchQuery)
            }
        } else {
            pageNumber = 1
            pageSize = 50
            inCinema = true
            getMoviesFilters()
            sortingDirection = "desc"
            getMovies(pg: selectedPGID, searchQuery: searchQuery)

        }
        self.sponsorImageViewHeightConstraint.constant = 0

        if AppInfoHelper.isVersionSponsorsed(){
            if AppInfoHelper.isCountrySplashSponsored(){
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
        lastState["SortingLastState"] = "date"
        selectedGenresCache["SelectedGenres"] = NSMutableArray()
        genresCache["GenresArray"] = NSMutableArray()
        languagesCache["languagesArrayCache"] = NSMutableArray()
        selectedLanguageCache["SelectedLanguage"] = 0
        selectedPGCache["SelectedPG"] = ""
        PGsCache["PGsArrayCache"] = NSMutableArray()
        isViewLoadedd = true
        
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
        if let isNavigating = isNavigatingFromSectionHeader["IsNavigatingFromSectionHeader"] {
            let isNavigatingBool = Bool(isNavigating)
            if isNavigatingBool {
                if let comingSoon = comingSoonSelected["ComingSoonSelected"] {
                    moviesArray = []
                    pageNumber = 1
                    pageSize = 50
                    let isComingSoon = Bool(comingSoon)
                    sortingDirection = "desc"
                    if isComingSoon {
                        inCinema = false
                        moviesSegmentedControl.selectedSegmentIndex = 1
                        //sortingDirection = "asc"
                        getMovies(pg: selectedPGID, searchQuery: searchQuery)
                    } else {
                        moviesSegmentedControl.selectedSegmentIndex = 0
                        inCinema = true
                       // sortingDirection = "asc"
                        getMovies(pg: selectedPGID, searchQuery: searchQuery)
                    }
                }
                isNavigatingFromSectionHeader.removeAllObjects()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMovie(notification:)), name: Notification.Name("OpenMovieFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinema(notification:)), name: Notification.Name("OpenCinemaFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMoviesList(notification:)), name: Notification.Name("OpenMoviesListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinemasList(notification:)), name: Notification.Name("OpenCinemasListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPushNotificationAlert(notification:)), name: Notification.Name("ShowPushNotificationAlert"), object: nil)
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        //        screenName = "iOS-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())-\(CinemaGuideLangs.currentAppleLanguage())-Movies"
        
        AnalyticsHelper.GAsetScreenName(With: "Movies")
        AnalyticsHelper.firebaseSetScreenName(With: "Movies", className: "MoviesViewController.swift")
        AnalyticsHelper.firebaseLogEvent(itemID: "Movies View Controller", itemName: "Movies", cType: "View Movies", screenName: "Movies")
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.addBannerView()
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
    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        appDelegate.isUniversalLink=false
        NotificationCenter.default.removeObserver(self)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    func initalizeBannerAds(withItemsList items: [MovieModel], andRepeatCount repeatCount: Int) -> [AnyObject] {
        var itemsList = [AnyObject]()
        itemsList = items
        let numOfAdsOnPager = (repeatCount > 0) ? itemsList.count / repeatCount : 0
        for i in 0..<numOfAdsOnPager {
            itemsList.insert(GADBannerView.init(), at: i + repeatCount + repeatCount * i)
        }
        return itemsList
    }
    //MARK: - Getting movies data
    func getMovies(pg: String, searchQuery: String) { //, dir: String
        //Langauge
        var languageString = ""
        if selectedLanguageID != 0 {
            languageString = "\(selectedLanguageID)"
        } else {
            languageString = ""
        }
        //
        
        startTheIndicator()
        APIManager.getAllMovies(pageNumber: self.pageNumber, pageSize: self.pageSize, inCinema: self.inCinema,
                                is3D: self.is3DFilter, genres: self.genresString, sorting: self.sortingType,
                                language: languageString, pg: pg, searchQuery: searchQuery, dir: self.sortingDirection, success: { //, dir: dir,
            (responseObject: [MovieModel]) -> Void in
            
            self.pageNumber = self.pageNumber + 1
            let checkingArray = responseObject
            if checkingArray.count != 0 && self.moviesArray.contains(where: { $0.id == checkingArray.first?.id }) == false {
                self.moviesArray.append(contentsOf: checkingArray)
                self.moviesArrayWithAds = self.initalizeBannerAds(withItemsList: self.moviesArray, andRepeatCount: self.mpuIndex)
                
                self.moviesTableView.isHidden = false
                self.filtersCollectionView.isHidden = false
                self.moviesSearchBar.isHidden = false
                self.moviesTableView.tableFooterView = UIView()
                self.moviesTableView.reloadData()
                self.filtersCollectionView.reloadData()
                self.moviesTableView.emptyDataSetDelegate = self
                self.moviesTableView.emptyDataSetDataSource = self
                self.errorMessage = NSLocalizedString("No data found, please try again later", comment: "No Data Found")
                DispatchQueue.main.async {
                    self.activityIndicatorView?.stopActivityIndicator()
                }
            } else {
                if self.moviesArray.count != 0 {
                    DispatchQueue.main.async {
                        self.activityIndicatorView?.stopActivityIndicator()
                    }  } else {
                    DispatchQueue.main.async {
                        self.activityIndicatorView?.stopActivityIndicator()
                        
                    }
                    self.errorMessage = NSLocalizedString("No data found, please try again later", comment: "No Data Found")
                    self.moviesTableView.emptyDataSetDelegate = self
                    self.moviesTableView.emptyDataSetDataSource = self
                    self.moviesTableView.isHidden = false
                    self.moviesSearchBar.isHidden = false
                    self.moviesTableView.reloadData()
                    self.filtersCollectionView.reloadData()
                }
            }
        }) { (error: NSError?) -> Void in
            DispatchQueue.main.async {
                self.activityIndicatorView?.stopActivityIndicator()
                
            }
            if error?.description == "The Internet connection appears to be offline." {
                self.errorMessage = NSLocalizedString("No internet connection, check your connection and try again", comment: "No Internet Connection")
            } else {
                self.errorMessage = NSLocalizedString("No data found, please try again later", comment: "No Data Found")
            }
            self.moviesTableView.emptyDataSetDelegate = self
            self.moviesTableView.emptyDataSetDataSource = self
            self.moviesTableView.isHidden = false
            self.moviesSearchBar.isHidden = false
            self.moviesTableView.reloadData()
//            Instabug.ibgLog(error?.description ?? "")
            
        }
    }
    
    func getMoviesFilters() {
        APIManager.getMoviesFilter(success: { (movieFilterModel: MoviesFiltersModel) -> Void in
            self.genresArray = movieFilterModel.genres
            self.languagesArray = movieFilterModel.langs
            self.pgsArray = movieFilterModel.pgs
        }) { (error: NSError?) -> Void in
            print(error?.description ?? "")
//            Instabug.ibgLog(error?.description ?? "")
        }
    }
    //MARK: - Collection view functions
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if filtersArray == nil {
            return 0
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filtersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let filterCell = collectionView.dequeueReusableCell(withReuseIdentifier: "FiltersCell", for: indexPath) as! FiltersCollectionViewCell
        
        if indexPath.row == 0 {             //Sort BY
            filterCell.arrowDownImage.image = #imageLiteral(resourceName: "ArrowDownIconSelected")
            filterCell.containerView.backgroundColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
            let SortingKey = NSLocalizedString("Sort by:", comment: "Sort by")
            if CinemaGuideLangs.currentAppleLanguage() == "ar" {
                if sortingType == "az" {
                    filterCell.filterLabel.text = SortingKey + " ابجدى "
                } else if sortingType == "rate" {
                    filterCell.filterLabel.text = SortingKey + " الافضل "
                } else if sortingType == "date" {
                    filterCell.filterLabel.text = SortingKey + " التاريخ "
                }
            } else {
                filterCell.filterLabel.text = SortingKey + "\(sortingType)"
            }
            filterCell.filterLabel.textColor = #colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1)
        } else if indexPath.row == 1 {      //3D
            filterCell.arrowDownImage.isHidden = true
            filterCell.filterLabel.text = NSLocalizedString("3D", comment: "3D Key")
            if is3DFilter != "" {
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1)
            } else {
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8823529412, blue: 0.8705882353, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6549019608, blue: 0.6588235294, alpha: 1)
            }
        } else if indexPath.row == 2 {      //Genres
            filterCell.filterLabel.text = NSLocalizedString("Genres", comment: "Genres Key")
            filterCell.arrowDownImage.isHidden = false
            if isGenreSelected {
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1)
                filterCell.arrowDownImage.image = #imageLiteral(resourceName: "ArrowDownIconSelected")
            } else {
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8823529412, blue: 0.8705882353, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6549019608, blue: 0.6588235294, alpha: 1)
                filterCell.arrowDownImage.image = #imageLiteral(resourceName: "ArrowDownIcon")
                selectedGenresCache["SelectedGenres"] = NSMutableArray()
                genresCache["GenresArray"] = NSMutableArray()
            }
        } else if indexPath.row == 3 {      //Language
            var language: String!
            if languagesArray.count > selectedLanguageID {
                language = languagesArray[selectedLanguageID > 0 ? selectedLanguageID - 1 : selectedLanguageID]["name"] as? String
            } else { language = "" }
                //NSLocalizedString("Language", comment: "Language Key")
            filterCell.arrowDownImage.isHidden = false
            if isLanguageSelected {
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1)
                filterCell.arrowDownImage.image = #imageLiteral(resourceName: "ArrowDownIconSelected")
                filterCell.filterLabel.text = "\(NSLocalizedString("Language", comment: "Language Key")): \(language ?? "")"
            } else {
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8823529412, blue: 0.8705882353, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6549019608, blue: 0.6588235294, alpha: 1)
                filterCell.arrowDownImage.image = #imageLiteral(resourceName: "ArrowDownIcon")
                languagesCache["languagesArrayCache"] = NSMutableArray()
                selectedLanguageCache["SelectedLanguage"] = 0
                filterCell.filterLabel.text = "\(NSLocalizedString("Language", comment: "Language Key"))"
            }
        } else if indexPath.row == 4 {      //PG
            filterCell.arrowDownImage.isHidden = false
            if isPGSelected {
                filterCell.filterLabel.text = filtersArray.last ?? "" //"PG"
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1)
                filterCell.arrowDownImage.image = #imageLiteral(resourceName: "ArrowDownIconSelected")
            } else {
                filterCell.filterLabel.text = NSLocalizedString("all", comment: "all") //"PG"
                filterCell.containerView.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8823529412, blue: 0.8705882353, alpha: 1)
                filterCell.filterLabel.textColor = #colorLiteral(red: 0.6431372549, green: 0.6549019608, blue: 0.6588235294, alpha: 1)
                filterCell.arrowDownImage.image = #imageLiteral(resourceName: "ArrowDownIcon")
                selectedPGCache["SelectedPG"] = ""
                PGsCache["PGsArrayCache"] = NSMutableArray()
            }
        }
        return filterCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0 {                 //Sort BY
            let font = UIFont(name: "SegoeUI", size: 24)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let localizedText = NSLocalizedString("Sort by:", comment: "Sort by")
            var myText = ""
            if CinemaGuideLangs.currentAppleLanguage() == "ar" {
                if sortingType == "az" {
                    myText = localizedText + " ابجدى "
                } else if sortingType == "rate" {
                    myText = localizedText + " الافضل "
                } else if sortingType == "date" {
                    myText = localizedText + " التاريخ "
                }
            } else {
                myText = localizedText + ": \(sortingType)"
            }
            let size = (myText as NSString).size(withAttributes: fontAttributes)
            return CGSize(width: size.width + 10, height: 40) // size.width + 20
            
        } else if indexPath.row == 1 {          //3D
            let font = UIFont(name: "SegoeUI", size: 24)
            let fontAttributes = [NSAttributedString.Key.font: font]
            let myText = NSLocalizedString("3D", comment: "3D Key")
            let size = (myText as NSString).size(withAttributes: fontAttributes)
            if CinemaGuideLangs.currentAppleLanguage() == "ar"{
                return CGSize(width: size.width - 10, height: 40)
            }
            return CGSize(width: size.width + 20, height: 40)
        }
        let font = UIFont(name: "SegoeUI", size: 24)
        let fontAttributes = [NSAttributedString.Key.font: font]
        var myText = ""
        
        if indexPath.row == 2 {                 //Generes
            myText = NSLocalizedString("Genres", comment: "Genres Key")
            
        } else if indexPath.row == 3 {          //Langauge
            
            if languagesArray.count > selectedLanguageID && selectedLanguageID != 0 {
                var language = languagesArray[selectedLanguageID]["name"] as? String
                myText = "\(NSLocalizedString("Language", comment: "Language Key")): \(language ?? "")"
            } else {
                myText = "\(NSLocalizedString("Language", comment: "Language Key"))"
            }
            //myText = NSLocalizedString("Language", comment: "Language Key")
            
        } else if indexPath.row == 4 {          //PG
            if selectedPGID != "" {
                myText = filtersArray.last ?? "PG"
            } else {
                myText = "All"
            }
        }
        let size = (myText as NSString).size(withAttributes: fontAttributes)
        return CGSize(width: size.width + 42, height: 40) //34 38
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var items = [CustomizableActionSheetItem]()
        if indexPath.row == 0 {
            if let view = self.tabBarController?.view {
                let sortingView = UINib(nibName: "SortingFilterView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? SortingFilterView
                sortingView?.delegate = self
                let sortingViewItem = CustomizableActionSheetItem(type: .view, height: 220)
                sortingViewItem.view = sortingView
                items.append(sortingViewItem)
                customActionSheet = CustomizableActionSheet()
                customActionSheet?.showInView(view , items: items)
            }
        } else if indexPath.row == 1 {
            if is3DFilter == "" {
                pageNumber = 1
                is3DFilter = "true"
                moviesTableView.isHidden = true
                moviesArray = []
                sortingDirection = "asc"
                getMovies(pg: selectedPGID, searchQuery: searchQuery)
                
                AnalyticsHelper.GALogEventWith(name: "Movies-Filter By 3D", category: "Button Action")
                AnalyticsHelper.firebaseLogEvent(itemID: "Filters", itemName: "Movies-Filter By 3D", cType: "Button Action", screenName: "Movies")
            } else {
                pageNumber = 1
                is3DFilter = ""
                moviesTableView.isHidden = true
                moviesArray = []
                sortingDirection = "desc"
                getMovies(pg: selectedPGID, searchQuery: searchQuery)
            }
        } else if indexPath.row == 2 {
            if let view = self.tabBarController?.view {
                let genresView = UINib(nibName: "GenresFilterView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? GenresFilterView
                self.genresCache["GenresArrayCache"] = NSMutableArray(array: self.genresArray)
                genresView?.delegate = self
                let sortingViewItem = CustomizableActionSheetItem(type: .view, height: 320)
                sortingViewItem.view = genresView
                items.append(sortingViewItem)
                customActionSheet = CustomizableActionSheet()
                customActionSheet?.showInView(view , items: items)
            }
        } else if indexPath.row == 3 {
            if let view = self.tabBarController?.view {
                let LanguageView = UINib(nibName: "LanguageFilterView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? LanguageFilterView
                self.languagesCache["languagesArrayCache"] = NSMutableArray(array: self.languagesArray)
                LanguageView?.delegate = self
                let sortingViewItem = CustomizableActionSheetItem(type: .view, height: 320)
                sortingViewItem.view = LanguageView
                items.append(sortingViewItem)
                customActionSheet = CustomizableActionSheet()
                customActionSheet?.showInView(view , items: items)
            }
        } else if indexPath.row == 4 {
            if let view = self.tabBarController?.view {
                let pgView = UINib(nibName: "PGsFilterView", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? PGsFilterView
                
                //V1
                //self.PGsCache["PGsArrayCache"] = NSMutableArray(array: self.pgsArray) //NSMutableArray(array: self.pgsArray)
                
                //V2
                let pgsArray = NSMutableArray(array: self.pgsArray) //movieFilterModel.pgs
                pgsArray.insert(["name": "All", "id": 0], at: 0) //pgsArray?.append(["name": "All", "id": 0])
                self.PGsCache["PGsArrayCache"] = pgsArray //NSMutableArray(array: self.pgsArray)
                
                pgView?.delegate = self
                let pgViewItem = CustomizableActionSheetItem(type: .view, height: 320)
                pgViewItem.view = pgView
                items.append(pgViewItem)
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
        if moviesArray.count == 0 {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if moviesArray.count != 0 {
            return moviesArrayWithAds.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let movieData = moviesArrayWithAds[indexPath.row]
        if movieData.isKind(of: MovieModel.self) {
            let movieCell = tableView.dequeueReusableCell(withIdentifier: "MovieTableViewCell", for: indexPath) as! MovieTableViewCell
            movieCell.initCellWithData(movieData: movieData as! MovieModel)
            if indexPath.row == moviesArrayWithAds.count - 2 && moviesArrayWithAds.count > 9 {
                pageNumber = pageNumber + 1
                
                //sortingDirection = "asc" since its pagination we don't want to change the sorting direction
                
                getMovies(pg: selectedPGID, searchQuery: searchQuery)
                activityIndicatorView?.removeFromSuperview()
            }
            return movieCell
        } else {
          //  let mediumRectAdCell = tableView.dequeueReusableCell(withIdentifier: "MediumRectCell", for: indexPath) as! MediumRectTableViewCell
               let mediumRectCell = UITableViewCell()
            if isMPUEnabled {
//                mediumRectAdCell.mediumRectView.rootViewController = self
//                mediumRectAdCell.initCellWith(adUnitID: "/7524/Mobile-FilBalad.com/Cinema-Guide-MPU")
                var position = String()
                if (indexPath.row/Helper.appInfo.mpuListingRepeatCount == 1 || indexPath.row/Helper.appInfo.mpuListingRepeatCount == 2){
                    position = "Pos" + String(indexPath.row/Helper.appInfo.mpuListingRepeatCount)
                    print(String(indexPath.row/Helper.appInfo.mpuListingRepeatCount))
                }
                else{
                    position = ""
                }
                
                print(position)
                mediumRectCell.addSubview(self.setBannerView(["Home"], andPosition: [position], andScreenName : "Home")!)
             
            } else {
                
               // mediumRectAdCell.adSpaceLabel.isHidden = true
            }
            return mediumRectCell
           // return mediumRectAdCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let movieData = moviesArrayWithAds[indexPath.row]
        if movieData.isKind(of: MovieModel.self) {
        return 155
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
        let selectedMovie = moviesArrayWithAds[indexPath.row]
        if selectedMovie.isKind(of: MovieModel.self) {
            if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
                let theCount = count as! NSNumber
                var countInt = Int(theCount)
                countInt = countInt + 1
                UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
            }
            let movieData = selectedMovie as! MovieModel
            selectedMovieID = movieData.id
            self.performSegue(withIdentifier: "NavigateToMovieDetails", sender: self)
        }
    }
    
    //MARK: - Segmented control function
    @IBAction func moviesSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        activityIndicator.removeFromSuperview()
        moviesTableView.isHidden = true
        moviesArray = []
        pageNumber = 1
        if inCinema {
            inCinema = false
        } else {
            inCinema = true
        }
        moviesArray = []
        let frame = CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50)
        initActivityIndicatorWith(frame: frame)
        self.view.addSubview(activityIndicator)
        sortingDirection = "desc"
        getMovies(pg: selectedPGID, searchQuery: searchQuery)
        
        AnalyticsHelper.GALogEventWith(name: "Movies-Selected \(moviesSegmentedControl.titleForSegment(at: moviesSegmentedControl.selectedSegmentIndex) ?? "") from movies segmented control", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Filters", itemName: "Movies-Selected \(moviesSegmentedControl.titleForSegment(at: moviesSegmentedControl.selectedSegmentIndex) ?? "") from movies segmented control", cType: "Button Action", screenName: "Movies")
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
        moviesTableView.isHidden = true
        sortingDirection = "asc"
        getMovies(pg: selectedPGID, searchQuery: searchQuery)
    }
    
    //MARK: - Preparing for segue
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
            moviesArray = []
            moviesTableView.isHidden = true
            self.moviesSearchBar.isHidden = true
            let frame = CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50)
            activityIndicatorView?.frame = frame
            self.view.addSubview(activityIndicatorView!)
            sortingDirection = "asc"
            getMovies(pg: selectedPGID, searchQuery: searchQuery)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            self.view.endEditing(true)
            searchQuery = searchBar.text!
            pageNumber = 1
            moviesArray = []
            moviesTableView.isHidden = true
            searchBar.showsCancelButton = false
            self.moviesSearchBar.isHidden = true
            sortingDirection = "desc"
            getMovies(pg: selectedPGID, searchQuery: searchQuery)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchQuery = ""
        pageNumber = 1
        moviesArray = []
        searchBar.showsCancelButton = true
        moviesTableView.isHidden = true
        if self.oldMpuIndex != 0 {
            self.mpuIndex = self.oldMpuIndex
        } else {
            if AppInfoHelper.isMpuEnabled(){
                mpuIndex = Helper.appInfo.mpuListingRepeatCount
            }
        }
        sortingDirection = "desc"
        getMovies(pg: selectedPGID, searchQuery: searchQuery)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text != "" {
            searchQuery = searchBar.text!
            pageNumber = 1
            moviesArray = []
            moviesTableView.isHidden = true
            self.moviesSearchBar.isHidden = true
            let frame = CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50)
            activityIndicatorView?.frame = frame
            self.view.addSubview(activityIndicatorView!)
            sortingDirection = "asc"
            getMovies(pg: selectedPGID, searchQuery: searchQuery)
        }
        else{
            searchQuery = ""
            pageNumber = 1
            moviesArray = []
            searchBar.showsCancelButton = true
            moviesTableView.isHidden = true
            if self.oldMpuIndex != 0 {
                self.mpuIndex = self.oldMpuIndex
            } else {
                if AppInfoHelper.isMpuEnabled(){
                    mpuIndex = Helper.appInfo.mpuListingRepeatCount
                }
            }
            sortingDirection = "desc"
            getMovies(pg: selectedPGID, searchQuery: searchQuery)
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

extension MoviesViewController: SortingViewDelegate {
    func setSorting(sortingType: String) {
        self.sortingType = sortingType
    }
    
    func okButtonPressed() {
        pageNumber = 1
        moviesArray = []
        moviesTableView.isHidden = true
        filtersCollectionView.reloadData()
        
        if sortingType == "date" || sortingType == "rate" {
            sortingDirection = "desc" //sortingDirection = "desc"
        }
         else {
            sortingDirection = "asc" //sortingDirection = "asc"
        }
        
        getMovies(pg: selectedPGID, searchQuery: searchQuery)

        customActionSheet?.dismiss()
        
        AnalyticsHelper.GALogEventWith(name: "Movies-Sorted By \(sortingType)", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Filters", itemName: "Movies-Sorted By \(sortingType)", cType: "Button Action", screenName: "Movies")
    }
    
    func cancelButtonPressed() {
        customActionSheet?.dismiss()
    }
}

extension MoviesViewController: GenresFilterDelegate {
    func okPressed(genresIDs: [Int]) {
        
        genresString = ""
        if genresIDs.count != 0 {
            pageNumber = 1
            moviesArray = []
            moviesTableView.isHidden = true
            self.moviesSearchBar.isHidden = true
            for GenreID in genresIDs {
                if genresString == "" {
                    genresString = "\(GenreID)"
                } else {
                    genresString = "\(genresString),\(GenreID)"
                }
            }
            isGenreSelected = true
            filtersCollectionView.reloadData()
            //sortingDirection = "asc"
            getMovies(pg: selectedPGID, searchQuery: searchQuery)
            customActionSheet?.dismiss()
            AnalyticsHelper.GALogEventWith(name: "Movies-Filter By Genres \(genresString)", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Filters", itemName: "Movies-Filter By Genres \(genresString)", cType: "Button Action", screenName: "Movies")
        } else {
            genresString = ""
            pageNumber = 1
            moviesTableView.isHidden = true
            moviesArray = []
            isGenreSelected = false
           // sortingDirection = "asc"
            getMovies(pg: selectedPGID, searchQuery: searchQuery)
            customActionSheet?.dismiss()
            filtersCollectionView.reloadData()
        }
    }
    
    func cancelPressed(buttonType: String) {
        if buttonType == "Cancel" {
            customActionSheet?.dismiss()
        }
    }
}

extension MoviesViewController: LanguageFilterDelegate {
    func okPressed(selectedIndex: Int, isAr: Bool) {
        if selectedIndex != 0 {
            let language = languagesArray[selectedIndex]
            selectedLanguageID = language["id"] as! Int
            if selectedLanguageID != 0 {
                isLanguageSelected = true
            } else {
                isLanguageSelected = false
            }
            pageNumber = 1
            moviesArray = []
            moviesTableView.isHidden = true
            self.moviesSearchBar.isHidden = true
           // sortingDirection = "asc"
            getMovies(pg: selectedPGID, searchQuery: searchQuery)
            customActionSheet?.dismiss()
            
            AnalyticsHelper.GALogEventWith(name: "Movies-Filter By Language \(selectedLanguageID)", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Filters", itemName: "Movies-Filter By Language \(selectedLanguageID)", cType: "Button Action", screenName: "Movies")
        } else {
            if let selectedID = selectedLanguageCache["SelectedLanguage"] {
                print(selectedID)
                if isAr {
                    selectedLanguageID = 1
                    if selectedLanguageID != 0 {
                        isLanguageSelected = true
                    } else {
                        isLanguageSelected = false
                    }
                    pageNumber = 1
                    moviesArray = []
                    moviesTableView.isHidden = true
                    self.moviesSearchBar.isHidden = true
                   // sortingDirection = "asc"
                    getMovies(pg: selectedPGID, searchQuery: searchQuery)
                    customActionSheet?.dismiss()
                    
                    AnalyticsHelper.GALogEventWith(name: "Movies-Filter By Language \(selectedLanguageID)", category: "Button Action")
                    AnalyticsHelper.firebaseLogEvent(itemID: "Filters", itemName: "Movies-Filter By Language \(selectedLanguageID)", cType: "Button Action", screenName: "Movies")
                } else {
                    isLanguageSelected = false
                    pageNumber = 1
                    selectedLanguageID = 0
                    moviesArray = []
                    //sortingDirection = "asc"
                    getMovies(pg: selectedPGID, searchQuery: searchQuery)
                    customActionSheet?.dismiss()
                }
            } else {
                isLanguageSelected = false
                pageNumber = 1
                moviesArray = []
                //sortingDirection = "asc"
                getMovies(pg: selectedPGID, searchQuery: searchQuery)
                customActionSheet?.dismiss()
            }
        }
    }
    
    func cancelPressed() {
        customActionSheet?.dismiss()
    }
}

extension MoviesViewController: PGsFilterDelegate {
    func pgOkPressed(selectedIndex: Int) {
        if selectedIndex != 0 {
            let pg = pgsArray[selectedIndex - 1]
            selectedPGID = pg["name"] as! String
            self.filtersArray[self.filtersArray.count - 1] = selectedPGID
            if selectedPGID != "" {
                isPGSelected = true
            } else {
                isPGSelected = false
            }
            pageNumber = 1
            moviesArray = []
            moviesTableView.isHidden = true
            self.moviesSearchBar.isHidden = true
            //sortingDirection = "asc"
            getMovies(pg: selectedPGID, searchQuery: searchQuery)
            customActionSheet?.dismiss()
            
            AnalyticsHelper.GALogEventWith(name: "Movies-Filter By PG \(selectedPGID)", category: "Button Action")
            AnalyticsHelper.firebaseLogEvent(itemID: "Filters", itemName: "Movies-Filter By PG \(selectedPGID)", cType: "Button Action", screenName: "Movies")
        } else {
            selectedPGID = "" //"PG" //"All" //""
            self.filtersArray[self.filtersArray.count - 1] = selectedPGID
            isPGSelected = false
            pageNumber = 1
            moviesArray = []
            moviesTableView.isHidden = true
            //sortingDirection = "asc"
            getMovies(pg: selectedPGID, searchQuery: searchQuery)
            filtersCollectionView.reloadData()
            customActionSheet?.dismiss()
        }
    }
    
    func pgCancelPressed() {
        customActionSheet?.dismiss()
    }
}

func queenAttackingKing(queens: [[Int]], king: [Int] ) -> [[Int]] {
    var result = [[Int]]()
    
    //Places where we seen the queens
    var seen = [[Bool]]()
    for queen in queens {
        seen[queen[0]][queen[1]] = true
    }
    
    let directions = [-1, 0, 1]
    for dx in directions {      //X axis    --   //Y axis     |     //Together    *  will cover all the squares between the king
        for dy in directions {
            if dx == 0 && dy == 0 { continue }
            
            var x = king[0]
            var y = king[1]
            
            //location isn't outside of the boundries [LEFT, RIGHT, BOTTOM, TOP]
            while x + dx >= 0 && x + dx <= 8 && y + dy >= 0 && y + dy <= 8 {
                x += dx
                y += dy
                
                //if there was a queen at that place then add its coordinates and break because we don't need to continue going to that direction because even if there was a queen it won't be able to pass over the current queen
                if seen[dx][dy] {
                    result.append([x, y])
                    break;
                }
            }
        }
    }
    
    return result
}
