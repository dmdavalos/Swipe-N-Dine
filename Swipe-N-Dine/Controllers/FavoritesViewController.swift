//
//  FavoritesViewController.swift
//  
//
//  Created by Daniel Davalos on 1/6/18.
//

import UIKit
import CoreData
import SVProgressHUD

class FavoritesViewController: UITableViewController {

    // Variables
    var favoritesList: [Favorites] = []
    let saveData = SaveData()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        saveData.delegate = self
        saveData.loadData()
    }
}

// MARK: Custom SaveData delegate methods
extension FavoritesViewController: SaveDataDelegate {
    func didLoadData(data: [Favorites]) {
        favoritesList = data
    }
    
    func didReceieveError(error: Error) {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
}

// MARK: Table view delegate methods. Most of the setup was done via the Storyboard.
extension FavoritesViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.text = "\(favoritesList[indexPath.row].name!), \(favoritesList[indexPath.row].address1!), \(favoritesList[indexPath.row].address2!)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            saveData.context.delete(favoritesList[indexPath.row])
            favoritesList.remove(at: indexPath.row)
            saveData.saveData()
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let actionSheet = UIAlertController(title: favoritesList[indexPath.row].name, message: "Select an option:", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Call", style: .default, handler: { (action) in
            print("Calling business...")
            let url = URL(string: "tel:\(self.favoritesList[indexPath.row].phone!)")
            print(url!)
            UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Directions", style: .default, handler: { (action) in
            print("Getting directions...")
            let addr = "\(self.favoritesList[indexPath.row].address1!), \(self.favoritesList[indexPath.row].address2!)".replacingOccurrences(of: " ", with: "+")
            let url = URL(string: "http://maps.apple.com/?daddr=\(addr)")
            UIApplication.shared.open(url!, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "View on Yelp", style: .default, handler: { (action) in
            print("Opening in Yelp...")
            if let url = URL(string: self.favoritesList[indexPath.row].url!) {
                UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
            
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(actionSheet, animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
