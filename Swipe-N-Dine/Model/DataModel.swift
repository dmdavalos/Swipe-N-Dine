//
//  DataModel.swift
//  Swipe-N-Dine
//
//  Created by Daniel Davalos on 1/2/18.
//  Copyright © 2018 Daniel Davalos. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

protocol YelpFetcherDelegate {
    func didReceiveRestaurants(result: JSON)
}

class YelpAPIFetcher {
    private let BASE_URL: String = "https://api.yelp.com/v3/businesses/search?"
    
    // MARK: IMPORTANT! Add your Yelp API key here!
    private let HEADERS: HTTPHeaders = ["Authorization":"Bearer YOUR_API_KEY"]
    
    var delegate: YelpFetcherDelegate?
    
    public func getRestaurants(lat: Double, lon: Double) {
        Alamofire.request(BASE_URL + "latitude=\(lat)&longitude=\(lon)", headers: HEADERS).responseJSON { (response) in
            if response.result.isSuccess {
                print("Yelp API fetching successful!")
                self.delegate?.didReceiveRestaurants(result: JSON(response.result.value!))
            } else {
                print("Error fetching restaurants! \(response.error.debugDescription)")
            }
        }
    }
}
