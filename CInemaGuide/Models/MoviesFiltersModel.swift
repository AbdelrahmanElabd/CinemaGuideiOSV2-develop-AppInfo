//
//  MoviesFiltersModel.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 7/17/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit

class MoviesFiltersModel: NSObject {
    
    var genres: [[String: Any]]!
    var langs: [[String: Any]]!
    var pgs: [[String: Any]]!
    var priceRanges: [Int]!
    
    init(fromDictionary dictionary: [String:Any]) {
        genres = dictionary["genres"] as! [[String : Any]]
        langs = dictionary["langs"] as! [[String : Any]]
        pgs = dictionary["pgs"] as! [[String : Any]]
        priceRanges = dictionary["priceRanges"] as! [Int]
    }
    
    func toDictionary() -> [String:Any] {
        var dictionary = [String:Any]()
        if genres != nil {
            dictionary["genres"] = genres
        }
        if langs != nil {
            dictionary["langs"] = langs
        }
        if pgs != nil {
            dictionary["pgs"] = pgs
        }
        if priceRanges != nil {
            dictionary["priceRanges"] = priceRanges
        }
        return dictionary
    }
    
    //NSCoding required initializer, Fills the data from the passed decoder
    @objc required init(coder aDecoder: NSCoder) {
        genres = aDecoder.decodeObject(forKey: "genres") as! [[String : Any]]
        langs = aDecoder.decodeObject(forKey: "langs") as! [[String : Any]]
        pgs = aDecoder.decodeObject(forKey: "pgs") as! [[String : Any]]
        priceRanges = aDecoder.decodeObject(forKey: "priceRanges") as! [Int]
    }
    
    //NSCoding required method, Encodes mode properties into the decoder
    @objc func encode(with aCoder: NSCoder) {
        if genres != nil {
            aCoder.encode(genres, forKey: "genres")
        }
        if langs != nil {
            aCoder.encode(langs, forKey: "langs")
        }
        if pgs != nil {
            aCoder.encode(pgs, forKey: "pgs")
        }
        if priceRanges != nil {
            aCoder.encode(priceRanges, forKey: "priceRanges")
        }
    }
}
