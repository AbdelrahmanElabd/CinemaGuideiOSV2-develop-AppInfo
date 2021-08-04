//
//	Message.swift
//
//	Create by Nada Gamal on 6/8/2018
//	Copyright © 2018. All rights reserved.
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class Message : NSObject, NSCoding{

	var id : Int!
	var isActive : Int!
	var msg : Msg!
	var msgUrl : String!
	var repeatTimes : Int!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		id = dictionary["id"] as? Int
		isActive = dictionary["isActive"] as? Int
		if let msgData = dictionary["msg"] as? [String:Any]{
			msg = Msg(fromDictionary: msgData)
		}
		msgUrl = dictionary["msgUrl"] as? String
		repeatTimes = dictionary["repeatTimes"] as? Int
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if id != nil{
			dictionary["id"] = id
		}
		if isActive != nil{
			dictionary["isActive"] = isActive
		}
		if msg != nil{
			dictionary["msg"] = msg.toDictionary()
		}
		if msgUrl != nil{
			dictionary["msgUrl"] = msgUrl
		}
		if repeatTimes != nil{
			dictionary["repeatTimes"] = repeatTimes
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         id = aDecoder.decodeObject(forKey: "id") as? Int
         isActive = aDecoder.decodeObject(forKey: "isActive") as? Int
         msg = aDecoder.decodeObject(forKey: "msg") as? Msg
         msgUrl = aDecoder.decodeObject(forKey: "msgUrl") as? String
         repeatTimes = aDecoder.decodeObject(forKey: "repeatTimes") as? Int

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if id != nil{
			aCoder.encode(id, forKey: "id")
		}
		if isActive != nil{
			aCoder.encode(isActive, forKey: "isActive")
		}
		if msg != nil{
			aCoder.encode(msg, forKey: "msg")
		}
		if msgUrl != nil{
			aCoder.encode(msgUrl, forKey: "msgUrl")
		}
		if repeatTimes != nil{
			aCoder.encode(repeatTimes, forKey: "repeatTimes")
		}

	}

}