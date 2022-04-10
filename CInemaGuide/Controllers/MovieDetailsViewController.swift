//
//  MovieDetailsViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/2/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import TBEmptyDataSet
import Kingfisher
import AwesomeCache
//import SwiftWebVC
//import SwiftImageSlider
import GoogleMobileAds
//import Instabug
import Toast_Swift
import SafariServices

class MovieDetailsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, TBEmptyDataSetDelegate, TBEmptyDataSetDataSource{

    //MARK: - Properties
    @IBOutlet weak var navigationBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageTitleLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var movieImageBackground: UIImageView!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var is3DView: UIView!
    @IBOutlet weak var is3DHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pgView: UIView!
    @IBOutlet weak var pgLabel: UILabel!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var ratingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cgRatingView: UIView!
    @IBOutlet weak var cgRatingImage: UIImageView!
    @IBOutlet weak var cgRatingLabel: UILabel!
    @IBOutlet weak var cgRatingWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var imdbRateView: UIView!
    @IBOutlet weak var imdbRatingLabel: UILabel!
    @IBOutlet weak var imdbRatingWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var rottenTomatoView: UIView!
    @IBOutlet weak var rottenTomatoLabel: UILabel!
    @IBOutlet weak var rottenTomatoRatingWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var timeView: UIView!
    @IBOutlet weak var timeIcon: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var calenderImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var languagesView: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var languageLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var playingAtButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var movieDataTabelView: UITableView!
    @IBOutlet weak var shareButtonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var sponsorImageView: UIImageView!
    @IBOutlet weak var sponsorImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    
    var movieID : Int!
    var movieDetails : MovieModel!
    var cinemasArray = [CinemaModel]()
    var socialMediaLinks = [[String : Any]]()
    var webSiteURL = ""
    var traileersArray = [[String: Any]]()
    var galleryArray = [[String : Any]]()
    var isPlayingAt : Bool!
    let isRatedCache = try! Cache<NSNumber>(name: "IsRated")
    let cachedMovieIDs = try! Cache<NSMutableArray>(name: "MovieIDs")
    var imagesArray = [String]()
    var selectedMovieID = 0
    var errorMessage = ""
    var selectedCinemaID = 0
    var apiRating = ""
    var isMovieSponsored = false
    var isPushMovie = false
    var isPushCinema = false
    var pushMovieID = Int()
    var pushCinemaID = Int()
    let activityIndicatorView = UINib(nibName: "CustomActivityIndicator", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? CustomActivityIndicator
    var cinemasArrayWithAd = [AnyObject]()
    var isMPUEnabled = false
    var isInterestatialEnabled = false
    var isSponsorEnabled = false
    let dynamicView=UIView(frame: CGRect(x:0,y: 0, width:UIScreen.main.bounds.width, height:UIScreen.main.bounds.height))
    //MARK: - View life cycle functions
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
        
        movieDataTabelView.register(UINib(nibName: "MovieDetailsVideosTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieDetailsVideosTableCell")
        movieDataTabelView.register(UINib(nibName: "MovieDetailsImagesTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieDetailsImagesTableCell")
        movieDataTabelView.register(UINib(nibName: "MoviesDetailsInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieInfoCell")
        movieDataTabelView.register(UINib(nibName: "MovieDetailsCinemasTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieDetailsCinemaCell")
        movieDataTabelView.register(UINib(nibName: "MovieDetailsSocialLinksTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieSocialLinksCell")
        movieDataTabelView.register(UINib(nibName: "MovieDetailsHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "MovieDetailsSectionHeader")
        movieDataTabelView.register(UINib(nibName: "MediumRectTableViewCell", bundle: nil), forCellReuseIdentifier: "MediumRectCell")
        
        isPlayingAt = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.rateTheMovie(_:)))
        cgRatingView.addGestureRecognizer(tap)
        
        contentView.isHidden = true
        let frame = CGRect(x: self.view.center.x - 25, y: self.view.center.y - 25, width: 50, height: 50)
        activityIndicatorView?.frame = frame
        self.view.addSubview(activityIndicatorView!)
        
        if CinemaGuideLangs.currentAppleLanguage() == "ar" {
            shareButtonTrailingConstraint.constant = self.view.frame.size.width - 16 - shareButton.frame.size.width
            backButton.setImage(#imageLiteral(resourceName: "ArabicBackButton"), for: .normal)
        }
        isMPUEnabled = AppInfoHelper.isMpuEnabled()
        getMovieDetails(movieID: movieID)
        getMovieRate(movieID: movieID)
        self.sponsorImageViewHeightConstraint.constant = 0
        if AppInfoHelper.isVersionSponsorsed(){
            if AppInfoHelper.isMovieSponsored(movieId: movieID){
                self.sponsorImageView.isHidden = false
                sponsorImageView.kf.setImage(with: AppInfoHelper.getMovieSponsor(movieId: movieID), placeholder: nil, options: [.transition(.fade(0.5))], progressBlock: nil, completionHandler: { (image, error, cahce, url) in
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Set Our Fake NavigationBar Header Background Height
        navigationBannerHeightConstraint?.constant = UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        pageTitleLabel.textAlignment = .center
        movieTitleLabel.textAlignment = .center
        genresLabel.textAlignment = .center
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        NotificationCenter.default.addObserver(self, selector: #selector(self.openTrailer(notification:)), name: Notification.Name("OpenTrailerVideo"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openImage(notification:)), name: Notification.Name("SelectImage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openFacebookPage(notification:)), name: Notification.Name("OpenMovieFacebookPage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openTwitterPage(notification:)), name: Notification.Name("OpenMovieTwitterPage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openWebsite(notification:)), name: Notification.Name("OpenMovieWebPage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMovie(notification:)), name: Notification.Name("OpenMovieFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinema(notification:)), name: Notification.Name("OpenCinemaFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMoviesList(notification:)), name: Notification.Name("OpenMoviesListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.openCinemasList(notification:)), name: Notification.Name("OpenCinemasListFromDeepLink"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showPushNotificationAlert(notification:)), name: Notification.Name("ShowPushNotificationAlert"), object: nil)
        
//        screenName = "iOS-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())-\(CinemaGuideLangs.currentAppleLanguage())-Movie Details-With ID \(movieID ?? 0)"
        
        AnalyticsHelper.GAsetScreenName(With: "Movie Details-With ID \(movieID ?? 0)")
        AnalyticsHelper.firebaseSetScreenName(With: "Movie Details-With ID \(movieID ?? 0)", className: "MovieDetailsViewController.swift")
        AnalyticsHelper.firebaseLogEvent(itemID: "Movie Details View Controller", itemName: "Movie", cType: "View Movie", screenName: "Movie Details-With ID \(movieID ?? 0)")
        
        pageTitleLabel.textAlignment = .center
        movieTitleLabel.textAlignment = .center
        genresLabel.textAlignment = .center
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let appDelegate:AppDelegate=UIApplication.shared.delegate as! AppDelegate
        appDelegate.isUniversalLink=false
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Getting movie details
    func getMovieDetails(movieID: Int) {
        activityIndicatorView?.startActivityIndicator()
        APIManager.getMovieDetails(movieID: movieID, success: { (responseObject: MovieModel) -> Void in
            self.movieDetails = responseObject
            if self.movieDetails.id != 0{
            self.initContentView()
            }
            else{
                let alert = UIAlertController(title: "", message:NSLocalizedString("No data found, please try again later", comment: "No Data Found") , preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Key"), style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                DispatchQueue.main.async {
                    self.activityIndicatorView?.stopActivityIndicator()
                }
                
            }
        }) { (error: NSError?) -> Void in
//            Instabug.ibgLog(error?.description ?? "")

            if error?.description == "The Internet connection appears to be offline." {
                self.errorMessage = NSLocalizedString("No internet connection, check your connection and try again", comment: "No Internet Connection")
            } else {
                self.errorMessage = NSLocalizedString("This movie will be available soon in cinemas", comment: "Movie Available Soon")
            }
            self.activityIndicatorView?.stopActivityIndicator()
            
            let width = UIScreen.main.bounds.width
            
            let label = UILabel(frame: CGRect(x:0,y: UIScreen.main.bounds.midY, width:width, height:20))
            let tryaginBTN = UIButton(frame: CGRect(x:0,y: (UIScreen.main.bounds.midY + 40), width:width, height:20))
            tryaginBTN.addTarget(self, action: #selector(self.loadAgain), for: .touchUpInside)
               let emptyImage = UIImage(named: "NoDataIcon")
               let emptyImageView = UIImageView(frame: CGRect(x:0,y: 80, width:width, height:120))
               emptyImageView.image = emptyImage
            emptyImageView.contentMode = .scaleAspectFit
            self.dynamicView.addSubview(emptyImageView)
            
            let attributedString = NSMutableAttributedString(string: NSLocalizedString("No data found, please try again later", comment: ""))
            let range = (self.errorMessage as NSString).range(of: "No data found, please try again later")
            let font = UIFont(name: "SegoeUI-Bold", size: 16)
            attributedString.addAttributes([NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.init(red: 30/255, green: 46/255, blue: 56/255, alpha: 1)], range: range)
            label.text = attributedString.string
            tryaginBTN.setTitle("Try again", for: .normal)
            tryaginBTN.setTitleColor(.gray, for: .normal)
            self.dynamicView.backgroundColor=UIColor.clear
            label.textAlignment = .center
            self.dynamicView.addSubview(label)
            self.dynamicView.addSubview(tryaginBTN)
            self.scrollView.addSubview(self.dynamicView)
            
            
            
           // self.movieDataTabelView.setEmptyMessage(self.errorMessage)
//            self.contentView.isHidden = false
//            let messsageAlertController = UIAlertController(title:NSLocalizedString("errorConnection", comment: "errorConnection"), message: "error Connection", preferredStyle: .alert)
//            let settingAlertAction = UIAlertAction(title: NSLocalizedString("Setting", comment: "Setting") , style: .default) { _ in
//
//                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//                            return
//                        }
//
//                        if UIApplication.shared.canOpenURL(settingsUrl) {
//                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
//                                print("Settings opened: \(success)") // Prints true
//                            })
//                        }
//            }
//            let retryAlertAction = UIAlertAction(title: NSLocalizedString("retry", comment: "Retry") , style: .default) { _ in
//                self.getMovieDetails(movieID: movieID)
//
//            }
//            messsageAlertController.addAction(settingAlertAction)
//            messsageAlertController.addAction(retryAlertAction)
//            self.present(messsageAlertController, animated: true);
            
//            self.movieDataTabelView.emptyDataSetDataSource = self
//            self.movieDataTabelView.emptyDataSetDelegate = self
//            self.movieDataTabelView.reloadData()
//
            
        }
    }
    
    @objc func loadAgain()  {
        self.dynamicView.removeFromSuperview()
        self.getMovieDetails(movieID: selectedMovieID)
        getMovieRate(movieID: selectedMovieID)
    }
    func getMovieRate(movieID: Int)  {
        APIManager.getMovieRate(movieID: movieID, success: { (movieRate: [String: Any]) -> Void in
            self.apiRating = (movieRate["movieRate"] as? String)!
            if self.movieDetails != nil && self.movieDetails.id != 0 {
                self.initContentView()
            }
        
        }) { (error: NSError?) in
//            Instabug.ibgLog(error?.description ?? "")
             
            print(error?.description ?? "")
        }
    }
    
    func initContentView() {
        pageTitleLabel.text = movieDetails.title
        let URLs = movieDetails.poster
        let posterURLs = URLs?["url"] as! [String: Any]
        let posterURLString = posterURLs["large"] as! String
        let posterURL = URL(string: "\(AppInfoHelper.getMediaBaseURL())\(posterURLString)")
        movieImageBackground.kf.setImage(with: posterURL)
        movieImage.kf.setImage(with: posterURL, placeholder: #imageLiteral(resourceName: "PlaceholderPortrait"), options: [.transition(.fade(0.3))], progressBlock: nil, completionHandler: nil)
        if !movieDetails.is3d {
            is3DView.isHidden = true
            is3DHeightConstraint.constant = 0
        } else {
            is3DView.isHidden = false
        }
        if movieDetails.parentalGuidance != "" {
            pgLabel.text = movieDetails.parentalGuidance
        } else {
            pgView.isHidden = true
        }
        var genresString = ""
        movieTitleLabel.text = movieDetails.title
        movieTitleLabel.textAlignment = .center
        let genresArray = movieDetails.genres
        for genre in genresArray! {
            let theGenre = genre as! [String: Any]
            if genresString == "" {
                genresString = theGenre["name"] as! String
            } else {
                genresString = genresString + " / \(theGenre["name"] ?? "")"
            }
        }
        genresLabel.text = genresString
        var ratesCount = 3
        cgRatingLabel.text = apiRating
        if movieDetails.imdbRate == 0.0 {
            imdbRateView.isHidden = true
            imdbRatingWidthConstraints.constant = 0
            ratesCount = ratesCount - 1
        } else {
            imdbRatingLabel.text = "\(movieDetails.imdbRate ?? 0.0)"
        }
        if movieDetails.rottenTomatoRate == 0 {
            rottenTomatoView.isHidden = true
            rottenTomatoRatingWidthConstraints.constant = 0
            ratesCount = ratesCount - 1
        } else {
            rottenTomatoLabel.text = "\(movieDetails.rottenTomatoRate ?? 0)%"
        }
        if ratesCount == 0 {
            ratingView.isHidden = true
            ratingViewHeightConstraint.constant = 0
        } else {
            ratingViewWidthConstraint.constant = CGFloat(Int(cgRatingView.frame.size.width) * ratesCount)
        }
        if movieDetails.duration == 0 {
            timeIcon.isHidden = true
            durationLabel.isHidden = true
        } else {
            if CinemaGuideLangs.currentAppleLanguage() == "ar" {
                durationLabel.text = "\(localizeNum(movieDetails.duration ?? 0)!) دقيقة"
            } else {
                durationLabel.text = "\(localizeNum(movieDetails.duration ?? 0)!) M"
            }
        }
        if movieDetails.releaseDate == "" {
            calenderImage.isHidden = true
            dateLabel.isHidden = true
        } else {
            dateLabel.text = localizeDate(movieDetails.releaseDate!) ?? ""
        }
        if movieDetails.language == "" {
            languageLabel.isHidden = true
        } else {
            let localizedLanguage = NSLocalizedString("Language", comment: "Language Key")
            print(localizedLanguage)
            print(movieDetails.language)
            if movieDetails.language == "English"{
            languageLabel.text = localizedLanguage + ": \( NSLocalizedString(movieDetails.language ?? "" , comment: "") )"
            }
            else
            {
               languageLabel.text = localizedLanguage + ": \( NSLocalizedString("arabic" , comment: "") )"
            }
        }
        if movieDetails.subtitle == "" {
            subtitleLabel.isHidden = true
            languageLabelLeadingConstraint.constant = languagesView.frame.size.width / 2 - languageLabel.intrinsicContentSize.width / 2
        } else {
           
            let localizedSubtitle = NSLocalizedString("Subtitle: ", comment: "Subtitle Key")
            subtitleLabel.text = localizedSubtitle + "\( NSLocalizedString("arabic", comment: "") )"
        }
        contentView.isHidden = false
        pageTitleLabel.textAlignment = .center
        movieTitleLabel.textAlignment = .center
        genresLabel.textAlignment = .center
        cinemasArray = movieDetails.cinemas
        if cinemasArray.count != 0 {
            cinemasArrayWithAd = cinemasArray
            let ad = ["ad": "true"]
            let adsCount = cinemasArrayWithAd.count / 5
            if cinemasArray.count < 5 {
                cinemasArrayWithAd.append(ad as AnyObject)
            } else {
                for i in 0 ... cinemasArrayWithAd.count + adsCount - 1 {
                    if i != 0 {
                        if i <= 5 {
                            if i % 5 == 0 {
                                cinemasArrayWithAd.insert(ad as AnyObject, at: i)
                            }
                        } else {
                            if i > 6 && i % 6 == 0 {
                                cinemasArrayWithAd.insert(ad as AnyObject, at: i)
                            }
                        }
                    }
                }
            }
        }
        webSiteURL = movieDetails.websiteURL
        socialMediaLinks = movieDetails.socialMediaLinks
        traileersArray = movieDetails.trailers
        galleryArray = movieDetails.movieGallery
        self.errorMessage = NSLocalizedString("This movie will be available soon in cinemas", comment: "Movie Available Soon")
        movieDataTabelView.emptyDataSetDelegate = self
        movieDataTabelView.emptyDataSetDataSource = self
        movieDataTabelView.reloadData()
        resizeScrollView()
        if let cachedIDs = cachedMovieIDs["MovieIDs"] {
            for id in cachedIDs {
                if movieDetails.id == id as! Int {
                    isRatedCache["IsRated"] = 1
                    break
                } else {
                    isRatedCache["IsRated"] = 0
                }
            }
        }
        
        if let isRated = isRatedCache["IsRated"] {
            let rated = Bool.init(isRated)
            if rated {
                cgRatingImage.image = #imageLiteral(resourceName: "StarIconCircle")
            } else {
                cgRatingImage.image = #imageLiteral(resourceName: "StarIconNavy")
            }
        } else {
            cgRatingImage.image = #imageLiteral(resourceName: "StarIconNavy")
        }
        DispatchQueue.main.async {
            self.activityIndicatorView?.stopActivityIndicator()
        }
        resizeScrollView()
    }

    func tableViewHeight() -> CGFloat {
        if cinemasArray.count == 0 && isPlayingAt {
            return 580
        }
        self.movieDataTabelView.layoutIfNeeded()
        return self.movieDataTabelView.contentSize.height
    }
    
    func resizeScrollView() {
        pageTitleLabel.textAlignment = .center
        movieTitleLabel.textAlignment = .center
        genresLabel.textAlignment = .center
        movieDataTabelView.isScrollEnabled = false
        let tableHeight = tableViewHeight()
        contentViewHeightConstraints.constant = CGFloat(Int(tableHeight) + 540)
    }
    
    @IBAction func playingAtButtonPressed(_ sender: UIButton) {
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        isPlayingAt = true
        playingAtButton.setTitleColor(#colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1), for: .normal)
        playingAtButton.backgroundColor = #colorLiteral(red: 0.1800381839, green: 0.2748469114, blue: 0.3280926645, alpha: 1)
        detailsButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.5960784314, blue: 0.6039215686, alpha: 1), for: .normal)
        detailsButton.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8823529412, blue: 0.8705882353, alpha: 1)
        self.errorMessage = NSLocalizedString("This movie will be available soon in cinemas", comment: "Movie Available Soon")
        movieDataTabelView.emptyDataSetDelegate = self
        movieDataTabelView.emptyDataSetDataSource = self
        movieDataTabelView.reloadData()
        
        AnalyticsHelper.GALogEventWith(name: "Movie Details-With ID \(movieID) Playing at button", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Movie Details", itemName: "Movie Details-With ID \(movieID) Playing at button", cType: "Button Action", screenName: "Movie Details")
    }
    
    @IBAction func didTapMovieImageView(_ sender: Any) {
        var photos = [MWPhoto]()
        photos.append(MWPhoto(image: self.movieImage.image))
        if let controller = MWPhotoBrowser(photos: photos) {
            controller.displayActionButton = true // Show action button to allow sharing, copying, etc (defaults to YES)
            controller.alwaysShowControls = true // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
            controller.modalPresentationStyle = .fullScreen
            //present(controller!, animated: true, completion: nil)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func detailsButtonPressed(_ sender: UIButton) {
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        isPlayingAt = false
        detailsButton.setTitleColor(#colorLiteral(red: 1, green: 0.771550715, blue: 0, alpha: 1), for: .normal)
        detailsButton.backgroundColor = #colorLiteral(red: 0.1800381839, green: 0.2748469114, blue: 0.3280926645, alpha: 1)
        playingAtButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.5960784314, blue: 0.6039215686, alpha: 1), for: .normal)
        playingAtButton.backgroundColor = #colorLiteral(red: 0.8901960784, green: 0.8823529412, blue: 0.8705882353, alpha: 1)
        self.errorMessage = NSLocalizedString("This movie will be available soon in cinemas", comment: "Movie Available Soon")
        movieDataTabelView.emptyDataSetDelegate = self
        movieDataTabelView.emptyDataSetDataSource = self
        movieDataTabelView.reloadData()
        
        AnalyticsHelper.GALogEventWith(name: "Movie Details-With ID \(movieID) Details button", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Movie Details", itemName: "Movie Details-With ID \(movieID) Details button", cType: "Button Action", screenName: "Movie Details")
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        let shareText = movieDetails.title
        let shareURL = URL(string: "https://www.filbalad.com/ar/movies/details/\(movieDetails.id ?? 0)")
        if let image = movieImage.image {
            let vc = UIActivityViewController(activityItems: [shareText ?? "", shareURL ?? "", image], applicationActivities: [])
            present(vc, animated: true, completion: nil)
        } else {
            let vc = UIActivityViewController(activityItems: [shareText ?? "", shareURL ?? ""], applicationActivities: [])
            present(vc, animated: true, completion: nil)
        }
        
        AnalyticsHelper.GALogEventWith(name: "Movie Details-With ID \(movieID) Share button", category: "Button Action")
        AnalyticsHelper.firebaseLogEvent(itemID: "Movie Details", itemName: "Movie Details-With ID \(movieID) Share button", cType: "Button Action", screenName: "Movie Details")
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Table view functions
    func numberOfSections(in tableView: UITableView) -> Int {
        if isPlayingAt {
            return 1
        } else if !isPlayingAt {
            return 5
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isPlayingAt {
            if cinemasArrayWithAd.count != 0 {
                return cinemasArrayWithAd.count
            }
        } else if !isPlayingAt {
            return 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isPlayingAt {
            let cinemaData = cinemasArrayWithAd[indexPath.row]
            if cinemaData.isKind(of: CinemaModel.self) {
                let cinemaCell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailsCinemaCell", for: indexPath) as! MovieDetailsCinemasTableViewCell
                cinemaCell.initCellWith(cinemaData: cinemaData as! CinemaModel)
                return cinemaCell
            } else {
               // let mediumRectAdCell = tableView.dequeueReusableCell(withIdentifier: "MediumRectCell", for: indexPath) as! MediumRectTableViewCell
                let mediumRectCell = UITableViewCell()
                if isMPUEnabled {
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

                    //mediumRectAdCell.mediumRectView.rootViewController = self
                    //mediumRectAdCell.initCellWith(adUnitID: "/7524/Mobile-FilBalad.com/Cinema-Guide-MPU")
                } else {
                    //mediumRectAdCell.adSpaceLabel.isHidden = true
                }
                return mediumRectCell
            }
        } else {

            if indexPath.section == 0 {
                let socialLinksCell = tableView.dequeueReusableCell(withIdentifier: "MovieSocialLinksCell", for: indexPath) as! MovieDetailsSocialLinksTableViewCell
                socialLinksCell.initCellWith(socialURLs: socialMediaLinks, webSiteURL: webSiteURL)
                return socialLinksCell
            } else if indexPath.section == 1 {
                let trailersCell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailsVideosTableCell", for: indexPath) as! MovieDetailsVideosTableViewCell
                trailersCell.initCellWith(trailersArray: traileersArray)
                return trailersCell
            } else if indexPath.section == 2 {
//                return UITableViewCell()
                let mediumRectAdCell = tableView.dequeueReusableCell(withIdentifier: "MediumRectCell", for: indexPath) as! MediumRectTableViewCell
                if isMPUEnabled {
                    mediumRectAdCell.mediumRectView.rootViewController = self
                    mediumRectAdCell.initCellWith(adUnitID: "/7524/Mobile-FilBalad.com/Cinema-Guide-MPU")
                }
                return mediumRectAdCell
            } else if indexPath.section == 3 {
                let galleryCell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailsImagesTableCell", for: indexPath) as! MovieDetailsImagesTableViewCell
                galleryCell.initCellWith(galleryData: galleryArray)
                return galleryCell
            } else {
                let castCell = tableView.dequeueReusableCell(withIdentifier: "MovieInfoCell", for: indexPath) as! MoviesDetailsInfoTableViewCell
                castCell.initCellWith(movieDetails: movieDetails)
                castCell.directorLabel.textAlignment = .center
                castCell.directorsNamesLabel.textAlignment = .center
                castCell.castLabel.textAlignment = .center
                castCell.castNamesLabel.textAlignment = .center
                castCell.storyLineLabel.textAlignment = .center
                castCell.storyLineStringLabel.textAlignment = .center
                return castCell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if isPlayingAt {
            let theCinema = cinemasArrayWithAd[indexPath.row]
            if theCinema.isKind(of: CinemaModel.self) {
                let defaultValue = NSLocalizedString("le", comment: "defaultCurrency");
                print(UserDefaults.standard.object(forKey: "Currency"))
                let currencey:String = (UserDefaults.standard.object(forKey: "Currency") ?? defaultValue.uppercased())as! String
                let cinemaData = cinemasArrayWithAd[indexPath.row] as! CinemaModel
                var showTimesString = ""
                var times = [String]()
                var price = 0
                var timesString = ""
                for showTimeData in cinemaData.showTimes {
                    times = showTimeData["times"] as! [String]
                    price = showTimeData["price"] as! Int
                    if times.count != 0 {
                        for aTime in times {
                            if timesString == "" {
                                timesString = aTime
                            } else {
                                timesString = timesString + " | " + aTime
                            }
                        }
                        if showTimesString == "" {
                            showTimesString = "\(price) \(NSLocalizedString(currencey, comment: "")) \(timesString)" //LE
                        } else {
                            showTimesString = showTimesString + " - \(price) \(NSLocalizedString(currencey, comment: "")) \(timesString)" //LE
                        }
                    }
                }
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 32, height: .greatestFiniteMagnitude))
                label.font = UIFont(name: "SegoeUI-Bold", size: 10)
                label.numberOfLines = 0
                label.text = showTimesString
                label.sizeToFit()
                resizeScrollView()
                return 66 + label.frame.size.height
            } else {
                if !isMPUEnabled {
                    return 0
                }
                return 266
            }
        } else {
            if indexPath.section == 0 {
                for aSocilalLink in socialMediaLinks {
                    if aSocilalLink["link"] as! String == "" {
                        return 0
                    }
                }
                if socialMediaLinks.count != 0 {
                    resizeScrollView()
                    return 60
                }
                return 0
            } else if indexPath.section == 1 {
                if traileersArray.count != 0 {
                    resizeScrollView()
                    return 175
                }
                return 0
            } else if indexPath.section == 2 {
//                if !isMPUEnabled {
//                    return 0
//                }
                return 266
            } else if indexPath.section == 3 {
                if galleryArray.count != 0 {
                    print(galleryArray.count)
                    var count = Double(galleryArray.count)
                    count = count / 3
                    if count > 0 && count < 1 {
                        count = 1
                    } else if count > 1 && count < 2 {
                        count = 2
                    } else if count > 2 && count < 3 {
                        count = 3
                    } else if count > 3 && count < 4 {
                        count = 4
                    } else if count > 4 && count < 5 {
                        count = 5
                    }
                    resizeScrollView()
                    return CGFloat(135 * count)
                }
                return 0
            } else {
                let storyLineLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 32, height: .greatestFiniteMagnitude))
                storyLineLabel.font = UIFont(name: "SegoeUI-Bold", size: 14)
                storyLineLabel.numberOfLines = 0
                storyLineLabel.text = movieDetails.synopsis
                storyLineLabel.sizeToFit()
                resizeScrollView()
                return 230 + storyLineLabel.frame.size.height
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if !isPlayingAt {
            resizeScrollView()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !isPlayingAt {
            if section == 0 {
                if socialMediaLinks.count != 0 {
                    for aSocilalLink in socialMediaLinks {
                        if aSocilalLink["link"] as! String == "" {
                            return 0
                        }
                    }
                    return 30
                }
            } else if section == 1 {
                if traileersArray.count != 0 {
                    return 30
                }
            } else if section == 3 {
                if galleryArray.count != 0 {
                    return 30
                }
            }
            return 0.000000001
        }
        return 0.00000001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderCell = tableView.dequeueReusableCell(withIdentifier: "MovieDetailsSectionHeader") as! MovieDetailsHeaderTableViewCell
        if !isPlayingAt {
            if section == 0 && socialMediaLinks.count != 0 {
                sectionHeaderCell.sectionHeaderLabel.text = NSLocalizedString("Links", comment: "Links Key")
            } else if section == 1 && traileersArray.count != 0 {
                sectionHeaderCell.sectionHeaderLabel.text = NSLocalizedString("Videos", comment: "Videos Key")
            } else if section == 3 && galleryArray.count != 0 {
                sectionHeaderCell.sectionHeaderLabel.text = NSLocalizedString("Gallery", comment: "Gallery Key")
            } else {
                sectionHeaderCell.sectionHeaderLabel.text = ""
            }
        } else {
            sectionHeaderCell.sectionHeaderLabel.text = ""
        }
        return sectionHeaderCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isPlayingAt {
            return 75
        } else {
            if section == 4 {
                let font = UIFont(name: "SegoeUI", size: 24)
                let fontAttributes = [NSAttributedString.Key.font: font]
                let myText = movieDetails.synopsis
                let size = (myText as! NSString).size(withAttributes: fontAttributes)
                return 75 + size.height
            }
        }
        return 0.000000001
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isPlayingAt {
            let theCinema = cinemasArrayWithAd[indexPath.row]
            if theCinema.isKind(of: CinemaModel.self) {
                if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
                    let theCount = count as! NSNumber
                    var countInt = Int(theCount)
                    countInt = countInt + 1
                    UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
                }
                let cinema = theCinema as! CinemaModel
                selectedCinemaID = cinema.id
                self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
            }
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
    
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetTapEnabled(in scrollView: UIScrollView) -> Bool {
        return true
    }
    
    //MARK: - Actions and Navigations
    @objc func openImage(notification: Notification) {
        let imageData = notification.object as! [String: Any]
        let selectedImageIndex = imageData["SelectedIndex"] as! Int
        imagesArray = imageData["ImagesArray"] as! [String]
        //let controller = ImageSliderViewController(currentIndex: selectedImageIndex, imageUrls: imagesArray)
        let photos = imagesArray.flatMap { MWPhoto(url: URL(string: $0)) }
        if let controller = MWPhotoBrowser(photos: photos) {
            self.navigationController?.pushViewController(controller, animated: true)
            //present(controller!, animated: true, completion: nil)
        }
    }
    
    @objc func openTrailer(notification: Notification) {
        let trailerURL = notification.object as! String
        //let wvc = SwiftModalWebVC(urlString: trailerURL.trimmingCharacters(in: .whitespaces), theme: .dark, dismissButtonStyle: .cross)
        //self.present(wvc, animated: true, completion: nil)
        openSafariWebViewController(string: trailerURL) //webSiteURL
    }
    
    @objc func openFacebookPage(notification: Notification) {
        let facebookPageURL = notification.object as! String
        //let wvc = SwiftModalWebVC(urlString: facebookPageURL, theme: .dark, dismissButtonStyle: .cross)
        //self.present(wvc, animated: true, completion: nil)
        openSafariWebViewController(string: facebookPageURL) //webSiteURL
    }
    
    @objc func openTwitterPage(notification: Notification) {
        let twitterAccountURL = notification.object as! String
        //let wvc = SwiftModalWebVC(urlString: twitterAccountURL, theme: .dark, dismissButtonStyle: .cross)
        //self.present(wvc, animated: true, completion: nil)
        openSafariWebViewController(string: twitterAccountURL) //webSiteURL
    }
    
    @objc func openWebsite(notification: Notification) {
        //let wvc = SwiftModalWebVC(urlString: webSiteURL, theme: .dark, dismissButtonStyle: .cross)
        //self.present(wvc, animated: true, completion: nil)
        openSafariWebViewController(string: webSiteURL) //webSiteURL
    }
    
    func openSafariWebViewController(string: String) {
        if #available(iOS 9.0, *) {
            if let url = URL(string: string) {
                    let vc = SFSafariViewController(url: url)
                    self.present(vc, animated: true)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func rateTheMovie(_ sender: UITapGestureRecognizer) {
        func thankYouAlert() {
            let alert = UIAlertController(title: NSLocalizedString("Thank you", comment: "Thank you"), message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Ok"), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        if let isRated = isRatedCache["IsRated"] {
            let rated = Bool.init(isRated)
            if rated {
                let alert = UIAlertController(title: NSLocalizedString("", comment: "Error Key"), message: NSLocalizedString("You already rated this movie", comment: "Rating Key"), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: "Cancel Key"), style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                if let cache = cachedMovieIDs["MovieIDs"] {
                    let cacheArray = cache.mutableCopy() as! NSMutableArray
                    cacheArray.add(movieDetails.id)
                    cachedMovieIDs["MovieIDs"] = cacheArray
                } else {
                    let cacheArray = NSMutableArray()
                    cacheArray.add(movieDetails.id)
                    cachedMovieIDs["MovieIDs"] = cacheArray
                }
                isRatedCache["IsRated"] = 1
                cgRatingImage.image = #imageLiteral(resourceName: "StarIconCircle")
                let rating = Int(apiRating)
                cgRatingLabel.text = "\(rating! + 1)"
                APIManager.rateMovie(movieID: movieDetails.id, success: { (ResponseObject: [String: Any]) -> Void in
                    print(ResponseObject["Success"] ?? "")
                    thankYouAlert()
                }, failure: { (error: NSError?) -> Void in
//                    Instabug.ibgLog(error?.description ?? "")

//                    Instabug.ibgLog(error?.description ?? "")
                    print(error?.description ?? "")
                })
            }
        } else {
            let cacheArray = NSMutableArray()
            cacheArray.add(movieDetails.id)
            cachedMovieIDs["MovieIDs"] = cacheArray
            isRatedCache["IsRated"] = 1
            cgRatingImage.image = #imageLiteral(resourceName: "StarIconCircle")
            let rating = Int(apiRating)
            cgRatingLabel.text = "\(rating! + 1)"
            APIManager.rateMovie(movieID: movieDetails.id, success: { (ResponseObject: [String: Any]) -> Void in
                print(ResponseObject["Success"] ?? "")
                thankYouAlert()
            }, failure: { (error: NSError?) -> Void in
//                Instabug.ibgLog(error?.description ?? "")
                print(error?.description ?? "")
            })
        }
    }
    
    @objc func openMovie(notification: Notification) {
        selectedMovieID = notification.object as! Int
        contentView.isHidden = true
        movieDataTabelView.isHidden = true
        movieID = selectedMovieID
        getMovieDetails(movieID: selectedMovieID)
        getMovieRate(movieID: selectedMovieID)
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
        if segue.identifier == "NavigateToCinema" {
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
                self.contentView.isHidden = false
                self.movieDataTabelView.isHidden = false
                self.movieID = self.selectedMovieID
                self.getMovieDetails(movieID: self.selectedMovieID)
                self.getMovieRate(movieID: self.selectedMovieID)
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
    

    
}

extension UITableView {
func setEmptyMessage(_ message: String) {
    
    let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
    messageLabel.text = message
    messageLabel.textColor = .black
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = .center;
    messageLabel.font = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
    messageLabel.sizeToFit()

    self.backgroundView = messageLabel;
    self.separatorStyle = .none;
}}
