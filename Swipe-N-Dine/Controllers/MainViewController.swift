//
//  ViewController.swift
//  Swipe-N-Dine
//
//  Created by Daniel Davalos on 12/30/17.
//  Copyright © 2017 Daniel Davalos. All rights reserved.
//

import UIKit
import Koloda
import SVProgressHUD
import MapKit
import SwiftyJSON

class MainViewController: UIViewController {
    @IBAction func likePressed(_ sender: Any) {
        cardView?.swipe(.right)
    }
    @IBAction func skipPressed(_ sender: Any) {
        cardView?.swipe(.left)
    }
    @IBAction func undoPressed(_ sender: Any) {
        cardView?.revertAction()
    }
    
    @IBOutlet var skipButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var undoButton: UIButton!
    @IBOutlet var map: MKMapView!
    @IBOutlet var cardView: KolodaView!
    @IBOutlet var mapOverlay: UIImageView!
    
    var restaurants: JSON = []
    var location: Location = Location()
    var yelpFetcher = YelpAPIFetcher()
    var saveData = SaveData()
    var favoritesList: [Favorites] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeNavBar()
        
        SVProgressHUD.show(withStatus: "Getting nearest restaurants...")
        
        location.delegate = self
        
        map.userTrackingMode = .follow
        
        cardView.delegate = self
        cardView.dataSource = self
        cardView.layer.cornerRadius = 10
        cardView.isHidden = true
        
        yelpFetcher.delegate = self
        
        saveData.loadData()
    }
}

// Location delegate methods
extension MainViewController: LocationDelegate {
    func locationNotAuthorized() {
        SVProgressHUD.showError(withStatus: "Location not authorized! Please check your settings app!")
        UIView.animate(withDuration: 1) {
            self.mapOverlay.alpha = 0.65
        }
    }
    
    func didReceiveLocation(lat: Double, lon: Double) {
        yelpFetcher.getRestaurants(lat: lat, lon: lon)
    }
    
    func didReceiveError(error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
}

// Navigation Bar configuration
extension MainViewController {
    func initializeNavBar() {
        UIApplication.shared.statusBarStyle = .lightContent
        
        let heartImage = UIImage(named: "heart")
        let favoritesButton = UIBarButtonItem(image: heartImage, style: .plain, target: self, action: #selector(favoritesButtonPressed))
        self.navigationController?.navigationBar.topItem?.setRightBarButton(favoritesButton, animated: true)
        
        let refreshImage = UIImage(named: "syncronize")
        let refreshButton = UIBarButtonItem(image: refreshImage, style: .plain, target: self, action: #selector(refreshButtonPressed))
        self.navigationController?.navigationBar.topItem?.setLeftBarButton(refreshButton, animated: true)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white]
    }
    
    @objc func favoritesButtonPressed() {
        self.performSegue(withIdentifier: "toFavorites", sender: self)
    }
    
    @objc func refreshButtonPressed() {
        location.getLocation()
        SVProgressHUD.show(withStatus: "Refreshing...")
    }
}

// Custom YelpFetcher delegate methods
extension MainViewController: YelpFetcherDelegate {
    func didReceiveRestaurants(result: JSON) {
        restaurants = result
        UIView.animate(withDuration: 1) {
            self.mapOverlay.alpha = 0.65
            self.cardView.isHidden = false
            self.skipButton.alpha = 1
            self.likeButton.alpha = 1
            self.undoButton.alpha = 1
        }
        cardView.reloadData()
        SVProgressHUD.dismiss()
    }
}

// Koloda delegate methods
extension MainViewController: KolodaViewDelegate, KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = Bundle.main.loadNibNamed("CardView", owner: self, options: nil)![0] as! CardView

        view.nameLabel.text = restaurants["businesses"][index]["name"].stringValue
        
        view.image.imageFromServerURL(urlString: restaurants["businesses"][index]["image_url"].stringValue)
        
