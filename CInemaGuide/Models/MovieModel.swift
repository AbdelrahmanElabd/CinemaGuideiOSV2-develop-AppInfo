//
//  CinemaMovieModel.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/5/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import Foundation

class MovieModel: NSObject, NSCoding {
    
    var id : Int!
    var poster : [String : Any]!
    var title : String!
    var rating : Int!
    var actors : [[String : Any]]!
    var trailers :[[String : Any]]!
    var director : String!
    var cinemas : [CinemaModel]!
    var language : String!
    var subtitle : String!
    var movieGallery : [[String : Any]]!
    var genres : [Any]!
    var synopsis : String!
    var is3d : Bool!
    var imdbRate : Double!
    var rottenTomatoRate : Int!
    var duration : Int!
    var isRated : Bool!
    var releaseDate : String!
    var isReviewed : Bool!
    var parentalGuidance : String!
    var numberOfCinemas : Int!
    var socialMediaLinks : [[String: Any]]!
    var websiteURL: String!
    var showtimes: [[String: Any]]!
    
    init(fromDictionary dictionary: [String:Any]) {
        id = dictionary["id"] as? Int ?? 0
        poster = dictionary["poster"] as? [String : Any] ?? ["" : ""]
        title = dictionary["title"] as? String ?? ""
        rating = dictionary["rate"] as? Int ?? 0
        actors = dictionary["actors"] as? [[String : Any]] ?? [["" : ""]]
        trailers = dictionary["trailers"] as? [[String : Any]] ?? [["" : ""]]
        director = dictionary["director"] as? String ?? ""
        cinemas = [CinemaModel]()
        if let cinemasArray = dictionary["cinemas"] as? [[String:Any]] {
            for dic in cinemasArray {
                let value = CinemaModel(fromDictionary: dic)
                cinemas.append(value)
            }
        }
        language = dictionary["languages"] as? String ?? ""
        subtitle = dictionary["subtitles"] as? String ?? ""
        movieGallery = dictionary["gallery"] as? [[String : Any]] ?? [["" : ""]]
        genres = dictionary["genre"] as? [[String : Any]] ?? [["" : ""]]
        synopsis = dictionary["synopsis"] as? String ?? ""
        is3d = dictionary["is3D"] as? Bool ?? false //["is_3d"]
        imdbRate = dictionary["imdb"] as? Double ?? 0.0
        rottenTomatoRate = dictionary["rotten"] as? Int ?? 0
        duration = dictionary["duration"] as? Int ?? 0
        isRated = dictionary["isRated"] as? Bool ?? false
        releaseDate = dictionary["releasedDate"] as? String ?? ""
        isReviewed = dictionary["isReviewed"] as? Bool ?? false
        parentalGuidance = dictionary["pg"] as? String ?? ""
        numberOfCinemas = dictionary["numOfCinemas"] as? Int ?? 0
        socialMediaLinks = dictionary["socialLinks"] as? [[String: Any]] ?? [["" : ""]]
        websiteURL = dictionary["website"] as? String ?? ""
        showtimes = dictionary["showTimes"] as? [[String: Any]] ?? [["" : ""]]
    }
    
