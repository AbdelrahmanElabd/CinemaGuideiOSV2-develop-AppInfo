//
//  APIManager.swift
//  CInemaGuide
//
//  Created by Hesham Haleem on 6/6/17.
//  Copyright © 2017 HeshamHaleem. All rights reserved.
//

import UIKit
import Alamofire
import AwesomeCache
//import Instabug
class APIConstants {
    //MARK: - App constants
    struct URLs {
//        static let baseURL = "http://apitest.filbalad.com/api/"
       // static var baseURL =   "https://apiv2.filbalad.com/api/"
        static let homeURL = "home"
        static let cinemasURL = "cinemas"
        static let moviesURL = "movies"
        static let moviesFiltersURL = "movies/filters"
        static let rateMovieURL = "movies/rate"
        static var locale = CinemaGuideLangs.currentAppleLanguage()
        static var serverTimeURL = "getServerTime"
        static let countriesURL = "countries"
    }
}

//func AppInfoHelper.getAPIBaseURL()-> String{
//    var baseURL = ""
//    let appInfoCache = try! Cache<NSDictionary>(name: "AppInfoCache")
//    if let appInfoData = appInfoCache["AppInfoCache"] {
//        let appInfo = AppInfo(fromDictionary: appInfoData as! [String : Any])
//        baseURL = appInfo.baseUrl
//    }
//    else{
//     baseURL = "https://apiv2.filbalad.com/api/"
//    }
//    return baseURL
//}
//MARK: -
class APIManager: NSObject {

    typealias dictionarySuccess = (_ result: [String: Any]) -> Void
    typealias movieModelSuccess = (_ result: MovieModel) -> Void
    typealias cinemaModelSuccess = (_ result: CinemaModel) -> Void
    typealias movieFiltersSuccess = (_ result: MoviesFiltersModel) -> Void
    typealias countriesSuccess = (_ result: [CountryModel]) -> Void
    typealias appInfoSuccess = (_ result: AppInfo) -> Void
    typealias apiSuccess = (_ result: NSArray) -> Void
    typealias apiFailure = (_ error: NSError?) -> Void
    static let appInfoCache = try! Cache<NSDictionary>(name: "AppInfoCache")
    
//    static let headers = [
//        "XDevice": "ios",
//    ]
    
    //MARK: - Class singleton
    class var SharedInstance: APIManager {
        struct Static {
            static let instance: APIManager = APIManager()
        }
        return Static.instance
    }
    
    //MARK: - Server Time Request
    class func getServerTime(success: @escaping dictionarySuccess, failure: @escaping apiFailure) {
        Alamofire.request(AppInfoHelper.getAPIBaseURL() + APIConstants.URLs.serverTimeURL, method: .get).responseString { (response) in
            if response.result.isSuccess {
                success(["ServerTime": "\(response.result.value ?? "0")"])
            } else {
                failure(response.result.error! as NSError)
            }
        }
    }
    
