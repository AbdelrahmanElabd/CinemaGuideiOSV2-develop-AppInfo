//
//  FavoriteCinemasViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/20/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import TBEmptyDataSet
import AwesomeCache
import GoogleMobileAds
import Toast_Swift
class FavoriteCinemasViewController: BaseViewController, TBEmptyDataSetDelegate, TBEmptyDataSetDataSource, UIGestureRecognizerDelegate {

    //MARK: - Properties
    @IBOutlet weak var favoriteCinemasTableView: UITableView!
    @IBOutlet weak var navigationBannerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sponsorImageView: UIImageView!
    @IBOutlet weak var sponsorImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var navBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bannerMainView: UIView!
    @IBOutlet weak var adsAreaLabel: UILabel!
    var bannerView: GADBannerView!
    var favoriteCinemasArray = [CinemaModel]()
    var errorMessage = ""
    var selectedCinemaID = 0
    var selectedMovieID: Int!
    var isPushMovie = false
    var isPushCinema = false
    var pushMovieID = Int()
    var pushCinemaID = Int()
    var favoriteCinemasIDsArray = [Int]()
    let activityIndicatorView = UINib(nibName: "CustomActivityIndicator", bundle: nil).instantiate(withOwner: self, options: nil)[0] as? CustomActivityIndicator
    var favoriteCinemasArrayOfDict = NSMutableArray()
    var isInterestatialEnabled = false
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
        
        //Effective Measure
        //let tracker = EmTracker()
        //tracker.verbose = true
        //tracker.configure("CinemaGuideMobileApp", tld: "filbalad.com", sdkKey: "2da9a01d-0fc7-4902-8d34-9f37d5bc55f6")
        //tracker.trackDefault()
        
        editButton.setTitle(NSLocalizedString("Edit", comment: "Edit Key"), for: .normal)
        favoriteCinemasTableView.register(UINib(nibName: "FavoriteCinemasTableViewCell", bundle: nil), forCellReuseIdentifier: "FavoriteCinemaCell")
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.openMovie(notification:)), name: Notification.Name("openMovie"), object: nil)
        
        if  UserDefaults.standard.object(forKey:"FavsCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())") != nil{
            let favorites = UserDefaults.standard.object(forKey:"FavsCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())") as! [Int]
            favoriteCinemasIDsArray = favorites
                favoriteCinemasArray = Helper.favCinemas
            if (favoriteCinemasArray.count == 0){
                       editButton.isHidden = true
                   }
                favoriteCinemasTableView.emptyDataSetDelegate = self
                favoriteCinemasTableView.emptyDataSetDataSource = self
                errorMessage = NSLocalizedString("You can add your favorite cinemas here", comment: "Add Favorite Cinema")
                favoriteCinemasTableView.reloadData()
                favoriteCinemasTableView.isHidden = false
        }
        else {
            favoriteCinemasTableView.isHidden = false
            favoriteCinemasTableView.emptyDataSetDelegate = self
            favoriteCinemasTableView.emptyDataSetDataSource = self
            errorMessage = NSLocalizedString("You can add your favorite cinemas here", comment: "Add Favorite Cinema")
            favoriteCinemasTableView.reloadData()
        }
        
