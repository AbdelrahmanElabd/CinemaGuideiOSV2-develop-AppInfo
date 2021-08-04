//
//  GenresFilterTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/15/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import M13Checkbox

class GenresFilterTableViewCell: UITableViewCell {

    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var genreCheckBox: M13Checkbox!
    var type : TypeModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        genreCheckBox.boxType = .square
        genreCheckBox.animationDuration = 0.5
        genreCheckBox.stateChangeAnimation = .fill
        genreCheckBox.tintColor = #colorLiteral(red: 0.1166469529, green: 0.1833347976, blue: 0.2228097022, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initcellWith(currentCell: GenresFilterTableViewCell, isSelected: Bool) {
       
        if currentCell.type.check {
            currentCell.genreCheckBox.checkState = .unchecked
        } else {
            currentCell.genreCheckBox.checkState = .checked
        }
//        currentCell.type.check = !currentCell.type.check
    }
}
