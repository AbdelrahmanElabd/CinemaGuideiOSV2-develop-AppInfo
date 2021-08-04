//
//  MoviesDetailsInfoTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/4/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class MoviesDetailsInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var directorsNamesLabel: UILabel!
    @IBOutlet weak var castLabel: UILabel!
    @IBOutlet weak var castNamesLabel: UILabel!
    @IBOutlet weak var storyLineLabel: UILabel!
    @IBOutlet weak var storyLineStringLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCellWith(movieDetails: MovieModel) {
        directorLabel.textAlignment = .center
        directorsNamesLabel.textAlignment = .center
        castLabel.textAlignment = .center
        castNamesLabel.textAlignment = .center
        storyLineLabel.textAlignment = .center
        storyLineStringLabel.textAlignment = .center
        if movieDetails.director != "" {
            directorsNamesLabel.text = movieDetails.director
        } else {
            directorLabel.isHidden = true
            directorsNamesLabel.isHidden = true
        }
        if movieDetails.actors.count != 0 {
            var actorsNames = ""
            for actorData in movieDetails.actors {
                if actorsNames == "" {
                    let actorName = actorData["name"] ?? ""
                    actorsNames = actorName as! String
                } else {
                    actorsNames = actorsNames + ", \(actorData["name"] ?? "")"
                }
            }
            castNamesLabel.text = actorsNames
        } else {
            castLabel.isHidden = true
            castNamesLabel.isHidden = true
        }
        if movieDetails.synopsis != "" {
            storyLineStringLabel.text = movieDetails.synopsis
        } else {
            storyLineLabel.isHidden = true
            storyLineStringLabel.isHidden = true
        }
    }
}
