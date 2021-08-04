//
//  PGsFilterView.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/17/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import AwesomeCache
import Instabug
@objc protocol PGsFilterDelegate {
    func pgOkPressed(selectedIndex: Int)
    func pgCancelPressed()
}

class PGsFilterView: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var pgsTableView: UITableView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: PGsFilterDelegate?
    var pgsArray = [[String: Any]]()
    var selectedPG = Int()
    let selectedPGCache = try! Cache<NSNumber>(name: "SelectedPG")
    let PGsCache = try! Cache<NSMutableArray>(name: "PGsArrayCache")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        pgsTableView.register(UINib(nibName: "DefaultFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultFilterCell")
        pgsTableView.isHidden = true
        if let pgs = PGsCache["PGsArrayCache"] {
            if pgs.count == 0 {
                getPGs()
            } else {
                pgsArray = pgs as! [[String: Any]]
                pgsTableView.isHidden = false
                pgsTableView.reloadData()
            }
        } else {
            getPGs()
        }
        
        if let theSelectedPG = selectedPGCache["SelectedPG"] {
            for aPG in pgsArray {
                let pgID = aPG["id"] as! Int
                if Int(theSelectedPG) == pgID {
                    selectedPG = pgID
                }
            }
        }
    }
    
    func getPGs() {
        APIManager.getMoviesFilter(success: { (movieFilterModel: MoviesFiltersModel) -> Void in
            var pgsArray = movieFilterModel.pgs
            pgsArray?.insert(["name": "All", "id": 0], at: 0) //pgsArray?.append(["name": "All", "id": 0])
            self.pgsArray = pgsArray! //movieFilterModel.pgs
            self.PGsCache["PGsArrayCache"] = NSMutableArray(array: self.pgsArray)
            self.pgsTableView.reloadData()
            self.pgsTableView.isHidden = false
        }) { (error: NSError?) -> Void in
            Instabug.ibgLog(error?.description ?? "")
            print(error?.description ?? "")
        }
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        delegate?.pgOkPressed(selectedIndex: selectedPG)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        delegate?.pgCancelPressed()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if pgsArray.count != 0 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pgsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pgCell = tableView.dequeueReusableCell(withIdentifier: "DefaultFilterCell", for: indexPath) as! DefaultFilterTableViewCell
        let pg = pgsArray[indexPath.row]
        pgCell.filterNameLabel.text = pg["name"] as? String
       //pgCell.filterNameLabel.textAlignment = NSTextAlignment.right

        //if selectedPG != 0 {
            if selectedPG == pg["id"] as! Int {
                pgCell.containerView.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
                pgCell.filterNameLabel.textColor = #colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1)
                pgCell.markImg.isHidden = false

            } else {
                pgCell.containerView.backgroundColor = UIColor.clear
                pgCell.filterNameLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
                pgCell.markImg.isHidden = true
            }
        //} else {
        //    pgCell.containerView.backgroundColor = UIColor.clear
        //    pgCell.filterNameLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
        //}
        return pgCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pg = pgsArray[indexPath.row]
        let languageCell = tableView.cellForRow(at: indexPath) as! DefaultFilterTableViewCell

        if pg["id"] as! Int == selectedPG {
            selectedPG = 0
            selectedPGCache["SelectedPG"] = selectedPG as NSNumber
            //tableView.reloadRows(at: [indexPath], with: .automatic)
            //V1
            //languageCell.containerView.backgroundColor = UIColor.clear
            //languageCell.filterNameLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
            //languageCell.markImg.isHidden = true
            //V2
            languageCell.containerView.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
            languageCell.filterNameLabel.textColor = #colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1)
            languageCell.markImg.isHidden = false
            tableView.reloadData()
        } else {
            selectedPG = pg["id"] as! Int
            selectedPGCache["SelectedPG"] = selectedPG as NSNumber
            languageCell.containerView.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
            languageCell.filterNameLabel.textColor = #colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1)
            languageCell.markImg.isHidden = false
            tableView.reloadData()
        }
    }
}
