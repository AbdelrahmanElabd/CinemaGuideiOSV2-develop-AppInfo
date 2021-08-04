//
//  LanguageFilterView.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/16/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import AwesomeCache
import Instabug
@objc protocol LanguageFilterDelegate {
    func okPressed(selectedIndex: Int, isAr: Bool)
    func cancelPressed()
}

class LanguageFilterView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var languagesTableView: UITableView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: LanguageFilterDelegate?
    var languagesArray = [[String: Any]]()
    var selectedLanguage = Int()
    let selectedLanguageCache = try! Cache<NSNumber>(name: "SelectedLanguage")
    let languagesCache = try! Cache<NSMutableArray>(name: "languagesArrayCache")
    var isAr = false
    var islanSelected = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        languagesTableView.register(UINib(nibName: "DefaultFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultFilterCell")
        languagesTableView.isHidden = true
        if let languages = languagesCache["languagesArrayCache"] {
            if languages.count == 0 {
                getLangs()
            } else {
                languagesArray = languages as! [[String: Any]]
                languagesTableView.isHidden = false
                languagesTableView.reloadData()
            }
        } else {
            getLangs()
        }
        
        if let selectedLang = selectedLanguageCache["SelectedLanguage"] {
            if languagesArray.count != 0 {
                for i in 0 ... languagesArray.count-1 {
                    let language = languagesArray[i]
                    let langID = language["id"] as! Int
                    if Int(selectedLang) == langID {
                        selectedLanguage = i
                        islanSelected = true
                    }
                }
            }
        }
    }
    
    func getLangs() {
        APIManager.getMoviesFilter(success: { (movieFilterModel: MoviesFiltersModel) -> Void in
            self.languagesArray = movieFilterModel.langs
            self.languagesCache["languagesArrayCache"] = NSMutableArray(array: self.languagesArray)
            self.languagesTableView.reloadData()
            self.languagesTableView.isHidden = false
        }) { (error: NSError?) -> Void in
            Instabug.ibgLog(error?.description ?? "")
            print(error?.description ?? "")
        }
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        delegate?.okPressed(selectedIndex: selectedLanguage, isAr: isAr)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        delegate?.cancelPressed()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if languagesArray.count != 0 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let languageCell = tableView.dequeueReusableCell(withIdentifier: "DefaultFilterCell", for: indexPath) as! DefaultFilterTableViewCell
        let language = languagesArray[indexPath.row]
        languageCell.filterNameLabel.text = language["name"] as? String
        let langCache = selectedLanguageCache["SelectedLanguage"] ?? 0
        if langCache != 0 {
            let lang = languagesArray[selectedLanguage]
            let langID = lang["id"] as! Int
            let currentLang = languagesArray[indexPath.row]
            let currentLangID = currentLang["id"] as! Int
          //  languageCell.filterNameLabel.textAlignment = NSTextAlignment.left

            if langID == currentLangID {
                languageCell.containerView.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
                languageCell.filterNameLabel.textColor = #colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1)
                languageCell.markImg.isHidden = false
            } else {
                languageCell.containerView.backgroundColor = UIColor.clear
                languageCell.filterNameLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
                languageCell.markImg.isHidden = true

            }
        } else {
            languageCell.containerView.backgroundColor = UIColor.clear
            languageCell.filterNameLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
        }
        return languageCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let language = languagesArray[indexPath.row]
        let theLang = languagesArray[selectedLanguage]
        let id = theLang["id"] as! Int
        let languageCell = tableView.cellForRow(at: indexPath) as! DefaultFilterTableViewCell
        if language["id"] as! Int == id && islanSelected {
            selectedLanguage = 0
            islanSelected = false
//            selectedLanguageCache["SelectedLanguage"] = selectedLanguage as NSNumber
//            languagesTableView.reloadRows(at: [indexPath], with: .automatic)
            languageCell.containerView.backgroundColor = UIColor.clear
            languageCell.filterNameLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
            languageCell.markImg.isHidden = true

        } else {
            selectedLanguage = indexPath.row
            let theLang = languagesArray[selectedLanguage]
            var id = theLang["id"] as! Int
            if id == 1 {
                isAr = true
            }
            islanSelected=true
            languageCell.containerView.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
            languageCell.filterNameLabel.textColor = #colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1)
            languageCell.markImg.isHidden = false
            selectedLanguageCache["SelectedLanguage"] = id as NSNumber
            languagesTableView.reloadData()
        }
    }
}
