//
//  SavedData.swift
//  Swipe-N-Dine
//
//  Created by Daniel Davalos on 1/12/18.
//  Copyright © 2018 Daniel Davalos. All rights reserved.
//

import UIKit
import CoreData

protocol SaveDataDelegate {
    func didLoadData(data: [Favorites])
    func didReceieveError(error: Error)
}

class SaveData {
    
    public let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var delegate: SaveDataDelegate?
    
    public func loadData() {
        let request: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        do {
            let saveDataArray = try context.fetch(request)
            delegate?.didLoadData(data: saveDataArray)
        } catch {
            print("Error loading data! \(error)")
            delegate?.didReceieveError(error: error)
        }
    }
    
    public func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving data! \(error)")
            delegate?.didReceieveError(error: error)
        }
    }
}