    func toDictionary() -> [String:Any] {
        var dictionary = [String:Any]()
        if id != nil {
            dictionary["id"] = id
        }
        if poster != nil {
            dictionary["poster"] = poster
        }
        if title != nil {
            dictionary["title"] = title
        }
        if rating != nil {
            dictionary["rate"] = rating
        }
        if actors != nil {
            dictionary["actors"] = actors
        }
        if trailers != nil {
            dictionary["trailers"] = trailers
        }
        if director != nil {
            dictionary["director"] = director
        }
        if cinemas != nil {
            var dictionaryElements = [[String:Any]]()
            for moviesElement in cinemas {
                dictionaryElements.append(moviesElement.toDictionary() as! [String : Any])
            }
            dictionary["cinemas"] = dictionaryElements
        }
        if language != nil {
            dictionary["languages"] = language
        }
        if subtitle != nil {
            dictionary["subtitles"] = subtitle
        }
        if movieGallery != nil {
            dictionary["gallery"] = movieGallery
        }
        if genres != nil {
            dictionary["genre"] = genres
        }
        if synopsis != nil {
            dictionary["synopsis"] = synopsis
        }
        if is3d != nil {
            dictionary["is_3d"] = is3d
        }
        if imdbRate != nil {
            dictionary["imdb"] = imdbRate
        }
        if rottenTomatoRate != nil {
            dictionary["rotten"] = rottenTomatoRate
        }
        if duration != nil {
            dictionary["duration"] = duration
        }
        if isRated != nil {
            dictionary["isRated"] = isRated
        }
        if releaseDate != nil {
            dictionary["releasedDate"] = releaseDate
        }
        if isReviewed != nil {
            dictionary["isReviewed"] = isReviewed
        }
        if parentalGuidance != nil {
            dictionary["pg"] = parentalGuidance
        }
        if numberOfCinemas != nil {
            dictionary["numOfCinemas"] = numberOfCinemas
        }
        if socialMediaLinks != nil {
            dictionary["socialLinks"] = numberOfCinemas
        }
        if websiteURL != nil {
            dictionary["website"] = websiteURL
        }
        if showtimes != nil {
            dictionary["showTimes"] = showtimes
        }
        return dictionary
    }
    
//    NSCoding required initializer, Fills the data from the passed decoder
    @objc required init(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as? Int ?? 0
        poster = aDecoder.decodeObject(forKey: "poster") as? [String : Any] ?? ["" : ""]
        title = aDecoder.decodeObject(forKey: "title") as? String ?? ""
        rating = aDecoder.decodeObject(forKey:"rate") as? Int ?? 0
        actors = aDecoder.decodeObject(forKey:"actors") as? [[String : Any]] ?? [["" : ""]]
        trailers = aDecoder.decodeObject(forKey:"trailers") as? [[String : Any]] ?? [["" : ""]]
        director = aDecoder.decodeObject(forKey:"director") as? String ?? ""
        cinemas = aDecoder.decodeObject(forKey: "cinemas") as? [CinemaModel]
        language = aDecoder.decodeObject(forKey:"languages") as? String ?? ""
        subtitle = aDecoder.decodeObject(forKey:"subtitles") as? String ?? ""
        movieGallery = aDecoder.decodeObject(forKey:"gallery") as? [[String : Any]] ?? [["" : ""]]
        genres = aDecoder.decodeObject(forKey:"genre") as? [[String : Any]] ?? [["" : ""]]
        synopsis = aDecoder.decodeObject(forKey:"synopsis") as? String ?? ""
        is3d = aDecoder.decodeObject(forKey:"is_3d") as? Bool ?? false
        imdbRate = aDecoder.decodeObject(forKey:"imdb") as? Double ?? 0.0
        rottenTomatoRate = aDecoder.decodeObject(forKey:"rotten") as? Int ?? 0
        duration = aDecoder.decodeObject(forKey:"duration") as? Int ?? 0
        isRated = aDecoder.decodeObject(forKey: "isRated") as? Bool ?? false
        releaseDate = aDecoder.decodeObject(forKey:"releasedDate") as? String ?? ""
        isReviewed = aDecoder.decodeObject(forKey: "isReviewed") as? Bool ?? false
        parentalGuidance = aDecoder.decodeObject(forKey: "pg") as? String ?? ""
        numberOfCinemas = aDecoder.decodeObject(forKey: "numOfCinemas") as? Int ?? 0
        socialMediaLinks = aDecoder.decodeObject(forKey: "socialLinks") as? [[String: Any]] ?? [["" : ""]]
        websiteURL = aDecoder.decodeObject(forKey: "website") as? String ?? ""
        showtimes = aDecoder.decodeObject(forKey: "showTimes") as? [[String: Any]] ?? [["" : ""]]
    }
    
    
//    NSCoding required method, Encodes mode properties into the decoder
    @objc func encode(with aCoder: NSCoder) {
        if id != nil{
            aCoder.encode(id, forKey: "id")
        }
        if poster != nil{
            aCoder.encode(poster, forKey: "poster")
        }
        if title != nil{
            aCoder.encode(title, forKey: "title")
        }
        if rating != nil {
            aCoder.encode(rating, forKey: "rate")
        }
        if actors != nil {
            aCoder.encode(actors, forKey: "actors")
        }
        if trailers != nil {
            aCoder.encode(trailers, forKey: "trailers")
        }
        if director != nil {
            aCoder.encode(director, forKey: "director")
        }
        if cinemas != nil {
            aCoder.encode(cinemas, forKey: "cinemas")
        }
        if language != nil {
            aCoder.encode(language, forKey: "languages")
        }
        if subtitle != nil {
            aCoder.encode(subtitle, forKey: "subtitles")
        }
        if movieGallery != nil {
            aCoder.encode(movieGallery, forKey: "gallery")
        }
        if genres != nil {
            aCoder.encode(genres, forKey: "genre")
        }
        if synopsis != nil {
            aCoder.encode(synopsis, forKey: "synopsis")
        }
        if is3d != nil {
            aCoder.encode(is3d, forKey: "is_3d")
        }
        if imdbRate != nil {
            aCoder.encode(imdbRate, forKey: "imdb")
        }
        if rottenTomatoRate != nil {
            aCoder.encode(rottenTomatoRate, forKey: "rotten")
        }
        if duration != nil {
            aCoder.encode(duration, forKey: "duration")
        }
        if isRated != nil {
            aCoder.encode(isRated, forKey: "isRated")
        }
        if releaseDate != nil {
            aCoder.encode(releaseDate, forKey: "releasedDate")
        }
        if isReviewed != nil {
            aCoder.encode(isReviewed, forKey: "isReviewed")
        }
        if parentalGuidance != nil {
            aCoder.encode(parentalGuidance, forKey: "pg")
        }
        if numberOfCinemas != nil {
            aCoder.encode(numberOfCinemas, forKey: "numOfCinemas")
        }
        if socialMediaLinks != nil {
            aCoder.encode(socialMediaLinks, forKey: "socialLinks")
        }
        if websiteURL != nil {
            aCoder.encode(websiteURL, forKey: "website")
        }
        if showtimes != nil {
            aCoder.encode(showtimes, forKey: "showTimes")
        }
    }
}
