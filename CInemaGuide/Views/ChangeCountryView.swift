//
//  ChangeCountryView.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 1/9/18.
//  Copyright © 2018 HeshamHaleem. All rights reserved.
//

import UIKit
//import Instabug
@objc protocol ChangeUserCountryDelegate {
    func changeCountryOkPressed(selectedCountry: String)
    func changeCountryCancelPressed()
}

class ChangeCountryView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var countriesTableView: UITableView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: ChangeUserCountryDelegate?
    var countriesArray = [CountryModel]()
    var selectedCountry = String()
    var currency = String()
    var activityView = UIActivityIndicatorView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        okButton.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        countriesTableView.register(UINib(nibName: "DefaultFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultFilterCell")
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.center = CGPoint(x: UIScreen.main.bounds.width / 2 - 10, y: 50)
        activityView.startAnimating()
        self.countriesTableView.addSubview(activityView)
        
        getCountries()
        okButton.titleLabel?.text = "okokoko"
        if let aCountry = UserDefaults.standard.object(forKey: "UserCountry") {
            selectedCountry = aCountry as! String
        }
    }
    
    func getCountries() {
        APIManager.getCountries(success: { (responseObject) in
            self.countriesArray = responseObject
            self.countriesTableView.reloadData()
            self.activityView.stopAnimating()
        }) { (error: NSError?) -> Void in
//            Instabug.ibgLog(error?.description ?? "")
            self.getCountries()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if countriesArray.count == 0 {
            return 0
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let countryCell = tableView.dequeueReusableCell(withIdentifier: "DefaultFilterCell", for: indexPath) as! DefaultFilterTableViewCell
        countryCell.filterNameLabel.text = countriesArray[indexPath.row].name
        if selectedCountry == countriesArray[indexPath.row].code {
            countryCell.containerView.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
            countryCell.filterNameLabel.textColor = #colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1)
        } else {
            countryCell.containerView.backgroundColor = UIColor.clear
            countryCell.filterNameLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
        }
        countryCell.filterNameLabel.textAlignment = .center
        countryCell.markWidthConstraint.constant = 0
        return countryCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCountry = countriesArray[indexPath.row].code
        currency=countriesArray[indexPath.row].currency
        tableView.reloadData()
    }
    
    @IBAction func okButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(currency, forKey: "Currency")
        UserDefaults.standard.synchronize()
        let user = NetmeraUser()
        user.country = selectedCountry
        Netmera.update(user)

        delegate?.changeCountryOkPressed(selectedCountry: selectedCountry)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        delegate?.changeCountryCancelPressed()
    }
}
