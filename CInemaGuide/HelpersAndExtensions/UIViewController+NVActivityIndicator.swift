//
//  UIViewController+NVActivityIndicator.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/5/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import Foundation
import NVActivityIndicatorView

public var activityIndicator = NVActivityIndicatorView.init(frame: CGRect.zero)

public extension UIViewController {
    public var activityIndicatorType: Int {
        return 16
    }

    public func initActivityIndicatorWith(frame: CGRect) {
        activityIndicator = NVActivityIndicatorView(frame: frame, type: .orbit)//NVActivityIndicatorType(rawValue: activityIndicatorType)!
        activityIndicator.color = #colorLiteral(red: 0.9239932299, green: 0.368311584, blue: 0.3515627384, alpha: 1)
        self.view.addSubview(activityIndicator)
    }
    
    public func startActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    public func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
}
