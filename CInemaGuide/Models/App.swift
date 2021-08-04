//
//	App.swift
//
//	Create by Nada Gamal on 6/8/2018
//	Copyright © 2018. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class App : NSObject, NSCoding{

	var isActive : Int!
	var msg : Msg!
	var storeUrl : String!
	var versionCode : Int!
	var versionsNeedCoreUpdate : [String]!
	var versionsNeedUpdate : [String]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		isActive = dictionary["isActive"] as? Int
		if let msgData = dictionary["msg"] as? [String:Any]{
			msg = Msg(fromDictionary: msgData)
		}
		storeUrl = dictionary["storeUrl"] as? String
		versionCode = dictionary["versionCode"] as? Int
		versionsNeedCoreUpdate = dictionary["versionsNeedCoreUpdate"] as? [String]
		versionsNeedUpdate = dictionary["versionsNeedUpdate"] as? [String]
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if isActive != nil{
			dictionary["isActive"] = isActive
		}
		if msg != nil{
			dictionary["msg"] = msg.toDictionary()
		}
		if storeUrl != nil{
			dictionary["storeUrl"] = storeUrl
		}
		if versionCode != nil{
			dictionary["versionCode"] = versionCode
		}
		if versionsNeedCoreUpdate != nil{
			dictionary["versionsNeedCoreUpdate"] = versionsNeedCoreUpdate
		}
		if versionsNeedUpdate != nil{
			dictionary["versionsNeedUpdate"] = versionsNeedUpdate
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         isActive = aDecoder.decodeObject(forKey: "isActive") as? Int
         msg = aDecoder.decodeObject(forKey: "msg") as? Msg
         storeUrl = aDecoder.decodeObject(forKey: "storeUrl") as? String
         versionCode = aDecoder.decodeObject(forKey: "versionCode") as? Int
         versionsNeedCoreUpdate = aDecoder.decodeObject(forKey: "versionsNeedCoreUpdate") as? [String]
         versionsNeedUpdate = aDecoder.decodeObject(forKey: "versionsNeedUpdate") as? [String]

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if isActive != nil{
			aCoder.encode(isActive, forKey: "isActive")
		}
		if msg != nil{
			aCoder.encode(msg, forKey: "msg")
		}
		if storeUrl != nil{
			aCoder.encode(storeUrl, forKey: "storeUrl")
		}
		if versionCode != nil{
			aCoder.encode(versionCode, forKey: "versionCode")
		}
		if versionsNeedCoreUpdate != nil{
			aCoder.encode(versionsNeedCoreUpdate, forKey: "versionsNeedCoreUpdate")
		}
		if versionsNeedUpdate != nil{
			aCoder.encode(versionsNeedUpdate, forKey: "versionsNeedUpdate")
		}

	}

}