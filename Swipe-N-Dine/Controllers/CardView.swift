//
//  CustomOverlayView.swift
//  Swipe-N-Dine
//
//  Created by Daniel Davalos on 1/5/18.
//  Copyright © 2018 Daniel Davalos. All rights reserved.
//

import Foundation
import Koloda

class CardView: UIView {
    

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var image: UIImageView!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var topLabel: UIView!
    @IBOutlet var yelpRating: UIImageView!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        image.layer.cornerRadius = 10
        topLabel.layer.cornerRadius = 10
        
        nameLabel.textColor = UIColor.white
        addressLabel.textColor = UIColor.white
        typeLabel.textColor = UIColor.white
        distanceLabel.textColor = UIColor.white
    }
    
}