//        screenName = "iOS-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())-\(CinemaGuideLangs.currentAppleLanguage())-Favorite Cinemas"
        AnalyticsHelper.GAsetScreenName(With: "Favorite Cinemas")
        AnalyticsHelper.firebaseSetScreenName(With: "Favorite Cinemas", className: "FavoriteCinemasViewController.swift")
        AnalyticsHelper.firebaseLogEvent(itemID: "Favorite Cinemas View Controller", itemName: "Favorite Cinemas", cType: "View Favorite Cinemas", screenName: "Favorite Cinemas")
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
        bannerView=GADBannerView.init(adSize:  kGADAdSizeBanner, origin:CGPoint(x:(UIScreen.main.bounds.width-300)/2-10,y:0))//y: 5 y: 10
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
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
            
            self.favoriteCinemasTableView.reloadData()
        }
        [remove, cancel].forEach { alert.addAction($0) }
        self.present(alert, animated: true, completion: nil)
    }
    */

    // MARK: - Empty data set functions
    func titleForEmptyDataSet(in scrollView: UIScrollView) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: self.errorMessage)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let range = (self.errorMessage as NSString).range(of: self.errorMessage)
        let font = UIFont(name: "SegoeUI-Bold", size: 16)
        attributedString.addAttributes([NSAttributedString.Key.font : font!, NSAttributedString.Key.foregroundColor : UIColor.init(red: 30/255, green: 46/255, blue: 56/255, alpha: 1), NSAttributedString.Key.paragraphStyle: paragraphStyle], range: range)
        return attributedString
    }
    
    func emptyDataSetShouldDisplay(in scrollView: UIScrollView) -> Bool {
        return true
    }
    
    func emptyDataSetTapEnabled(in scrollView: UIScrollView) -> Bool {
        return true
    }
    
    //MARK: - Edit actions
    @IBAction func editButtonPressed(_ sender: UIButton) {
        if favoriteCinemasTableView.isEditing {
            favoriteCinemasTableView.isEditing = false
            editButton.setTitle(NSLocalizedString("Edit", comment: "Edit Key"), for: .normal)
        } else {
            favoriteCinemasTableView.isEditing = true
            editButton.setTitle(NSLocalizedString("Done", comment: "Done Key"), for: .normal)
        }
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
        if segue.identifier == "NavigateToCinema" {
            let destination = segue.destination as! CinemaDetailsViewController
            destination.cinemaID = selectedCinemaID
        }
        if segue.identifier == "NavigateToMovieDetails" {
            let destination = segue.destination as! MovieDetailsViewController
            destination.movieID = selectedMovieID
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
}
extension FavoriteCinemasViewController:UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if favoriteCinemasArray.count != 0 {
            editButton.isHidden = false
            return 1
        }
        else{
        editButton.isHidden = true
        return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteCinemasArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favoriteCinemasCell = tableView.dequeueReusableCell(withIdentifier: "FavoriteCinemaCell", for: indexPath) as! FavoriteCinemasTableViewCell
        let cinema = favoriteCinemasArray[indexPath.row] 
        favoriteCinemasCell.initCellWith(movies: cinema.movies, cinemaName: cinema.name)
        favoriteCinemasCell.deleteButton.isHidden = true
        //favoriteCinemasCell.deleteButton.tag = indexPath.row
        //favoriteCinemasCell.deleteButton.addTarget(self, action: #selector(deleteFavoriteCinema(_:)), for: .touchUpInside)
        return favoriteCinemasCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 155
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.000001
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 49
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let count = UserDefaults.standard.object(forKey: "ClickCountCache") {
            let theCount = count as! NSNumber
            var countInt = Int(theCount)
            countInt = countInt + 1
            UserDefaults.standard.set(countInt, forKey: "ClickCountCache")
        }
        let cinema = favoriteCinemasArray[indexPath.row]
        selectedCinemaID = cinema.id
        self.performSegue(withIdentifier: "NavigateToCinema", sender: self)
    }
    
    func imageForEmptyDataSet(in scrollView: UIScrollView) -> UIImage? {
        return UIImage.init(named: "NoFavCinemasIcon")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let index = getFavoriteCinemaIndex(cinemaId:favoriteCinemasArray[indexPath.row].id )
            favoriteCinemasIDsArray.remove(at: getCinemaIndex(cinemaId: favoriteCinemasArray[indexPath.row].id) )
            favoriteCinemasArray.remove(at: index)
            Helper.favCinemas.remove(at: index)

            let defaults = UserDefaults.standard
            defaults.set(favoriteCinemasIDsArray, forKey: "FavsCinemasIDs-\(UserDefaults.standard.object(forKey: "UserCountry") ?? "EG".uppercased())")
            defaults.synchronize()
            if favoriteCinemasArray.count == 0 {
                favoriteCinemasTableView.isHidden = false
                favoriteCinemasTableView.emptyDataSetDelegate = self
                favoriteCinemasTableView.emptyDataSetDataSource = self
                errorMessage = NSLocalizedString("You can add your favorite cinemas here", comment: "Add Favorite Cinema")
                tableView.setEditing(false, animated: true)
                editButton.setTitle(NSLocalizedString("Edit", comment: "Edit Key"), for: .normal)
            }
            
            favoriteCinemasTableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if CinemaGuideLangs.currentAppleLanguage() == "ar" {
            return "حذف"
        } else {
            return "Delete"
        }
    }
}
