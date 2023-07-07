//
//  SearchTableViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 01/05/2023.
//  Reference:
//  - https://developer.apple.com/documentation/mapkit/mklocalsearch
//

import UIKit
import MapKit

enum EpisodeListError: Error {
    case invalidServerResponse
    case invalidShowURL
    case invalidEpisodeImageURL
}

class SearchTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    
    let CELL_COFFEE = "cafesCell"
    let REQUEST_STRING_ICED = "https://api.sampleapis.com/coffee/iced"
    
    // MARK: store coffee information from API
    var newCoffee = [CoffeeData]()
    
    // MARK: store location from MKLocalSearch
    var newplace: [String] = []
    
    // MARK: filter items for searching purposes
    var filteredItems: [CoffeeData] = []
    
    var currentScopeIndex = 0
    
    // MARK: Any type for storing different type of list, ie. CoffeeData/Location
    var searchList: [Any] = []

    var selectedCoffee: CoffeeData?
    var indicator = UIActivityIndicatorView()
    weak var databaseController: DatabaseProtocol?
    
    let MAX_ITEMS_PER_REQUEST = 40
    let MAX_REQUESTS = 10
    var currentRequestIndex: Int = 0
    
    var selectedRow = Set<Int>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
        databaseController = appDelegate?.databaseController
        
        // MARK: Configure Search Controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All"
        searchController.searchBar.scopeButtonTitles = ["Drink", "Location"]
        searchController.searchBar.showsScopeBar = true
        navigationItem.searchController = searchController
        
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        loadDataforIced()
        
        filteredItems = newCoffee
    }
    
    /// Call API to retrieve coffee information
    func loadDataforIced(){
        Task{
            do{
                guard let requestURL = URL(string: REQUEST_STRING_ICED) else{
                    throw EpisodeListError.invalidShowURL
                }
                let (data, response) = try await URLSession.shared.data(from: requestURL)
                guard let httpResponse = response as? HTTPURLResponse,
                          httpResponse.statusCode == 200 else {
                    throw EpisodeListError.invalidServerResponse
                }
                
                let decoder = JSONDecoder()
                let showData = try decoder.decode([CoffeeData].self, from: data)
                newCoffee = showData
                searchList = newCoffee  //replace searchList with new coffee array

                tableView.reloadData()
                
                print("API call done")
            }
            catch {
                print(error)
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
//        return filteredItems.count
        return searchList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cafesCell", for: indexPath) as! SearchTableViewCell

        // Configure the cell...
        if !searchList.isEmpty && indexPath.row < searchList.count{
            if let coffeeList = searchList[indexPath.row] as? CoffeeData{
                let coffee = coffeeList //filteredItems[indexPath.row]
                cell.cafeLabel?.text = coffee.title
                
            }
            else if let location = searchList[indexPath.row] as? Location {
                print("Location \(location)")
                cell.cafeLabel.text = location.name
            }
        }
        
        return cell
    }
    

    /// Change segue when the scope index is changed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedCoffee = searchList[indexPath.row] as? CoffeeData
        if currentScopeIndex == 0{
            performSegue(withIdentifier: "showCoffee", sender: indexPath)
        } else {
            performSegue(withIdentifier: "showLocationSegue", sender: indexPath)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }

        if searchController.searchBar.selectedScopeButtonIndex == 0{
            if searchText.count > 0 {
                searchList = newCoffee.filter({ (coffee: CoffeeData) -> Bool in
                    return (coffee.title?.lowercased().contains(searchText) ?? false)
                })
            } else {
                searchList = newCoffee
            }
        } else{
            let searchText = searchController.searchBar.text ?? ""
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            
            // Region Bias
            if let userLocation = UserSession.shared.currentLocation{
                request.region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 500, longitudinalMeters: 500)
                print("Region is set")
            }
            
            request.pointOfInterestFilter = MKPointOfInterestFilter(including: [.cafe])

            let search = MKLocalSearch(request: request)
            search.start { (response, error) in
                guard let response = response else { return }
                
                
                let locations = response.mapItems.map { (mapItem) -> Location? in
                    guard let coordinate = mapItem.placemark.location?.coordinate else {
                        return nil
                    }
                    
                    
                    var locationString = ""
                            
                    if let name = mapItem.name {
                        locationString += name
                    }

                    if let thoroughfare = mapItem.placemark.thoroughfare {
                        if !locationString.isEmpty {
                            locationString += ", "
                        }
                        locationString += thoroughfare
                    }
                    
                    let location = Location()
                    location.name = locationString
                    location.latitude = coordinate.latitude
                    location.longitude = coordinate.longitude
                        
                    return location
                    }
                
                self.searchList = locations
                self.tableView.reloadData()
            }
        }

        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        currentScopeIndex = selectedScope
        switch currentScopeIndex{
        case 0:
            self.searchList = newCoffee //replace newcoffee into searchlist
            self.tableView.reloadData()
            
        case 1:
            self.searchList = newplace // replace locations list into searchlist
            
            // MARK: Start Map Kit Location Search
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "coffee"
            request.pointOfInterestFilter?.includes(.cafe)
            request.naturalLanguageQuery = searchBar.text
            
            let search = MKLocalSearch(request: request)
            search.start { response, error in
                guard let response = response else { return }
                self.searchList = response.mapItems.map { $0.name ?? "Unknown" }
                self.tableView.reloadData()
            }
        default:
            break
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "showCoffee"{
            if let indexPath = sender as? IndexPath {
                
                // Check if searchlist is in coffeeData type
                if let _ = searchList[indexPath.row] as? CoffeeData{
                    let destination = segue.destination as! CoffeeViewController
                    destination.currentCoffee = searchList[indexPath.row] as? CoffeeData
                }
            }
        }
        
        else if segue.identifier == "showLocationSegue"{
            if let indexPath = sender as? IndexPath {
                
                // Check if searchlist is in Location type
                if let _ = searchList[indexPath.row] as? Location{
                    let destination = segue.destination as! LocationViewController
                    destination.currentLocation = searchList[indexPath.row] as? Location
                    
                }
            }
        }
    }
    
}
