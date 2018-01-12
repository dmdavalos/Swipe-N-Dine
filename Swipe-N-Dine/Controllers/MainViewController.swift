//
//  ViewController.swift
//  Swipe-N-Dine
//
//  Created by Daniel Davalos on 12/30/17.
//  Copyright © 2017 Daniel Davalos. All rights reserved.
//

import UIKit
import CoreLocation
import Koloda
import SVProgressHUD
import MapKit
import CDYelpFusionKit

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
    
    let dataModel = DataModel()
    var restaurants: [CDYelpBusiness] = []
    var shortList: [CDYelpBusiness] = []
    var location: Location = Location()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeNavBar()
        
        SVProgressHUD.show(withStatus: "Getting nearest restaurants...")
        
        dataModel.delegate = self
        location.delegate = self
        
        map.userTrackingMode = .follow
        
        cardView.delegate = self
        cardView.dataSource = self
        cardView.layer.cornerRadius = 10
        cardView.isHidden = true
        
    }
}

// Location delegate methods
extension MainViewController: LocationDelegate {
    func didReceiveLocation(lat: Double, lon: Double) {
        dataModel.searchBusinesses(lat: lat, lon: lon)
    }
    
    func didReceiveError(error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
}

// Navigation Bar configuration
extension MainViewController {
    func initializeNavBar() {
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

// Custom DataModel delegate methods
extension MainViewController: DataModelDelegate {
    func receievedData(data: [CDYelpBusiness]) {
        UIView.animate(withDuration: 1) {
            self.mapOverlay.alpha = 0.65
            self.cardView.isHidden = false
            self.skipButton.alpha = 1
            self.likeButton.alpha = 1
            self.undoButton.alpha = 1
        }
        restaurants = data
        cardView.reloadData()
        SVProgressHUD.dismiss()
    }
}

// Koloda delegate methods
extension MainViewController: KolodaViewDelegate, KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = Bundle.main.loadNibNamed("CardView", owner: self, options: nil)![0] as! CardView

        view.nameLabel.text = restaurants[index].name
        
        view.image.imageFromServerURL(urlString: restaurants[index].imageUrl!.absoluteString)
        
        if restaurants[index].location?.displayAddress?.count == 2 {
            view.addressLabel.text = "\(restaurants[index].location!.displayAddress![0]), \(restaurants[index].location!.displayAddress![1])"
        }
        else {
            view.addressLabel.text = ""
        }
        
        if let typeExists = restaurants[index].categories {
            view.typeLabel.text = typeExists[0].title
        }
        else {
            view.typeLabel.text = ""
        }
        if let distanceExists = restaurants[index].distance {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            let inMiles = formatter.string(from: distanceExists/1609.344 as NSNumber)! // Convert from meters to miles
            
            view.distanceLabel.text = "\(inMiles) mi"
        }
        else {
            view.distanceLabel.text = ""
        }
        
        print("Rating: \(restaurants[index].rating!)")
        if let ratingExists = restaurants[index].rating {
            switch ratingExists {
            case 5:
                view.yelpRating.image = UIImage.yelpStars(numberOfStars: .five, forSize: .large)
            case 4.5:
                view.yelpRating.image = UIImage.yelpStars(numberOfStars: .fourHalf, forSize: .large)
            case 4:
                view.yelpRating.image = UIImage.yelpStars(numberOfStars: .four, forSize: .large)
            case 3.5:
                view.yelpRating.image = UIImage.yelpStars(numberOfStars: .threeHalf, forSize: .large)
            case 3:
                view.yelpRating.image = UIImage.yelpStars(numberOfStars: .three, forSize: .large)
            case 2.5:
                view.yelpRating.image = UIImage.yelpStars(numberOfStars: .twoHalf, forSize: .large)
            case 2:
                view.yelpRating.image = UIImage.yelpStars(numberOfStars: .two, forSize: .large)
            case 1.5:
                view.yelpRating.image = UIImage.yelpStars(numberOfStars: .oneHalf, forSize: .large)
            case 1:
                view.yelpRating.image = UIImage.yelpStars(numberOfStars: .one, forSize: .large)
            default:
                view.yelpRating.image = UIImage.yelpStars(numberOfStars: .zero, forSize: .large)
            }
        }
        
        return view
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let actionSheet = UIAlertController(title: restaurants[index].name, message: "Select an option:", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
            print("Calling business...")
            let url = URL(string: "tel:\(self.restaurants[index].phone!)")
            print(url!)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Directions", style: .default, handler: { (action) in
            print("Getting directions...")
            let addr = "\(self.restaurants[index].location!.displayAddress![0]), \(self.restaurants[index].location!.displayAddress![1])".replacingOccurrences(of: " ", with: "+")
            let url = URL(string: "http://maps.apple.com/?daddr=\(addr)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "View on Yelp", style: .default, handler: { (action) in
            print("Opening in Yelp...")
            if let url = self.restaurants[index].url {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }

        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        if direction == .right {
            if self.shortList.contains(where: { (business) -> Bool in
                if business.id == restaurants[index].id {
                    return true
                }
                else {
                    return false
                }}) {
                print("Resaurant found. Skipping.")
            }
            else {
                print("Adding to shortlist.")
                self.shortList.append(restaurants[index])
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

                let newItem = Favorites(context: context)
                newItem.id = restaurants[index].id
                newItem.name = restaurants[index].name
                newItem.address1 = restaurants[index].location?.displayAddress![0]
                newItem.address2 = restaurants[index].location?.displayAddress![1]
                newItem.imageUrl = restaurants[index].imageUrl?.absoluteString
                newItem.phone = restaurants[index].phone
                newItem.price = restaurants[index].price
                newItem.rating = restaurants[index].rating!
                newItem.url = restaurants[index].url?.absoluteString
                
                do {
                    try context.save()
                } catch {
                    print("Error saving restaurant! \(error)")
                }
            }
        }
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        cardView.resetCurrentCardIndex()
        SVProgressHUD.showInfo(withStatus: "Out of cards! Starting over.")
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return restaurants.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return DragSpeed.default
    }
}
