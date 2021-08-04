//
//	Msg.swift
//
//	Create by Nada Gamal on 6/8/2018
//	Copyright © 2018. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class Msg : NSObject, NSCoding{

	var ar : String!
	var en : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		ar = dictionary["ar"] as? String
		en = dictionary["en"] as? String
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if ar != nil{
			dictionary["ar"] = ar
		}
		if en != nil{
			dictionary["en"] = en
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         ar = aDecoder.decodeObject(forKey: "ar") as? String
         en = aDecoder.decodeObject(forKey: "en") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if ar != nil{
			aCoder.encode(ar, forKey: "ar")
		}
		if en != nil{
			aCoder.encode(en, forKey: "en")
		}

	}

}