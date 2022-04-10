//
//  LanguageAndCountriesViewController.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 1/15/18.
//  Copyright © 2018 HeshamHaleem. All rights reserved.
//

import UIKit
//import Instabug
class LanguageAndCountriesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //MARK: - Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var changeInSettingsLabel: UILabel!
    
    var isLanguageChoice = Bool()
    var countriesArray = [CountryModel]()
    let languagesArray = ["English", "عربي"]
    var selectedLanguage: String!
    var selectedCountry: CountryModel!
    
    //MARK: - View lifecycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        isLanguageChoice = true
        confirmButton.setTitle( "موافق" , for: .normal)
        tableView.register(UINib(nibName: "LanguagesAndCountriesTableViewCell", bundle: nil), forCellReuseIdentifier: "LanguagesAndCountriesCell")
        if isLanguageChoice {
            tableViewHeightConstraint.constant = CGFloat(languagesArray.count * 50)
            titleLabel.text = NSLocalizedString(" إختر اللغه", comment: "choose language key")
        } else {
            titleLabel.text = NSLocalizedString(" إختر البلد", comment: "choose country key")
        }
        getCountries()
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.3
        confirmButton.setTitle("إستمرار", for: .normal)
        
        changeInSettingsLabel.text = NSLocalizedString("You can change this in app settings later", comment: "change in settings key")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Getting countries
    func getCountries() {
        APIManager.getCountries(success: { (responseObject) in
            self.countriesArray = responseObject
            if !self.isLanguageChoice {
                self.tableView.reloadData()
            }
        }) { (error: NSError?) -> Void in
            self.getCountries()
//            Instabug.ibgLog(error?.description ?? "")
        }
    }
    
    //MARK: - Tableview functions
    func numberOfSections(in tableView: UITableView) -> Int {
        if !isLanguageChoice {
            if countriesArray.count == 0 {
                return 0
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLanguageChoice {
            return languagesArray.count
        }
        return countriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LanguagesAndCountriesCell", for: indexPath) as! LanguagesAndCountriesTableViewCell
        cell.isSelectedImageView.isHidden = true
        if isLanguageChoice {
            cell.initCellWith(imageURL: "", labelText: languagesArray[indexPath.row])
        } else {
            cell.initCellWith(imageURL: "\(AppInfoHelper.getMediaBaseURL())\(countriesArray[indexPath.row].flagImageURL ?? "")", labelText: countriesArray[indexPath.row].name)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LanguagesAndCountriesTableViewCell
        if isLanguageChoice {
            selectedLanguage = languagesArray[indexPath.row]
            if selectedLanguage == "English"{
                titleLabel.text = NSLocalizedString("CHOOSE LANGUAGE", comment: "")
                confirmButton.setTitle("Continue", for: .normal)
                changeInSettingsLabel.text = "You can change this in app settings later"
            }
            else{
                titleLabel.text = "إختر اللغه"
                confirmButton.setTitle("إستمرار", for: .normal)
                changeInSettingsLabel.text = "يمكنك تغيير اختياراتك من اعدادات التطبيق لاحقا"
            }
            cell.isSelectedImageView.isHidden = false
            confirmButton.isEnabled = true
            confirmButton.alpha = 1
        } else {
            selectedCountry = countriesArray[indexPath.row]
            cell.isSelectedImageView.isHidden = false
            confirmButton.isEnabled = true
            confirmButton.alpha = 1
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! LanguagesAndCountriesTableViewCell
        cell.isSelectedImageView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    //MARK: - View controller functions
    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        if isLanguageChoice {
            if selectedLanguage == "English" {
                APIConstants.URLs.locale = "en"
                MethodSwizzleGivenClassName(cls: UILabel.self, originalSelector: #selector(UILabel.layoutSubviews), overrideSelector: #selector(UILabel.cstmlayoutSubviews))
                CinemaGuideLangs.setAppleLAnguageTo(lang: "en")
            } else {
                APIConstants.URLs.locale = "ar"
                MethodSwizzleGivenClassName(cls: UILabel.self, originalSelector: #selector(UILabel.layoutSubviews), overrideSelector: #selector(UILabel.cstmlayoutSubviews))
                CinemaGuideLangs.setAppleLAnguageTo(lang: "ar")
               
                if #available(iOS 9.0, *) {
                    UIView.appearance().semanticContentAttribute = .forceRightToLeft
                } else {
                    // Fallback on earlier versions
                }
            }
            isLanguageChoice = false
            confirmButton.setTitle(NSLocalizedString("CONFIRM", comment: "confirm key"), for: .normal)
            
            getCountries()
            let transition: UIView.AnimationOptions = .transitionFlipFromLeft
            UIView.transition(with: tableView, duration: 0.5, options: transition, animations: nil, completion: nil)
            tableView.reloadData()
            titleLabel.text = NSLocalizedString("CHOOSE COUNTRY", comment: "choose country key")
            confirmButton.isEnabled = false
            confirmButton.alpha = 0.3
        } else {
            let user = NetmeraUser()
            user.country = selectedCountry.code
            Netmera.update(user)
            UserDefaults.standard.set(selectedCountry.code, forKey: "UserCountry")
            UserDefaults.standard.set(selectedCountry.currency, forKey: "Currency")
            UserDefaults.standard.synchronize()
            self.performSegue(withIdentifier: "NavigateToNavBar", sender: self)
        }
    }

}
