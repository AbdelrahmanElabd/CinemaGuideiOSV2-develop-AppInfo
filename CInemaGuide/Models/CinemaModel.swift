//
//  CinemaModel.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/5/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import Foundation

class CinemaModel: NSObject, NSCoding {
    
    var id : Int!
    var latitude : String!
    var longitude : String!
    var address : String!
    var name : String!
    var imageUrl : [String : Any]!
    var movies : [MovieModel]!
    var phoneNumbers : [String]!
    var is3D : Bool!
    var showTimes : [[String : Any]]!
    var area : String!
    var moviesCount : Int!
    var priceOne : Int!
    var PriceTwo : Int!
    var distance : Double!
    
    init(fromDictionary dictionary: [String:Any]) {
        id = dictionary["id"] as? Int ?? 0
        latitude = dictionary["latitude"] as? String ?? ""
        longitude = dictionary["longitude"] as? String ?? ""
        address = dictionary["address"] as? String ?? ""
        name = dictionary["name"] as? String ?? ""
        imageUrl = dictionary["imageUrl"] as? [String : Any] ?? ["" : ""]
        movies = [MovieModel]()
        if let moviesArray = dictionary["movies"] as? [[String:Any]] {
            for dic in moviesArray {
                let value = MovieModel(fromDictionary: dic)
                movies.append(value)
            }
        }
        phoneNumbers = dictionary["phoneNumbers"] as? [String] ?? ["0"]
        is3D = dictionary["is3D"] as? Bool ?? false
        showTimes = dictionary["showTimes"] as? [[String : Any]] ?? [["" : ""]]
        area = dictionary["area"] as? String ?? ""
        moviesCount = dictionary["moviesCount"] as? Int ?? 0
        priceOne = dictionary["priceOne"] as? Int ?? 0
        PriceTwo = dictionary["priceTwo"] as? Int ?? 0
        distance = dictionary["distance"] as? Double ?? 0.0
    }
    
    func toDictionary() -> NSMutableDictionary {
        let dictionary = NSMutableDictionary()
        if id != nil{
            dictionary["id"] = id
        }
        if latitude != nil{
            dictionary["latitude"] = latitude
        }
        if longitude != nil{
            dictionary["longitude"] = longitude
        }
        if address != nil{
            dictionary["address"] = address
        }
        if name != nil{
            dictionary["name"] = name
        }
        if imageUrl != nil{
            dictionary["imageUrl"] = imageUrl
        }
        if movies != nil{
            var dictionaryElements = [[String:Any]]()
            for moviesElement in movies {
                dictionaryElements.append(moviesElement.toDictionary())
            }
            dictionary["movies"] = dictionaryElements
        }
        if phoneNumbers != nil {
            dictionary["phoneNumbers"] = phoneNumbers
        }
        if is3D != nil {
            dictionary["is3D"] = is3D
        }
        if showTimes != nil {
            dictionary["showTimes"] = showTimes
        }
        if area != nil {
            dictionary["area"] = area
        }
        if moviesCount != nil {
            dictionary["moviesCount"] = moviesCount
        }
        if priceOne != nil {
            dictionary["priceOne"] = priceOne
        }
        if PriceTwo != nil {
            dictionary["priceTwo"] = PriceTwo
        }
        if distance != nil {
            dictionary["distance"] = distance
        }
        return dictionary
    }
    
//    NSCoding required initializer, Fills the data from the passed decoder
    @objc required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? Int
        latitude = aDecoder.decodeObject(forKey: "latitude") as? String
        longitude = aDecoder.decodeObject(forKey: "longitude") as? String
        address = aDecoder.decodeObject(forKey: "address") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        imageUrl = aDecoder.decodeObject(forKey: "imageUrl") as? [String : Any]
        movies = aDecoder.decodeObject(forKey :"movies") as? [MovieModel]
        phoneNumbers = aDecoder.decodeObject(forKey: "phoneNumbers") as? [String]
        is3D = aDecoder.decodeObject(forKey: "is3D") as? Bool
        showTimes = aDecoder.decodeObject(forKey: "showTimes") as? [[String : Any]]
        area = aDecoder.decodeObject(forKey: "area") as? String
        moviesCount = aDecoder.decodeObject(forKey: "moviesCount") as? Int
        priceOne = aDecoder.decodeObject(forKey: "priceOne") as? Int
        PriceTwo = aDecoder.decodeObject(forKey: "priceTwo") as? Int
        distance = aDecoder.decodeObject(forKey: "distance") as? Double
    }
    
//    NSCoding required method, Encodes mode properties into the decoder
    @objc func encode(with aCoder: NSCoder) {
        if id != nil {
            aCoder.encode(id, forKey: "id")
        }
        if latitude != nil {
            aCoder.encode(latitude, forKey: "latitude")
        }
        if longitude != nil {
            aCoder.encode(longitude, forKey: "longitude")
        }
        if address != nil {
            aCoder.encode(address, forKey: "address")
        }
        if name != nil {
            aCoder.encode(name, forKey: "name")
        }
        if imageUrl != nil {
            aCoder.encode(imageUrl, forKey: "imageUrl")
        }
        if movies != nil {
            aCoder.encode(movies, forKey: "movies")
        }
        if phoneNumbers != nil {
            aCoder.encode(phoneNumbers, forKey: "phoneNumbers")
        }
        if is3D != nil {
            aCoder.encode(is3D, forKey: "is3D")
        }
        if showTimes != nil {
            aCoder.encode(showTimes, forKey: "showTimes")
        }
        if area != nil {
            aCoder.encode(area, forKey: "area")
        }
        if moviesCount != nil {
            aCoder.encode(moviesCount, forKey: "moviesCount")
        }
        if priceOne != nil {
            aCoder.encode(priceOne, forKey: "priceOne")
        }
        if PriceTwo != nil {
            aCoder.encode(PriceTwo, forKey: "priceTwo")
        }
        if distance != nil {
            aCoder.encode(distance, forKey: "distance")
        }
    }
}
