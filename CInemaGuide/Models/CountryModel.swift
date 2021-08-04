//
//  CountryModel.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 1/8/18.
//  Copyright © 2018 HeshamHaleem. All rights reserved.
//

import UIKit

class CountryModel: NSObject {

    var id: Int!
    var name: String!
    var code: String!
    var flagImageURL: String!
    var currency: String!
    init(fromDictionary dictionary: [String:Any]) {
        id = dictionary["id"] as? Int ?? 0
        name = dictionary["name"] as? String ?? ""
        code = dictionary["code"] as? String ?? ""
        flagImageURL = dictionary["flag"] as? String ?? ""
        currency = dictionary["currency"] as? String ?? ""
    }
    
    func toDictionary() -> [String:Any] {
        var dictionary = [String:Any]()
        if id != nil {
            dictionary["id"] = id
        }
        if name != nil {
            dictionary["name"] = name
        }
        if code != nil {
            dictionary["code"] = code
        }
        if flagImageURL != nil {
            dictionary["flag"] = flagImageURL
        }
        if currency != nil {
            dictionary["currency"] = currency
        }
        return dictionary
    }
    
    //NSCoding required initializer, Fills the data from the passed decoder
    @objc required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? Int ?? 0
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        code = aDecoder.decodeObject(forKey: "code") as? String ?? ""
        flagImageURL = aDecoder.decodeObject(forKey: "flag") as? String ?? ""
        currency = aDecoder.decodeObject(forKey: "currency") as? String ?? ""

    }
    
    //NSCoding required method, Encodes mode properties into the decoder
    @objc func encode(with aCoder: NSCoder) {
        if id != nil {
            aCoder.encode(id, forKey: "id")
        }
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        if currency != nil {
            aCoder.encode(currency, forKey: "currency")
        }
        if code != nil {
            aCoder.encode(code, forKey: "code")
        }
        if flagImageURL != nil {
            aCoder.encode(flagImageURL, forKey: "flag")
        }
    }
}
