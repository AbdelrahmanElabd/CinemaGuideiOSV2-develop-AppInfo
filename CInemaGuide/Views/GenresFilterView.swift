//
//  GenresFilterView.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/15/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import AwesomeCache
//import Instabug
@objc protocol GenresFilterDelegate {
    func okPressed(genresIDs: [Int])
    func cancelPressed(buttonType: String)
}

class GenresFilterView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var genresTableView: UITableView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    weak var delegate: GenresFilterDelegate?
    var genresArray = [[String: Any]]()
    var genreTypies = [TypeModel]()
    var selectedGenresArray = NSMutableArray()
    var selectedStaticGenresArrayVirtual = false
    var selectedStaticGenresArrayRealcount = 0
    var isSelectedCell = Bool()
    let selectedGenresCache = try! Cache<NSMutableArray>(name: "SelectedGenres")
    let genresCache = try! Cache<NSMutableArray>(name: "GenresArrayCache")
    static var isold = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        genresTableView.register(UINib(nibName: "GenresFilterTableViewCell", bundle: nil), forCellReuseIdentifier: "GenresCell")
        if let array = selectedGenresCache["SelectedGenres"] {
            cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel Key"), for: .normal)
            if array.count != 0 {
                 selectedGenresArray = array
            }
//            else {
//
////                cancelButton.setTitle(NSLocalizedString("Clear", comment: "Clear Key"), for: .normal)
//            }
        }
//        else {
//            cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel Key"), for: .normal)
//        }
        if let genres = genresCache["GenresArrayCache"] {
            if genres.count == 0 {
                getGenres()
            } else {
                self.genreTypies = [TypeModel]()
                for item in genres{
                    if let arrayItem = item as? NSDictionary{
                        self.genreTypies.append(TypeModel(id: arrayItem["id"] as? Int, check: false, text: arrayItem["name"] as? String))
                    }
                    }
                genresTableView.isHidden = false
                genresTableView.reloadData()
            }
        } else {
            getGenres()
        }
    }
    func getGenres() {
        self.genreTypies = [TypeModel]()
        APIManager.getMoviesFilter(success: {[weak self] (movieFilterModel: MoviesFiltersModel) -> Void in
            if let self = self{
            self.genresArray = movieFilterModel.genres
                for item in self.genresArray{
                    self.genreTypies.append(TypeModel(id: item["id"] as? Int, check: false, text: item["name"] as? String))
            }
            self.genresCache["GenresArrayCache"] = NSMutableArray(array: self.genresArray)
            self.genresTableView.reloadData()
            self.genresTableView.isHidden = false
            }
            }) { (error: NSError?) -> Void in
//            Instabug.ibgLog(error?.description ?? "")
            print(error?.description ?? "")
        }
    }
  
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        delegate?.cancelPressed(buttonType: "Cancel")
        
//        if cancelButton.titleLabel?.text == NSLocalizedString("Cancel", comment: "Cancel Key") {
//            delegate?.cancelPressed(buttonType: "Cancel")
//        } else {
//            GenresFilterView.isold = true
//            selectedStaticGenresArrayVirtual = true
//            self.selectedGenresArray = NSMutableArray()
//
//            isSelectedCell = false
//            if let genres = genresCache["GenresArrayCache"] {
//                if genres.count == 0 {
//                    getGenres()
//                } else {
//                    self.genreTypies = [TypeModel]()
//                    for item in genres{
//                        if let arrayItem = item as? NSDictionary{
//                            self.genreTypies.append(TypeModel(id: arrayItem["id"] as? Int, check: false, text: arrayItem["name"] as? String))
//                        }
//                        }
//                    genresTableView.isHidden = false
//                    genresTableView.reloadData()
//                }
//            }
//            self.genresTableView.reloadData()
//            cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel Key"), for: .normal)
//        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if genreTypies.count != 0 {
            return 1
        }
        return 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genreTypies.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let genresCell = tableView.dequeueReusableCell(withIdentifier: "GenresCell", for: indexPath) as! GenresFilterTableViewCell
        genresCell.type = genreTypies[indexPath.row]
        genresCell.genreCheckBox.isUserInteractionEnabled = false
        genresCell.genreLabel.text = genreTypies[indexPath.row].text ?? ""
        
        if genresCell.type.check{
            genresCell.genreCheckBox.checkState = .checked
        }
        else{
            genresCell.genreCheckBox.checkState = .unchecked
        }
        if !selectedStaticGenresArrayVirtual{
        for genre in selectedGenresArray {
            let genreID = genre as! Int
            
            if genreID == genresCell.type.id {
                genresCell.genreCheckBox.checkState = .checked
            }
        }

        }
        return genresCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    @IBAction func okButtonPressed(_ sender: UIButton) {
        selectedGenresCache["SelectedGenres"] = selectedGenresArray
        if selectedStaticGenresArrayVirtual{
            selectedGenresArray = NSMutableArray()
            selectedGenresCache["SelectedGenres"] = NSMutableArray()
        }
        delegate?.okPressed(genresIDs: selectedGenresArray as! [Int])
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let genresCell = tableView.cellForRow(at: indexPath) as! GenresFilterTableViewCell
        let genre = genreTypies[indexPath.row]
        
        if genresCell.genreCheckBox.checkState == .checked {
            genreTypies[indexPath.row].check = false
            genresCell.type.check = false
            genresCell.genreCheckBox.checkState = .unchecked
            if let genreID = genre.id{
            selectedGenresArray.remove(genreID)
            }
            if (selectedGenresArray.count == 0){
                cancelButton.setTitle(NSLocalizedString("Cancel", comment: "Cancel Key"), for: .normal)
            }
        } else {
            if selectedGenresArray.count == 0 && !selectedStaticGenresArrayVirtual {
                selectedGenresCache["SelectedGenres"] = NSMutableArray()
            }
            selectedStaticGenresArrayVirtual = false
            let genreID = genre.id
            selectedGenresArray.add(genreID)
            if GenresFilterView.isold{
                selectedGenresArray = NSMutableArray()
                selectedGenresArray.add(genreID)
                GenresFilterView.isold = false
            }
//            cancelButton.setTitle(NSLocalizedString("Clear", comment: "Clear Key"), for: .normal)
            genreTypies[indexPath.row].check = true
            genresCell.type.check = true
            genresCell.genreCheckBox.checkState = .checked
        }
    }
}
