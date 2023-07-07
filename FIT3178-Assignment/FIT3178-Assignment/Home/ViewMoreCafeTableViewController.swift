//
//  viewMoreCafeTableViewController.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 30/5/2023.
//

import UIKit

class ViewMoreCafeTableViewController: UITableViewController {
    
    @IBOutlet weak var sortToggle: UIBarButtonItem!
    
    // MARK: PROPERTIES
    var venues: [Venue] = []
    var location: Location?
    var selectedVenue: Venue?
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        // check if location is nil
        guard let location = location else{
            return
        }
        
        // start to retrive venues and update tableview
        Task{
            do{
                venues = try await APICallHelper().retrieveVenues(latitude: location.latitude!, longitude: location.longitude!, category: "cafe", limit: 8, sortBy: "distance", locale: "en_AU")
                self.tableView.reloadData()
            } catch{
                print("Error: \(error)")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return venues.count
    }
    
//    func retrieveVenues(latitude: Double, longitude: Double, category: String, limit: Int, sortBy: String,locale: String) async throws -> [Venue]{
//        /**
//         Retrieve venues using the parameters such as latitude, longitude and etc
//         */
//
//        let baseURL =
//            "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&categories=\(category)&limit=\(limit)&sort_by=\(sortBy)&locale=\(locale)"
//
//        let url = URL(string: baseURL)
//        var request = URLRequest(url: url!)
//        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
//        request.httpMethod = "GET"
//
//        let (data, _) = try await URLSession.shared.data(for: request)
//        let json = try JSONSerialization.jsonObject(with: data, options: [])
//        guard let resp = json as! NSDictionary?,
//              let businesses = resp.value(forKey: "businesses") as? [NSDictionary] else {
//            throw NSError(domain: "Parsing Error", code: 0, userInfo: nil)
//        }
//
//        var venueList : [Venue] = []
//
//        for business in businesses {
//            var venue = Venue()
//            venue.name = business.value(forKey: "name") as? String
//            venue.id = business.value(forKey: "id") as? String
//            venue.rating = business.value(forKey: "rating") as? Float
//            venue.price = business.value(forKey: "price") as? String
//            venue.is_closed = business.value(forKey: "is_closed") as? Bool
//            venue.distance = business.value(forKey: "distance") as? Double
//            venue.imageURL = business.value(forKey: "image_url") as? String
//            let address = business.value(forKeyPath: "location.display_address") as? [String]
//            venue.address = address?.joined(separator: "\n")
//
//
//
//            venueList.append(venue)
//
//        }
//        return venueList
//    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! NearbyTableViewCell
        
        let venue = venues[indexPath.row]
        cell.locationName.text = venue.name
        cell.locationRating.text = "\(venue.rating ?? 0.0)/5⭐️"
        
        if let cover = venue.imageURL{
            let url = URL(string: cover)
            if url != nil{
                var comps = URLComponents(url: url!, resolvingAgainstBaseURL: false)
                comps?.scheme = "https"
                let data = try? Data(contentsOf: (comps?.url)!)
                cell.locationImage.image = UIImage(data: data!)
            } else{
                cell.locationImage.image = UIImage(named: "image_not_available")
            }
        }
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
    
    @IBAction func sortBy(_ sender: Any) {
        venues.sort{$0.rating! > $1.rating!}
                
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedVenue = venues[indexPath.row]
        self.performSegue(withIdentifier: "viewMoreLocationSegue", sender: self)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewMoreLocationSegue"{
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! LocationViewController
                let venue = venues[indexPath.row]
                destination.selectedVenue = venue
                destination.currentLocation = location
            }
        }
    }
    

}
