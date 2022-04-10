//
//  CinemaFilterPriceRangesView.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/17/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import AwesomeCache
//import Instabug
@objc protocol PriceRangesFilterDelegate {
    func priceRangesOkPressed(selectedRange: Int)
    func priceRangesCancelPressed()
}

class CinemaFilterPriceRangesView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var priceRangesTableView: UITableView!
    
    weak var delegate: PriceRangesFilterDelegate?
    var priceRangesArray = [Int]()
    var selectedPriceRange = Int()
    let selectedPriceRangeCache = try! Cache<NSNumber>(name: "SelectedPriceRange")
    let priceRangesCache = try! Cache<NSMutableArray>(name: "PriceRangesArrayCache")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        priceRangesTableView.register(UINib(nibName: "DefaultFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "DefaultFilterCell")
        priceRangesTableView.isHidden = true
        
        if let ranges = priceRangesCache["PriceRangesArrayCache"] {
            if ranges.count == 0 {
                getPriceRanges()
            } else {
                priceRangesArray = ranges as! [Int]
                priceRangesTableView.isHidden = false
                priceRangesTableView.reloadData()
            }
        } else {
            getPriceRanges()
        }
        
        if let theSelectedRange = selectedPriceRangeCache["SelectedPriceRange"] {
            for aRange in priceRangesArray {
                if Int(theSelectedRange) == aRange {
                    selectedPriceRange = aRange
                }
            }
        }
    }
    
    func getPriceRanges() {
        APIManager.getMoviesFilter(success: { (movieFilterModel: MoviesFiltersModel) -> Void in
            self.priceRangesArray = movieFilterModel.priceRanges
            self.priceRangesCache["PriceRangesArrayCache"] = NSMutableArray(array: self.priceRangesArray)
            self.priceRangesTableView.reloadData()
            self.priceRangesTableView.isHidden = false
        }) { (error: NSError?) -> Void in
//            Instabug.ibgLog(error?.description ?? "")
            print(error?.description ?? "")
        }
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        delegate?.priceRangesOkPressed(selectedRange: selectedPriceRange)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        delegate?.priceRangesCancelPressed()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if priceRangesArray.count != 0 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return priceRangesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let priceRangeCell = tableView.dequeueReusableCell(withIdentifier: "DefaultFilterCell", for: indexPath) as! DefaultFilterTableViewCell
        print(priceRangesArray[indexPath.row])
        let price = priceRangesArray[indexPath.row]
        let defaultValue = NSLocalizedString("le", comment: "defaultCurrency");
        let currencey:String = (UserDefaults.standard.object(forKey: "Currency") ?? defaultValue.uppercased()) as! String
        print(currencey)
       // headerCell.cellLabel.text = "\(localizeNum(price)!) \(currencey)"
        priceRangeCell.filterNameLabel.text = "\(localizeNum(price) ?? "0")" + " " + NSLocalizedString(currencey, comment: "")
        priceRangeCell.filterNameLabel.textAlignment = .center
        //priceRangeCell.filterNameLabel.textAlignment = NSTextAlignment.right

        
        //if selectedPriceRange != 0 {
            if selectedPriceRange == priceRangesArray[indexPath.row] {
                priceRangeCell.containerView.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
                priceRangeCell.filterNameLabel.textColor = #colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1)
                priceRangeCell.markImg.isHidden = false
            } else {
                priceRangeCell.containerView.backgroundColor = UIColor.clear
                priceRangeCell.filterNameLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
                priceRangeCell.markImg.isHidden = true
            }
        //} else {
        //    priceRangeCell.containerView.backgroundColor = UIColor.clear
        //    priceRangeCell.filterNameLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
        //}
        return priceRangeCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! DefaultFilterTableViewCell
        if priceRangesArray[indexPath.row] == selectedPriceRange {
            selectedPriceRange = 0
            selectedPriceRangeCache["SelectedPriceRange"] = selectedPriceRange as NSNumber
           // tableView.reloadRows(at: [indexPath], with: .automatic)
            cell.containerView.backgroundColor = UIColor.clear
            cell.filterNameLabel.textColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
            cell.markImg.isHidden = true
        } else {
            selectedPriceRange = priceRangesArray[indexPath.row]
            selectedPriceRangeCache["SelectedPriceRange"] = selectedPriceRange as NSNumber
            cell.containerView.backgroundColor = #colorLiteral(red: 0.1176470588, green: 0.1843137255, blue: 0.2235294118, alpha: 1)
            cell.filterNameLabel.textColor = #colorLiteral(red: 1, green: 0.7725490196, blue: 0, alpha: 1)
            cell.markImg.isHidden = false
            tableView.reloadData()
        }
    }
}
