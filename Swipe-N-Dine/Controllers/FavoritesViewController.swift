//
//  FavoritesViewController.swift
//  
//
//  Created by Daniel Davalos on 1/6/18.
//

import UIKit
import CoreData

class FavoritesViewController: UITableViewController {

    // Constants
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // Variables
    var favoritesArray: [Favorites] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        loadData()
    }
    
    func loadData() {
        let request: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        do {
            favoritesArray = try context.fetch(request)
            print("Found \(favoritesArray.count) items.")
        } catch {
            print("Error loading data! \(error)")
        }
        tableView.reloadData()
    }
    
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving data! \(error)")
        }
        tableView.reloadData()
    }
}

// MARK: Table view delegate methods. Most of the setup was done via the Storyboard.
extension FavoritesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = "\(favoritesArray[indexPath.row].name!), \(favoritesArray[indexPath.row].address1!), \(favoritesArray[indexPath.row].address2!)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(favoritesArray[indexPath.row])
            favoritesArray.remove(at: indexPath.row)
            saveData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: favoritesArray[indexPath.row].name, message: "Select an option:", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
            print("Calling business...")
            let url = URL(string: "tel:\(self.favoritesArray[indexPath.row].phone!)")
            print(url!)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Directions", style: .default, handler: { (action) in
            print("Getting directions...")
            let addr = "\(self.favoritesArray[indexPath.row].address1!), \(self.favoritesArray[indexPath.row].address2!)".replacingOccurrences(of: " ", with: "+")
            let url = URL(string: "http://maps.apple.com/?daddr=\(addr)")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "View on Yelp", style: .default, handler: { (action) in
            print("Opening in Yelp...")
            if let url = URL(string: self.favoritesArray[indexPath.row].url!) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
}
