//
//  DataModel.swift
//  Swipe-N-Dine
//
//  Created by Daniel Davalos on 1/2/18.
//  Copyright © 2018 Daniel Davalos. All rights reserved.
//

import Foundation
import CDYelpFusionKit

protocol DataModelDelegate {
    func receievedData(data: [CDYelpBusiness])
}

class DataModel {
    var delegate: DataModelDelegate?
    
    // MARK: Important! Add your Yelp API keys here!
    let yelpAPIClient = CDYelpAPIClient(clientId: "", clientSecret: "")

    func searchBusinesses(lat: Double, lon: Double) {
        print("Querying Yelp for restaurants near \(lat),\(lon)")
        yelpAPIClient.searchBusinesses(byTerm: nil,
                                       location: nil,
                                       latitude: lat,
                                       longitude: lon,
                                       radius: 4000,
                                       categories: [.restaurants, .food, .fastFood],
                                       locale: nil,
                                       limit: 50,
                                       offset: nil,
                                       sortBy: nil,
                                       priceTiers: nil,
                                       openNow: true,
                                       openAt: nil,
                                       attributes: nil)
        { (response) in
            if response?.businesses?.count == 0 {
                print("No restaurants found!")
            }
            else {
                print("\(response!.total!) businesses found!")
                self.delegate?.receievedData(data: response!.businesses!)
            }
        }
    }
}