    //MARK: - Home Request
    class func getHomeData(longtide: Double, latitude: Double, CinemasIDs: String, success:@escaping dictionarySuccess, failure:@escaping apiFailure) {
        let url = AppInfoHelper.getAPIBaseURL() + APIConstants.URLs.homeURL + "?lng=\(longtide)&lat=\(latitude)&cinemaIds=\(CinemasIDs)&locale=\(APIConstants.URLs.locale)&country=\(UserDefaults.standard.object(forKey: "UserCountry") as? String ?? "egypt")"
        let hmac = HMACAuthentication(appId: "4d53bce03ec34c0a911182d4c228ee6c", andApiSecret: "A93reRTUJHsCuQSHR+L3GxqOJyDmQpCgps102ciuabc=")
        let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: "")
        let requestHeader = ["Authorization": authHeaders ?? "",]
        Alamofire.request(url, method: .get, headers: requestHeader).responseJSON { (response) in
            if response.result.isSuccess {
                let apiResponse = response.result.value as! [String: AnyObject]
                var responseObject = [String: Any]()
                if let errorMessagr = apiResponse["message"] {
                    print(errorMessagr)
                    let error = NSError(domain: "Unknow Error", code: 00, userInfo: apiResponse)
                    failure(error)
                    
                } else {
                    if let nowPlayingMoviesResponse = apiResponse["nowPlaying"] {
                        let nowPlayingMoviesArray = NSMutableArray()
                        for nowPlayingMovie in nowPlayingMoviesResponse as! NSArray {
                            let movieDict = nowPlayingMovie as! [String: Any]
                            let movieModel = MovieModel.init(fromDictionary: movieDict)
                            nowPlayingMoviesArray.add(movieModel)
                        }
                        responseObject["nowPlayingMovies"] = nowPlayingMoviesArray
                    } else {
                        responseObject["nowPlayingMovies"] = []
                    }
                    if let featuresMoviesResponse = apiResponse["featured"] {
                        let featuredMoviesArray = NSMutableArray()
                        for featuredMovie in featuresMoviesResponse as! NSArray {
                            let movieDict = featuredMovie as! [String: Any]
                            let movieModel = MovieModel.init(fromDictionary: movieDict)
                            featuredMoviesArray.add(movieModel)
                        }
                        responseObject["featuredMovies"] = featuredMoviesArray
                    } else {
                        responseObject["featuredMovies"] = []
                    }
                    if let comingSoonMoviesResponse = apiResponse["comingSoon"] {
                        let comingSoonMoviesArray = NSMutableArray()
                        for comingSoonMovie in comingSoonMoviesResponse as! NSArray {
                            let movieDict = comingSoonMovie as! [String: Any]
                            let movieModel = MovieModel.init(fromDictionary: movieDict)
                            comingSoonMoviesArray.add(movieModel)
                        }
                        responseObject["comingSoonMovies"] = comingSoonMoviesArray
                    } else {
                        responseObject["comingSoonMovies"] = []
                    }
                    if let cinemas = apiResponse["nearByCinemas"] {
                        let nearbyCinemas = cinemas as! NSArray
                        if nearbyCinemas.count != 0 {
                            let nearbyCinemasArray = NSMutableArray()
                            for nearbyCinema in nearbyCinemas {
                                let cinemaDict = nearbyCinema as! [String : Any]
                                let cinemaModel = CinemaModel.init(fromDictionary: cinemaDict)
                                nearbyCinemasArray.add(cinemaModel)
                            }
                            responseObject["nearbyCinemas"] = nearbyCinemasArray
                        } else {
                            responseObject["nearbyCinemas"] = []
                        }
                    } else {
                        responseObject["nearbyCinemas"] = []
                    }
                    if let cinemas = apiResponse["favoriteCinemas"] {
                        let favoriteCinemas = cinemas as! NSArray
                        if favoriteCinemas.count != 0 {
                            let favoriteCinemasArray = NSMutableArray()
                            for favoriteCinema in favoriteCinemas {
                                let cinemaDict = favoriteCinema as! [String : Any]
                                let cinemaModel = CinemaModel.init(fromDictionary: cinemaDict)
                                favoriteCinemasArray.add(cinemaModel)
                            }
                            responseObject["favoriteCinemas"] = favoriteCinemasArray
                        } else {
                            responseObject["favoriteCinemas"] = []
                        }
                    } else {
                        responseObject["favoriteCinemas"] = []
                    }
                    success(responseObject)
                }
            } else if response.result.isFailure {
                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        self.getServerTime(success: { (responseObject: [String: Any]) -> Void in
                            let serverTimeString = responseObject["ServerTime"] as! String
                            let serverTime = Double(serverTimeString)
                            let time = NSDate().timeIntervalSince1970
                            let interval = Int(serverTime!) - Int(time)
                            let date1 = NSDate().addingTimeInterval(Double(interval))
                            let time1 = date1.timeIntervalSince1970
                            let timestamp = "\(Int(time1))"
                            let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: timestamp)
                            let requestHeader = ["Authorization": authHeaders ?? "",]
                            Alamofire.request(url, method: .get, headers: requestHeader).responseJSON { (response) in
                                if response.result.isSuccess {
                                    let apiResponse = response.result.value as! [String: AnyObject]
                                    var responseObject = [String: Any]()
                                    if let errorMessagr = apiResponse["message"] {
                                        print(errorMessagr)
                                        let error = NSError(domain: "Unknow Error", code: 00, userInfo: apiResponse)
                                        failure(error)
                                    } else {
                                        if let nowPlayingMoviesResponse = apiResponse["nowPlaying"] {
                                            let nowPlayingMoviesArray = NSMutableArray()
                                            for nowPlayingMovie in nowPlayingMoviesResponse as! NSArray {
                                                let movieDict = nowPlayingMovie as! [String: Any]
                                                let movieModel = MovieModel.init(fromDictionary: movieDict)
                                                nowPlayingMoviesArray.add(movieModel)
                                            }
                                            responseObject["nowPlayingMovies"] = nowPlayingMoviesArray
                                        } else {
                                            responseObject["nowPlayingMovies"] = []
                                        }
                                        if let featuresMoviesResponse = apiResponse["featured"] {
                                            let featuredMoviesArray = NSMutableArray()
                                            for featuredMovie in featuresMoviesResponse as! NSArray {
                                                let movieDict = featuredMovie as! [String: Any]
                                                let movieModel = MovieModel.init(fromDictionary: movieDict)
                                                featuredMoviesArray.add(movieModel)
                                            }
                                            responseObject["featuredMovies"] = featuredMoviesArray
                                        } else {
                                            responseObject["featuredMovies"] = []
                                        }
                                        if let comingSoonMoviesResponse = apiResponse["comingSoon"] {
                                            let comingSoonMoviesArray = NSMutableArray()
                                            for comingSoonMovie in comingSoonMoviesResponse as! NSArray {
                                                let movieDict = comingSoonMovie as! [String: Any]
                                                let movieModel = MovieModel.init(fromDictionary: movieDict)
                                                comingSoonMoviesArray.add(movieModel)
                                            }
                                            responseObject["comingSoonMovies"] = comingSoonMoviesArray
                                        } else {
                                            responseObject["comingSoonMovies"] = []
                                        }
                                        if let cinemas = apiResponse["nearByCinemas"] {
                                            let nearbyCinemas = cinemas as! NSArray
                                            if nearbyCinemas.count != 0 {
                                                let nearbyCinemasArray = NSMutableArray()
                                                for nearbyCinema in nearbyCinemas {
                                                    let cinemaDict = nearbyCinema as! [String : Any]
                                                    let cinemaModel = CinemaModel.init(fromDictionary: cinemaDict)
                                                    nearbyCinemasArray.add(cinemaModel)
                                                }
                                                responseObject["nearbyCinemas"] = nearbyCinemasArray
                                            } else {
                                                responseObject["nearbyCinemas"] = []
                                            }
                                        } else {
                                            responseObject["nearbyCinemas"] = []
                                        }
                                        if let cinemas = apiResponse["favoriteCinemas"] {
                                            let favoriteCinemas = cinemas as! NSArray
                                            if favoriteCinemas.count != 0 {
                                                let favoriteCinemasArray = NSMutableArray()
                                                for favoriteCinema in favoriteCinemas {
                                                    let cinemaDict = favoriteCinema as! [String : Any]
                                                    let cinemaModel = CinemaModel.init(fromDictionary: cinemaDict)
                                                    favoriteCinemasArray.add(cinemaModel)
                                                }
                                                responseObject["favoriteCinemas"] = favoriteCinemasArray
                                            } else {
                                                responseObject["favoriteCinemas"] = []
                                            }
                                        } else {
                                            responseObject["favoriteCinemas"] = []
                                        }
                                        success(responseObject)
                                    }
                                } else if response.result.isFailure {
                                    failure(response.result.error! as NSError)
                                }
                            }
                        }, failure: { (error: NSError?) in
                            failure(response.result.error! as NSError)
                        })
                    } else {
                        failure(response.result.error! as NSError)
                    }
                } else {
                    failure(response.result.error! as NSError)
                }
            }
        }
    }
    
    //MARK: - All Cinemas Request
    class func getAllCinemas(pageNumber: Int, pageSize: Int, longitude: Double, latitude: Double, sorting: String, is3D: String, priceRange: String, searchQuery: String, success:@escaping (_ result: [CinemaModel]) -> Void, failure:@escaping apiFailure) {
//        let theQuery = searchQuery.replacingOccurrences(of: " ", with: "")
        let theQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let urlString = AppInfoHelper.getAPIBaseURL() + APIConstants.URLs.cinemasURL + "?page=\(pageNumber)&pagesize=\(pageSize)&locale=\(APIConstants.URLs.locale)&lng=\(longitude)&lat=\(latitude)&sorting=\(sorting)&is3d=\(is3D)&priceRange=\(priceRange)&direction=asc&query=\(theQuery)&country=\(UserDefaults.standard.object(forKey: "UserCountry") as? String ?? "egypt")"
//        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let hmac = HMACAuthentication(appId: "4d53bce03ec34c0a911182d4c228ee6c", andApiSecret: "A93reRTUJHsCuQSHR+L3GxqOJyDmQpCgps102ciuabc=")
        let authHeaders = hmac?.getHeaderString(usingUrlString: urlString, parameters: nil, requestType: "GET", andTimeStamp: "")
        let requestHeader = ["Authorization": authHeaders ?? "",]
        Alamofire.request(urlString, method: .get, headers: requestHeader).responseJSON { (response) in
            if response.result.isSuccess {
                let responseArray = response.result.value as! NSArray
                var responseObject = [CinemaModel]()
                for cinema in responseArray {
                    let cinemaDict = cinema as! [String : Any]
                    let cinemaModel = CinemaModel.init(fromDictionary: cinemaDict)
                    responseObject.append(cinemaModel)
                }
                success(responseObject)
            } else if response.result.isFailure {
                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        self.getServerTime(success: { (responseObject: [String: Any]) -> Void in
                            let serverTimeString = responseObject["ServerTime"] as! String
                            let serverTime = Double(serverTimeString)
                            let time = NSDate().timeIntervalSince1970
                            let interval = Int(serverTime!) - Int(time)
                            let date1 = NSDate().addingTimeInterval(Double(interval))
                            let time1 = date1.timeIntervalSince1970
                            let timestamp = "\(Int(time1))"
                            let authHeaders = hmac?.getHeaderString(usingUrlString: urlString, parameters: nil, requestType: "GET", andTimeStamp: timestamp)
                            let requestHeader = ["Authorization": authHeaders ?? "",]
                            Alamofire.request(urlString, method: .get, headers: requestHeader).responseJSON(completionHandler: { (response) in
                                if response.result.isSuccess {
                                    let responseArray = response.result.value as! NSArray
                                    var responseObject = [CinemaModel]()
                                    for cinema in responseArray {
                                        let cinemaDict = cinema as! [String : Any]
                                        let cinemaModel = CinemaModel.init(fromDictionary: cinemaDict)
                                        responseObject.append(cinemaModel)
                                    }
                                    success(responseObject)
                                } else if response.result.isFailure {
                                    failure(response.result.error! as NSError)
                                }
                            })
                        }, failure: { (error: NSError?) in
                            failure(response.result.error! as NSError)
                        })
                    } else {
                        failure(response.result.error! as NSError)
                    }
                } else {
                    failure(response.result.error! as NSError)
                }
            }
        }
    }
    
    //MARK: - Cinema Details Request
    class func getCinemaDetails(cinemaID: Int, success:@escaping cinemaModelSuccess, failure: @escaping apiFailure) {
        let url = AppInfoHelper.getAPIBaseURL() + APIConstants.URLs.cinemasURL + "/\(cinemaID)?locale=\(APIConstants.URLs.locale)&country=\(UserDefaults.standard.object(forKey: "UserCountry") as? String ?? "egypt")"
        let hmac = HMACAuthentication(appId: "4d53bce03ec34c0a911182d4c228ee6c", andApiSecret: "A93reRTUJHsCuQSHR+L3GxqOJyDmQpCgps102ciuabc=")
        let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: "")
        let requestHeader = ["Authorization": authHeaders ?? "",]
        Alamofire.request(url, method: .get, headers: requestHeader).responseJSON { (response) in
            if response.result.isSuccess {
                let apiResponse = response.result.value as! [String: Any]
                let cinemaModel = CinemaModel.init(fromDictionary: apiResponse)
                success(cinemaModel)
            } else if response.result.isFailure {
                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        self.getServerTime(success: { (responseObject: [String: Any]) -> Void in
                            let serverTimeString = responseObject["ServerTime"] as! String
                            let serverTime = Double(serverTimeString)
                            let time = NSDate().timeIntervalSince1970
                            let interval = Int(serverTime!) - Int(time)
                            let date1 = NSDate().addingTimeInterval(Double(interval))
                            let time1 = date1.timeIntervalSince1970
                            let timestamp = "\(Int(time1))"
                            let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: timestamp)
                            let requestHeader = ["Authorization": authHeaders ?? "",]
                            Alamofire.request(url, method: .get, headers: requestHeader).responseJSON { (response) in
                                if response.result.isSuccess {
                                    let apiResponse = response.result.value as! [String: Any]
                                    let cinemaModel = CinemaModel.init(fromDictionary: apiResponse)
                                    success(cinemaModel)
                                } else if response.result.isFailure {
                                    failure(response.result.error! as NSError)
                                }
                            }
                        }, failure: { (error: NSError?) in
                            failure(response.result.error! as NSError)
                        })
                    } else {
                        failure(response.result.error! as NSError)
                    }
                } else {
                    failure(response.result.error! as NSError)
                }
            }
        }
    }
    
    //MARK: - All Movies Request
    class func getAllMovies(pageNumber: Int, pageSize: Int, inCinema: Bool, is3D: String, genres: String, sorting: String, language: String, pg: String, searchQuery: String, dir: String, success:@escaping (_ result: [MovieModel]) -> Void, failure:@escaping apiFailure) {
//        let theQuery = searchQuery.replacingOccurrences(of: " ", with: "")
        let theQuery = searchQuery.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let urlString = AppInfoHelper.getAPIBaseURL() + APIConstants.URLs.moviesURL + "?page=\(pageNumber)&pagesize=\(pageSize)&locale=\(APIConstants.URLs.locale)&onCinema=\(inCinema)&sorting=\(sorting)&is3d=\(is3D)&genre=\(genres)&lang=\(language)&pg=\(pg)&direction=\(dir)&query=\(theQuery)&country=\(UserDefaults.standard.object(forKey: "UserCountry") as? String ?? "egypt")"
        let hmac = HMACAuthentication(appId: "4d53bce03ec34c0a911182d4c228ee6c", andApiSecret: "A93reRTUJHsCuQSHR+L3GxqOJyDmQpCgps102ciuabc=")
        let authHeaders = hmac?.getHeaderString(usingUrlString: urlString, parameters: nil, requestType: "GET", andTimeStamp: "")
        let requestHeader = ["Authorization": authHeaders ?? "",]
//        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        Alamofire.request(urlString, method: .get, headers: requestHeader).responseJSON { (response) in
            if response.result.isSuccess {
                let responseArray = response.result.value as! NSArray
                var responseObject = [MovieModel]()
                for movie in responseArray {
                    let movieDict = movie as! [String: Any]
                    let movieModel = MovieModel.init(fromDictionary: movieDict)
                    responseObject.append(movieModel)
                }
                success(responseObject)
            } else if response.result.isFailure {
                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        self.getServerTime(success: { (responseObject: [String: Any]) -> Void in
                            let serverTimeString = responseObject["ServerTime"] as! String
                            let serverTime = Double(serverTimeString)
                            let time = NSDate().timeIntervalSince1970
                            let interval = Int(serverTime!) - Int(time)
                            let date1 = NSDate().addingTimeInterval(Double(interval))
                            let time1 = date1.timeIntervalSince1970
                            let timestamp = "\(Int(time1))"
                            let authHeaders = hmac?.getHeaderString(usingUrlString: urlString, parameters: nil, requestType: "GET", andTimeStamp: timestamp)
                            let requestHeader = ["Authorization": authHeaders ?? "",]
                            Alamofire.request(urlString, method: .get, headers: requestHeader).responseJSON { (response) in
                                if response.result.isSuccess {
                                    let responseArray = response.result.value as! NSArray
                                    var responseObject = [MovieModel]()
                                    for movie in responseArray {
                                        let movieDict = movie as! [String: Any]
                                        let movieModel = MovieModel.init(fromDictionary: movieDict)
                                        responseObject.append(movieModel)
                                    }
                                    success(responseObject)
                                } else if response.result.isFailure {
                                    failure(response.result.error! as NSError)
                                }
                            }
                        }, failure: { (error: NSError?) in
                            failure(response.result.error! as NSError)
                        })
                    } else {
                        failure(response.result.error! as NSError)
                    }
                } else {
                    failure(response.result.error! as NSError)
                }
            }
        }
    }
    
    //MARK: - Movie Details Request
    class func getMovieDetails(movieID: Int, success:@escaping movieModelSuccess, failure:@escaping apiFailure) {
        let url = AppInfoHelper.getAPIBaseURL() + APIConstants.URLs.moviesURL + "/\(movieID)?locale=\(APIConstants.URLs.locale)&country=\(UserDefaults.standard.object(forKey: "UserCountry") as? String ?? "egypt")"
        let hmac = HMACAuthentication(appId: "4d53bce03ec34c0a911182d4c228ee6c", andApiSecret: "A93reRTUJHsCuQSHR+L3GxqOJyDmQpCgps102ciuabc=")
        let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: "")
        let requestHeader = ["Authorization": authHeaders ?? "",]
        Alamofire.request(url, method: .get, headers: requestHeader).responseJSON { (response) in
            if response.result.isSuccess {
                let apiResponse = response.result.value as! [String: Any]
                let movieModel = MovieModel.init(fromDictionary: apiResponse)
                success(movieModel)
            } else if response.result.isFailure {
                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        self.getServerTime(success: { (responseObject: [String: Any]) -> Void in
                            let serverTimeString = responseObject["ServerTime"] as! String
                            let serverTime = Double(serverTimeString)
                            let time = NSDate().timeIntervalSince1970
                            let interval = Int(serverTime!) - Int(time)
                            let date1 = NSDate().addingTimeInterval(Double(interval))
                            let time1 = date1.timeIntervalSince1970
                            let timestamp = "\(Int(time1))"
                            let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: timestamp)
                            let requestHeader = ["Authorization": authHeaders ?? "",]
                            Alamofire.request(url, method: .get, headers: requestHeader).responseJSON { (response) in
                                if response.result.isSuccess {
                                    let apiResponse = response.result.value as! [String: Any]
                                    let movieModel = MovieModel.init(fromDictionary: apiResponse)
                                    success(movieModel)
                                } else if response.result.isFailure {
                                    failure(response.result.error! as NSError)
                                }
                            }
                        }, failure: { (error: NSError?) in
                            failure(response.result.error! as NSError)
                        })
                    } else {
                        failure(response.result.error! as NSError)
                    }
                } else {
                    failure(response.result.error! as NSError)
                }
            }
        }
    }
    
    //MARK: - Movies Filters Request
    class func getMoviesFilter(success:@escaping movieFiltersSuccess, failure:@escaping apiFailure) {
        let url = AppInfoHelper.getAPIBaseURL() + APIConstants.URLs.moviesFiltersURL + "?locale=\(APIConstants.URLs.locale)&country=\(UserDefaults.standard.object(forKey: "UserCountry") as? String ?? "egypt")"
        let hmac = HMACAuthentication(appId: "4d53bce03ec34c0a911182d4c228ee6c", andApiSecret: "A93reRTUJHsCuQSHR+L3GxqOJyDmQpCgps102ciuabc=")
        let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: "")
        let requestHeader = ["Authorization": authHeaders ?? "",]
        Alamofire.request(url, method: .get, headers: requestHeader).responseJSON { (response) in
            if response.result.isSuccess {
                let responseData = response.result.value as! [String: Any]
                let filterModel = MoviesFiltersModel.init(fromDictionary: responseData)
                success(filterModel)
            } else if response.result.isFailure {
                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        self.getServerTime(success: { (responseObject: [String: Any]) -> Void in
                            let serverTimeString = responseObject["ServerTime"] as! String
                            let serverTime = Double(serverTimeString)
                            let time = NSDate().timeIntervalSince1970
                            let interval = Int(serverTime!) - Int(time)
                            let date1 = NSDate().addingTimeInterval(Double(interval))
                            let time1 = date1.timeIntervalSince1970
                            let timestamp = "\(Int(time1))"
                            let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: timestamp)
                            let requestHeader = ["Authorization": authHeaders ?? "",]
                            Alamofire.request(url, method: .get, headers: requestHeader).responseJSON { (response) in
                                if response.result.isSuccess {
                                    let responseData = response.result.value as! [String: Any]
                                    let filterModel = MoviesFiltersModel.init(fromDictionary: responseData)
                                    success(filterModel)
                                } else if response.result.isFailure {
                                    failure(response.result.error! as NSError)
                                }
                            }
                        }, failure: { (error: NSError?) in
                            failure(response.result.error! as NSError)
                        })
                    } else {
                        failure(response.result.error! as NSError)
                    }
                } else {
                    failure(response.result.error! as NSError)
                }
            }
        }
    }
    
    //MARK: - Rate Movie Request
    class func rateMovie(movieID: Int, success:@escaping dictionarySuccess, failure:@escaping apiFailure) {
        let url = AppInfoHelper.getAPIBaseURL() + APIConstants.URLs.rateMovieURL + "?locale=\(APIConstants.URLs.locale)&id=\(movieID)&country=\(UserDefaults.standard.object(forKey: "UserCountry") as? String ?? "egypt")"
        let hmac = HMACAuthentication(appId: "4d53bce03ec34c0a911182d4c228ee6c", andApiSecret: "A93reRTUJHsCuQSHR+L3GxqOJyDmQpCgps102ciuabc=")
        let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "POST", andTimeStamp: "")
        let requestHeader = ["Authorization": authHeaders ?? "", "xDevice": "ios",]
        Alamofire.request(url, method: .post, headers: requestHeader).responseString { (response) in
            if response.result.isSuccess {
                success(["Success": "\(response.result.value ?? "Success")"])
            } else if response.result.isFailure {
                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        self.getServerTime(success: { (responseObject: [String: Any]) -> Void in
                            let serverTimeString = responseObject["ServerTime"] as! String
                            let serverTime = Double(serverTimeString)
                            let time = NSDate().timeIntervalSince1970
                            let interval = Int(serverTime!) - Int(time)
                            let date1 = NSDate().addingTimeInterval(Double(interval))
                            let time1 = date1.timeIntervalSince1970
                            let timestamp = "\(Int(time1))"
                            let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: timestamp)
                            let requestHeader = ["Authorization": authHeaders ?? "",]
                            Alamofire.request(url, method: .post, headers: requestHeader).responseString { (response) in
                                if response.result.isSuccess {
                                    success(["Success": "\(response.result.value ?? "Success")"])
                                } else if response.result.isFailure {
                                    failure(response.result.error! as NSError)
                                }
                            }
                        }, failure: { (error: NSError?) in
                            failure(response.result.error! as NSError)
                        })
                    } else {
                        failure(response.result.error! as NSError)
                    }
                } else {
                    failure(response.result.error! as NSError)
                }
            }
        }
    }
    
    //MARK: - Get Rate Movie Request
    class func getMovieRate(movieID: Int, success:@escaping dictionarySuccess, failure:@escaping apiFailure) {
        let url = AppInfoHelper.getAPIBaseURL() + APIConstants.URLs.rateMovieURL + "?&id=\(movieID)"
        let hmac = HMACAuthentication(appId: "4d53bce03ec34c0a911182d4c228ee6c", andApiSecret: "A93reRTUJHsCuQSHR+L3GxqOJyDmQpCgps102ciuabc=")
        let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: "")
        let requestHeader = ["Authorization": authHeaders ?? "", "xDevice": "ios",]
        Alamofire.request(url, method: .get, headers: requestHeader).responseString { (response) in
            if response.result.isSuccess {
                success(["movieRate": "\(response.result.value ?? "0")"])
            } else if response.result.isFailure {
                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        self.getServerTime(success: { (responseObject: [String: Any]) -> Void in
                            let serverTimeString = responseObject["ServerTime"] as! String
                            let serverTime = Double(serverTimeString)
                            let time = NSDate().timeIntervalSince1970
                            let interval = Int(serverTime!) - Int(time)
                            let date1 = NSDate().addingTimeInterval(Double(interval))
                            let time1 = date1.timeIntervalSince1970
                            let timestamp = "\(Int(time1))"
                            let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: timestamp)
                            let requestHeader = ["Authorization": authHeaders ?? "",]
                            Alamofire.request(url, method: .get, headers: requestHeader).responseString { (response) in
                                if response.result.isSuccess {
                                    success(["movieRate": "\(response.result.value ?? "0")"])
                                } else if response.result.isFailure {
                                    failure(response.result.error! as NSError)
                                }
                            }
                        }, failure: { (error: NSError?) in
                            failure(response.result.error! as NSError)
                        })
                    } else {
                        failure(response.result.error! as NSError)
                    }
                } else {
                    failure(response.result.error! as NSError)
                }
            }
        }
    }
    
    //MARK: - Countries request
    class func getCountries( success: @escaping countriesSuccess, failure: @escaping apiFailure) {
        let url = AppInfoHelper.getAPIBaseURL() + APIConstants.URLs.countriesURL + "?direction=asc" + "&locale=\(APIConstants.URLs.locale)"
        let hmac = HMACAuthentication(appId: "4d53bce03ec34c0a911182d4c228ee6c", andApiSecret: "A93reRTUJHsCuQSHR+L3GxqOJyDmQpCgps102ciuabc=")
        let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: "")
        let requestHeader = ["Authorization": authHeaders ?? ""]
        Alamofire.request(url, method: .get, headers: requestHeader).responseJSON { (response) in
            if response.result.isSuccess {
                let responseObject = response.result.value as![[String: Any]]
                var countries = [CountryModel]()
                for country in responseObject {
                    let aCountry = CountryModel(fromDictionary: country)
                    countries.append(aCountry)
                }
                success(countries)
            } else {
                if let statusCode = response.response?.statusCode {
                    if statusCode == 401 {
                        self.getServerTime(success: { (responseObject: [String: Any]) -> Void in
                            let serverTimeString = responseObject["ServerTime"] as! String
                            let serverTime = Double(serverTimeString)
                            let time = NSDate().timeIntervalSince1970
                            let interval = Int(serverTime!) - Int(time)
                            let date1 = NSDate().addingTimeInterval(Double(interval))
                            let time1 = date1.timeIntervalSince1970
                            let timestamp = "\(Int(time1))"
                            let authHeaders = hmac?.getHeaderString(usingUrlString: url, parameters: nil, requestType: "GET", andTimeStamp: timestamp)
                            let requestHeader = ["Authorization": authHeaders ?? "",]
                            Alamofire.request(url, method: .get, headers: requestHeader).responseJSON { (response) in
                                if response.result.isSuccess {
                                    let responseObject = response.result.value as![[String: Any]]
                                    var countries = [CountryModel]()
                                    for country in responseObject {
                                        let aCountry = CountryModel(fromDictionary: country)
                                        countries.append(aCountry)
                                    }
                                    success(countries)
                                } else if response.result.isFailure {
                                    failure(response.result.error! as NSError)
                                }
                            }
                        }, failure: { (error: NSError?) in
                            failure(response.result.error! as NSError)
                        })
                    } else {
                        failure(response.result.error! as NSError)
                    }
                } else {
                    failure(response.result.error! as NSError)
                }
            }
        }
    }
    
    //MARK: - App info request
    //dev Url : https://www.filbalad.com/system/settings/cinemaguideiosv2/appinfotest.json
    //production Url https://www.filbalad.com/system/settings/cinemaguideiosv2/cinemaguideiosv2appinfo.json?t=0
    // New AppInfo Version https://www.filbalad.com/system/settings/cinemaguideiosv2/appinfov2/appinfo.json
    class func getAppInfo(success: @escaping appInfoSuccess, failure: @escaping apiFailure) {
        URLCache.shared.removeAllCachedResponses()
        print("https://www.filbalad.com/system/settings/cinemaguideiosv2/appinfov2/appinfo.json")
        Alamofire.request("https://www.filbalad.com/system/settings/cinemaguideiosv2/appinfov2/appinfo.json", method: .get).responseJSON { (response) in
            if response.result.isSuccess {
                let responseObject = response.result.value as? [String: Any]
                Helper.appInfo = AppInfo(fromDictionary: responseObject!)
                success(Helper.appInfo)
            } else if response.result.isFailure {
                failure(response.result.error! as NSError)
            }
        }
    }
}
