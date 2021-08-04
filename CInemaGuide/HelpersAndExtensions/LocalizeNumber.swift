//
//  UIView+LocalizeNumber.swift
//  CInemaGuide
//
//  Created by Hamad on 1/14/20.
//  Copyright © 2020 Sarmady. All rights reserved.
//

import Foundation

let Number_Formatter = NumberFormatter()
let Time_Formatter = DateFormatter()

extension NSObject {
    //761523478 or 1234.13254
    func localizeNum(_ number: Any) -> String? {
        if CinemaGuideLangs.currentAppleLanguage() == "ar" {
            Number_Formatter.locale = Locale(identifier: "ar")
        } else {
            Number_Formatter.locale = Locale(identifier: "en_US")
        }
        if number is Int {
            Number_Formatter.numberStyle = .none
            return Number_Formatter.string(from: NSNumber(integerLiteral: number as! Int))
        } else if number is Double {
            Number_Formatter.numberStyle = .decimal
            return Number_Formatter.string(from: NSNumber(floatLiteral: number as! Double))
        } else if let number = number as? String {
            if number.contains("."), let doubleNum = Double(number) {
                Number_Formatter.numberStyle = .decimal
                return Number_Formatter.string(from: NSNumber(floatLiteral: doubleNum))
            } else if let intNum = Int(number)  {
                Number_Formatter.numberStyle = .none
                return Number_Formatter.string(from: NSNumber(integerLiteral: intNum))
            }
        }
        return nil
    }
    
    //01:50 or 15:45
    func localizeTim(_ time: Any) -> String? {
        if CinemaGuideLangs.currentAppleLanguage() == "ar" {
            Time_Formatter.locale = Locale(identifier: "ar")
        } else {
            Time_Formatter.locale = Locale(identifier: "en_US")
        }
        Time_Formatter.dateFormat = "HH:mm"
        
        if time is String {
            if let date = Time_Formatter.date(from: time as! String) as? Date {
                return Time_Formatter.string(from: date)
            }
        }
        return nil
    }
    
    //16-1-2020
    func localizeDate(_ time: Any) -> String? {
        if CinemaGuideLangs.currentAppleLanguage() == "ar" {
            Time_Formatter.locale = Locale(identifier: "ar")
        } else {
            Time_Formatter.locale = Locale(identifier: "en_US")
        }
        Time_Formatter.dateFormat = "dd-MM-yyyy"
        
        if time is String {
            if let date = Time_Formatter.date(from: time as! String) as? Date {
                Time_Formatter.dateFormat = "dd - MM - yyyy"
                return Time_Formatter.string(from: date)
            }
        }
        return nil
    }
}