        if restaurants["businesses"][index]["location"]["display_address"].isEmpty {
            view.addressLabel.text = ""
        }
        else {
            view.addressLabel.text = "\(restaurants["businesses"][index]["location"]["display_address"][0].stringValue), \(restaurants["businesses"][index]["location"]["display_address"][1].stringValue)"
        }

        if restaurants["businesses"][index]["categories"][0].isEmpty {
            view.typeLabel.text = ""
        }
        else {
            view.typeLabel.text = restaurants["businesses"][index]["categories"][0]["title"].stringValue
        }
        
        if restaurants["businesses"][index]["distance"] == 0 {
            view.distanceLabel.text = ""
        }
        else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            let inMiles = formatter.string(from: restaurants["businesses"][index]["distance"].doubleValue/1609.344 as NSNumber)! // Convert from meters to miles
            
            view.distanceLabel.text = "\(inMiles) mi"
        }

        if let ratingExists = restaurants["businesses"][index]["rating"].double {
            switch ratingExists {
            case 5:
                view.yelpRating.image = UIImage(named: "yelp_stars_five_large")
            case 4.5:
                view.yelpRating.image = UIImage(named: "yelp_stars_four_half_large")
            case 4:
                view.yelpRating.image = UIImage(named: "yelp_stars_four_large")
            case 3.5:
                view.yelpRating.image = UIImage(named: "yelp_stars_three_half_large")
            case 3:
                view.yelpRating.image = UIImage(named: "yelp_stars_three_large")
            case 2.5:
                view.yelpRating.image = UIImage(named: "yelp_stars_two_half_large")
            case 2:
                view.yelpRating.image = UIImage(named: "yelp_stars_two_large")
            case 1.5:
                view.yelpRating.image = UIImage(named: "yelp_stars_one_half_large")
            case 1:
                view.yelpRating.image = UIImage(named: "yelp_stars_one_large")
            default:
                view.yelpRating.image = UIImage(named: "yelp_stars_zero_large")
            }
        }
        
        return view
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let actionSheet = UIAlertController(title: restaurants["businesses"][index]["name"].stringValue, message: "Select an option:", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
            print("Calling business...")
            let url = URL(string: "tel:\(self.restaurants["business"][index]["phone"])")
            print(url!)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Directions", style: .default, handler: { (action) in
            print("Getting directions...")
            let addr = ("\(self.restaurants["businesses"][index]["location"]["display_address"][0].stringValue), \(self.restaurants["businesses"][index]["location"]["display_address"][1].stringValue)").replacingOccurrences(of: " ", with: "+")
            let url = URL(string: "http://maps.apple.com/?daddr=\(addr)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "View on Yelp", style: .default, handler: { (action) in
            print("Opening in Yelp...")
            if let url = self.restaurants["businesses"][index]["url"].url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .right {
            if favoritesList.contains(where: { (item) -> Bool in
                if item.id == restaurants["businesses"][index]["name"].stringValue {
                    return true
                } else {
                    return false
                }
            }) {
                print("Item found in SaveData! Skipping...")
            } else {
                print("Adding item to SaveData...")
                let newItem = Favorites(context: saveData.context)
                newItem.id = restaurants["businesses"][index]["id"].stringValue
                newItem.name = restaurants["businesses"][index]["name"].stringValue
                newItem.address1 = restaurants["businesses"][index]["location"]["display_address"][0].stringValue
                newItem.address2 = restaurants["businesses"][index]["location"]["display_address"][1].stringValue
                newItem.imageUrl = restaurants["businesses"][index]["image_url"].stringValue
                newItem.phone = restaurants["businesses"][index]["phone"].stringValue
                newItem.rating = restaurants["businesses"][index]["rating"].doubleValue
                newItem.url = restaurants["businesses"][index]["location"]["url"].stringValue
                saveData.saveData()
            }
        }
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        cardView.resetCurrentCardIndex()
        SVProgressHUD.showInfo(withStatus: "Out of cards! Starting over.")
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return restaurants["businesses"].count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return DragSpeed.default
    }
}

extension MainViewController: SaveDataDelegate {
    func didLoadData(data: [Favorites]) {
        favoritesList = data
    }
    
    func didReceieveError(error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
}
