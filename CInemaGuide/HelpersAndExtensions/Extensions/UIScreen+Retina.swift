//
//  UIScreen+Retina.swift
//  ContactCars
//
//  Created by Sarmady on 6/2/19.
//  Copyright © 2019 Sarmady. All rights reserved.
//

import UIKit

extension UIScreen {
    
    public var isRetina: Bool {
        guard let scale = screenScale else {
            return false
        }
        return scale >= 2.0
    }
    
    public var isRetinaHD: Bool {
        guard let scale = screenScale else {
            return false
        }
        return scale >= 2.0
    }
    
    private var screenScale: CGFloat? {
        guard UIScreen.main.responds(to: #selector(getter: scale)) else {
            return nil
        }
        return UIScreen.main.scale
    }
}
