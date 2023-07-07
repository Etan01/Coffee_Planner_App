//
//  WishlistTableViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 13/05/2023.
//

import UIKit

class WishlistTableViewController: UITableViewController, UISearchResultsUpdating, CoreDataListener {
    
    
    let SECTION_WISHLIST = 0
    let SECTION_INFO = 1
    
    let CELL_WISHLIST = "wishlistCell"
    let CELL_INFO = "totalCell"
    
    var allWishlists: [WishlistCoreData] = []
    var filteredWishlists: [WishlistCoreData] = []
    
//    var listenerType: CoreListenerType.wishlist
    weak var coredataController: CoreDataProtocol?
    
//    var listenerType = ListenerType.wishlist
//    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        coredataController = appDelegate?.coredataController
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All"
        navigationItem.searchController = searchController
                
        // This view controller decides how the search controller is presented
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        filteredWishlists = allWishlists
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coredataController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        coredataController?.removeListener(listener: self)
    }
    
    func onWishlistChange(wishlist: [WishlistCoreData]) {
        allWishlists = wishlist
        updateSearchResults(for: navigationItem.searchController!)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case SECTION_WISHLIST:
            return filteredWishlists.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }

    /// Display different information into cell based on the section
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_WISHLIST {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_WISHLIST, for: indexPath) as! WishlistTableViewCell
            
            let wishlist = filteredWishlists[indexPath.row]
            cell.name.text = wishlist.name
            cell.ratingLabel.text = "\(wishlist.ratings)/5⭐️"
                        
            if let cover = wishlist.imageURL{
                if let url = URL(string: cover){
                    var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
                    comps?.scheme = "https"
                    
                    let session = URLSession.shared
                    let task = session.dataTask(with: url){(data, response, error) in
                        if error != nil{
                            return
                        }
                        if let data = data{
                            if let image = UIImage(data: data){
                                DispatchQueue.main.async {
                                    cell.wishlistImage.image = image
                                    cell.setNeedsLayout()
                                }
                            }
                        }
                    }
                    task.resume()
                } else{
                    cell.wishlistImage.image = UIImage(named: "image_not_available")
                }
            }
            
            return cell
        }
        
        else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath)
                    
            infoCell.textLabel?.text = "\(filteredWishlists.count) places in the core database"
            
            return infoCell
        }
    }
    
    /// Long press tablecell to perform more actions
    override func tableView(_ tableView: UITableView,
                             contextMenuConfigurationForRowAt indexPath: IndexPath,
                            point: CGPoint) -> UIContextMenuConfiguration? {

        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { suggestedActions in

            let location = self.filteredWishlists[indexPath.row]

            guard let title = location.name else {
                return nil
            }
            
            var msg = ""
            if location.isWorking{
                msg = "Opened Now"
            } else{
                msg = "Closed"
            }

            let description = "\(title), Lat: \(location.location?.latitude), Long: \(location.location?.longitude), \(msg)"


            let shareAction =
            UIAction(title: "Share",
                     image: UIImage(systemName: "square.and.arrow.up")) { action in

                let activityViewCOntroller = UIActivityViewController(activityItems: [description], applicationActivities: nil)
                activityViewCOntroller.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)?.contentView


                activityViewCOntroller.excludedActivityTypes = [.message, .postToFacebook]

                self.present(activityViewCOntroller, animated: true)


            }

            let copyAction =
            UIAction(title: "Copy",
                     image: UIImage(systemName: "doc.on.doc")) { action in

                UIPasteboard.general.string = description
            }

            let deleteAction =
            UIAction(title: "Delete",
                     image: UIImage(systemName: "trash"),
                     attributes: .destructive) { action in

                if self.filteredWishlists.count > 0{
                    self.coredataController?.removeFromWishlist(wishlist: self.filteredWishlists[indexPath.row])
                    self.filteredWishlists.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }

            }

            return UIMenu(title: "", children: [shareAction, copyAction, deleteAction])
        })
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == SECTION_WISHLIST {
            return true
        }
        
        return false
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == SECTION_WISHLIST {
            let place = filteredWishlists[indexPath.row]
            coredataController?.removeFromWishlist(wishlist: place)
            tableView.reloadData()
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showWishlistDetail"{
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! LocationViewController
                
                // MARK: Pass relevant information to next view controller
                let location = filteredWishlists[indexPath.row]
                let currentLocation = Location(name: location.name, latitude: location.location?.latitude, longitude: location.location?.longitude)
                
                let venue = Venue(name: location.name, id: location.id, rating: location.ratings, is_closed: !location.isWorking, distance: location.distance, address: "", imageURL: location.imageURL, isInWishlist: true, latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                
                destination.selectedVenue = venue
                destination.currentLocation = currentLocation

            }
        }
    }
    
    /// Update search results when typing
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }

        if searchText.count > 0 {
            filteredWishlists = allWishlists.filter({ (wishlist: WishlistCoreData) -> Bool in
                return (wishlist.name?.lowercased().contains(searchText) ?? false)
            })
        } else {
            filteredWishlists = allWishlists
        }

        tableView.reloadData()
    }

}
