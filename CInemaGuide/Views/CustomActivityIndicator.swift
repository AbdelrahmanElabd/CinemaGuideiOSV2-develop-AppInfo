//
//  CustomActivityIndicator.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 8/28/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class CustomActivityIndicator: UIView {
    
    @IBOutlet weak var activityIndicatorCinemaImage: UIImageView!
    @IBOutlet weak var activityIndicatorRedDotIcon: UIImageView!
    @IBOutlet weak var redDotIconHorizontalSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var redDotIconVerticalSpaceConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startActivityIndicator()
        
        if #available(iOS 9.0, *) {
            self.semanticContentAttribute = .forceLeftToRight
            activityIndicatorCinemaImage.semanticContentAttribute = .forceLeftToRight
            activityIndicatorRedDotIcon.semanticContentAttribute = .forceLeftToRight
        } else {
            // Fallback on earlier versions
        }
    }
    
    func startActivityIndicator() {
        rotateImage()
    }
    
    func stopActivityIndicator() {
        activityIndicatorCinemaImage.isHidden = true
        activityIndicatorRedDotIcon.isHidden = true
        self.activityIndicatorCinemaImage.layer.removeAllAnimations()
        self.removeFromSuperview()
    }
    
    private func rotateImage(duration: Double = 0.5) {
        activityIndicatorCinemaImage.isHidden = false
        activityIndicatorRedDotIcon.isHidden = false
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 7200.0
        rotationAnimation.toValue = 0.0
        rotationAnimation.duration = 49.4
        self.activityIndicatorCinemaImage.layer.add(rotationAnimation, forKey: nil)
    }
}
