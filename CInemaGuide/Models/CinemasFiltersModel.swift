//
//  CinemasFiltersModel.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/17/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class CinemasFiltersModel: NSObject {

    var genres: [String]!
    var is3D: [Bool]!
    var priceRanges: [Int]!
    
    init(fromDictionary dictionary: [String:Any]) {
        genres = dictionary["genres"] as! [String]
        is3D = dictionary["is3D"] as! [Bool]
        priceRanges = dictionary["priceRanges"] as! [Int]
    }
    
    func toDictionary() -> [String:Any] {
        var dictionary = [String:Any]()
        if genres != nil {
            dictionary["genres"] = genres
        }
        if is3D != nil {
            dictionary["is3D"] = is3D
        }
        if priceRanges != nil {
            dictionary["priceRanges"] = priceRanges
        }
        return dictionary
    }
    
    //NSCoding required initializer, Fills the data from the passed decoder
    @objc required init(coder aDecoder: NSCoder) {
        genres = aDecoder.decodeObject(forKey: "genres") as! [String]
        is3D = aDecoder.decodeObject(forKey: "is3D") as! [Bool]
        priceRanges = aDecoder.decodeObject(forKey: "priceRanges") as! [Int]
    }
    
    //NSCoding required method, Encodes mode properties into the decoder
    @objc func encode(with aCoder: NSCoder) {
        if genres != nil {
            aCoder.encode(genres, forKey: "genres")
        }
        if is3D != nil {
            aCoder.encode(is3D, forKey: "is3D")
        }
        if priceRanges != nil {
            aCoder.encode(priceRanges, forKey: "priceRanges")
        }
    }
}
