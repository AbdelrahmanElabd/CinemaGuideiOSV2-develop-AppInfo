//
//	AppInfo.swift
//
//	Create by Nada Gamal on 6/8/2018
//	Copyright © 2018. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class AppInfo : NSObject, NSCoding{

	var apiBaseUrl : String!
	var app : App!
	var cinemasSponsor : [CinemasSponsor]!
	var countrySponsor : [CountrySponsor]!
	var interstitialAdsEnabledPerVersion : [String]!
	var interstitialNumberOfActions : [Int]!
	var mediaBaseUrl : String!
	var message : Message!
	var moviesSponsor : [MoviesSponsor]!
	var mpuAdsEnabledPerVersion : [String]!
	var mpuListingRepeatCount : Int!
	var sponsor : Sponsor!
	var sponsorAdsEnabledPerVersion : [String]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		apiBaseUrl = dictionary["apiBaseUrl"] as? String
		if let appData = dictionary["app"] as? [String:Any]{
			app = App(fromDictionary: appData)
		}
		cinemasSponsor = [CinemasSponsor]()
		if let cinemasSponsorArray = dictionary["cinemasSponsor"] as? [[String:Any]]{
			for dic in cinemasSponsorArray{
				let value = CinemasSponsor(fromDictionary: dic)
				cinemasSponsor.append(value)
			}
		}
		countrySponsor = [CountrySponsor]()
		if let countrySponsorArray = dictionary["countrySponsor"] as? [[String:Any]]{
			for dic in countrySponsorArray{
				let value = CountrySponsor(fromDictionary: dic)
				countrySponsor.append(value)
			}
		}
		interstitialAdsEnabledPerVersion = dictionary["interstitialAdsEnabledPerVersion"] as? [String]
		interstitialNumberOfActions = dictionary["interstitialNumberOfActions"] as? [Int]
		mediaBaseUrl = dictionary["mediaBaseUrl"] as? String
		if let messageData = dictionary["message"] as? [String:Any]{
			message = Message(fromDictionary: messageData)
		}
		moviesSponsor = [MoviesSponsor]()
		if let moviesSponsorArray = dictionary["moviesSponsor"] as? [[String:Any]]{
			for dic in moviesSponsorArray{
				let value = MoviesSponsor(fromDictionary: dic)
				moviesSponsor.append(value)
			}
		}
		mpuAdsEnabledPerVersion = dictionary["mpuAdsEnabledPerVersion"] as? [String]
		mpuListingRepeatCount = dictionary["mpuListingRepeatCount"] as? Int
		if let sponsorData = dictionary["sponsor"] as? [String:Any]{
			sponsor = Sponsor(fromDictionary: sponsorData)
		}
		sponsorAdsEnabledPerVersion = dictionary["sponsorAdsEnabledPerVersion"] as? [String]
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if apiBaseUrl != nil{
			dictionary["apiBaseUrl"] = apiBaseUrl
		}
		if app != nil{
			dictionary["app"] = app.toDictionary()
		}
		if cinemasSponsor != nil{
			var dictionaryElements = [[String:Any]]()
			for cinemasSponsorElement in cinemasSponsor {
				dictionaryElements.append(cinemasSponsorElement.toDictionary())
			}
			dictionary["cinemasSponsor"] = dictionaryElements
		}
		if countrySponsor != nil{
			var dictionaryElements = [[String:Any]]()
			for countrySponsorElement in countrySponsor {
				dictionaryElements.append(countrySponsorElement.toDictionary())
			}
			dictionary["countrySponsor"] = dictionaryElements
		}
		if interstitialAdsEnabledPerVersion != nil{
			dictionary["interstitialAdsEnabledPerVersion"] = interstitialAdsEnabledPerVersion
		}
		if interstitialNumberOfActions != nil{
			dictionary["interstitialNumberOfActions"] = interstitialNumberOfActions
		}
		if mediaBaseUrl != nil{
			dictionary["mediaBaseUrl"] = mediaBaseUrl
		}
		if message != nil{
			dictionary["message"] = message.toDictionary()
		}
		if moviesSponsor != nil{
			var dictionaryElements = [[String:Any]]()
			for moviesSponsorElement in moviesSponsor {
				dictionaryElements.append(moviesSponsorElement.toDictionary())
			}
			dictionary["moviesSponsor"] = dictionaryElements
		}
		if mpuAdsEnabledPerVersion != nil{
			dictionary["mpuAdsEnabledPerVersion"] = mpuAdsEnabledPerVersion
		}
		if mpuListingRepeatCount != nil{
			dictionary["mpuListingRepeatCount"] = mpuListingRepeatCount
		}
		if sponsor != nil{
			dictionary["sponsor"] = sponsor.toDictionary()
		}
		if sponsorAdsEnabledPerVersion != nil{
			dictionary["sponsorAdsEnabledPerVersion"] = sponsorAdsEnabledPerVersion
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         apiBaseUrl = aDecoder.decodeObject(forKey: "apiBaseUrl") as? String
         app = aDecoder.decodeObject(forKey: "app") as? App
         cinemasSponsor = aDecoder.decodeObject(forKey :"cinemasSponsor") as? [CinemasSponsor]
         countrySponsor = aDecoder.decodeObject(forKey :"countrySponsor") as? [CountrySponsor]
         interstitialAdsEnabledPerVersion = aDecoder.decodeObject(forKey: "interstitialAdsEnabledPerVersion") as? [String]
         interstitialNumberOfActions = aDecoder.decodeObject(forKey: "interstitialNumberOfActions") as? [Int]
         mediaBaseUrl = aDecoder.decodeObject(forKey: "mediaBaseUrl") as? String
         message = aDecoder.decodeObject(forKey: "message") as? Message
         moviesSponsor = aDecoder.decodeObject(forKey :"moviesSponsor") as? [MoviesSponsor]
         mpuAdsEnabledPerVersion = aDecoder.decodeObject(forKey: "mpuAdsEnabledPerVersion") as? [String]
         mpuListingRepeatCount = aDecoder.decodeObject(forKey: "mpuListingRepeatCount") as? Int
         sponsor = aDecoder.decodeObject(forKey: "sponsor") as? Sponsor
         sponsorAdsEnabledPerVersion = aDecoder.decodeObject(forKey: "sponsorAdsEnabledPerVersion") as? [String]

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if apiBaseUrl != nil{
			aCoder.encode(apiBaseUrl, forKey: "apiBaseUrl")
		}
		if app != nil{
			aCoder.encode(app, forKey: "app")
		}
		if cinemasSponsor != nil{
			aCoder.encode(cinemasSponsor, forKey: "cinemasSponsor")
		}
		if countrySponsor != nil{
			aCoder.encode(countrySponsor, forKey: "countrySponsor")
		}
		if interstitialAdsEnabledPerVersion != nil{
			aCoder.encode(interstitialAdsEnabledPerVersion, forKey: "interstitialAdsEnabledPerVersion")
		}
		if interstitialNumberOfActions != nil{
			aCoder.encode(interstitialNumberOfActions, forKey: "interstitialNumberOfActions")
		}
		if mediaBaseUrl != nil{
			aCoder.encode(mediaBaseUrl, forKey: "mediaBaseUrl")
		}
		if message != nil{
			aCoder.encode(message, forKey: "message")
		}
		if moviesSponsor != nil{
			aCoder.encode(moviesSponsor, forKey: "moviesSponsor")
		}
		if mpuAdsEnabledPerVersion != nil{
			aCoder.encode(mpuAdsEnabledPerVersion, forKey: "mpuAdsEnabledPerVersion")
		}
		if mpuListingRepeatCount != nil{
			aCoder.encode(mpuListingRepeatCount, forKey: "mpuListingRepeatCount")
		}
		if sponsor != nil{
			aCoder.encode(sponsor, forKey: "sponsor")
		}
		if sponsorAdsEnabledPerVersion != nil{
			aCoder.encode(sponsorAdsEnabledPerVersion, forKey: "sponsorAdsEnabledPerVersion")
		}

	}

}