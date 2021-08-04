//
//  HomeHeaderTableViewCell.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/8/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

@objc protocol HomeSelectedHeaderDelegate {
    func selectHeader(headerTitle: String)
}

class HomeHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    weak var delegate: HomeSelectedHeaderDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
    }
    
    func initCellWith(title:String) {
        self.titleLabel.text = title
    }
    
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        delegate?.selectHeader(headerTitle: self.titleLabel.text!)
    }
}
