//
//	CountrySponsor.swift
//
//	Create by Nada Gamal on 6/8/2018
//	Copyright © 2018. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class CountrySponsor : NSObject, NSCoding{

	var baseUrl : String!
	var countryCode : [String]!
	var isActive : Int!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		baseUrl = dictionary["baseUrl"] as? String
		countryCode = dictionary["countryCode"] as? [String]
		isActive = dictionary["isActive"] as? Int
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if baseUrl != nil{
			dictionary["baseUrl"] = baseUrl
		}
		if countryCode != nil{
			dictionary["countryCode"] = countryCode
		}
		if isActive != nil{
			dictionary["isActive"] = isActive
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         baseUrl = aDecoder.decodeObject(forKey: "baseUrl") as? String
         countryCode = aDecoder.decodeObject(forKey: "countryCode") as? [String]
         isActive = aDecoder.decodeObject(forKey: "isActive") as? Int

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if baseUrl != nil{
			aCoder.encode(baseUrl, forKey: "baseUrl")
		}
		if countryCode != nil{
			aCoder.encode(countryCode, forKey: "countryCode")
		}
		if isActive != nil{
			aCoder.encode(isActive, forKey: "isActive")
		}

	}

}