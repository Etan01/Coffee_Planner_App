//
//  HomeViewController.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 15/5/2023.
//

import UIKit
import MapKit

class HomeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate,UITableViewDataSource, UITableViewDelegate {
    
    // MARK: variables for api venue
    var venues: [Venue] = []
    
    // MARK: variables for location
    weak var locationDelegate: EditExpenseDelegate?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var annotations: [MKAnnotation] = []
    
    var location: Location?
        
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: Set the theme mode from User Default
        guard let windowScene = UIApplication.shared.connectedScenes.first(where: {$0.activationState == .foregroundActive}) as? UIWindowScene else {
                return
            }

        guard let window = windowScene.windows.first else{
            return
        }
        
        let savedThemeMode = UserDefaults.standard.string(forKey: themeModeKey)
        if savedThemeMode == "Dark" {
            // Apply dark theme
            window.overrideUserInterfaceStyle = .dark
        } else {
            // Apply light theme
            window.overrideUserInterfaceStyle = .light
        }
        
        // MARK: Set delegate and datasource to mapview and tableview
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        
        // Define the settings into locationManager
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        
        // Do any additional setup after loading the view.
        let authorisationStatus = locationManager.authorizationStatus
        if authorisationStatus != .authorizedWhenInUse{
            if authorisationStatus == .notDetermined{
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        //Zoom to user location
        if let userLocation = mapView.userLocation.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
        
        mapView.showsUserLocation = true
        
        // Sync Function to update the locationManager
        DispatchQueue.main.async { [self] in
            self.locationManager.startUpdatingLocation()
        }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        currentLocation = locations.last!.coordinate
        
        self.location = Location(name: "", latitude: currentLocation!.latitude, longitude: currentLocation!.longitude)
        
        // MARK: retrieve venues after current location is updated
        Task{
            do{
                venues = try await retrieveVenues(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude, category: "cafe", limit: 2, sortBy: "distance", locale: "en_AU")
                self.tableView.reloadData()
            } catch{
                print("Error: \(error)")
            }
        }
        
        UserSession.shared.currentLocation = currentLocation    //save user location to usersession

    }
    
    // set the mapview into current user's location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    //Configure the table view cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! NearbyTableViewCell
        
        let venue = venues[indexPath.row]
        cell.locationName.text = venue.name
        cell.locationRating.text = "\(venue.rating ?? 0.0)/5⭐️"
        
        
        // download the image url from online
        if let cover = venue.imageURL{
            let url = URL(string: cover)
            if url != nil{
                var comps = URLComponents(url: url!, resolvingAgainstBaseURL: false)
                comps?.scheme = "https"
                let data = try? Data(contentsOf: (comps?.url)!)
                cell.locationImage.image = UIImage(data: data!)
            } else{
                // if image not available, replace with image_not_available
                cell.locationImage.image = UIImage(named: "image_not_available")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    func retrieveVenues(latitude: Double, longitude: Double, category: String, limit: Int, sortBy: String,locale: String) async throws -> [Venue]{
        /**
         Retrieve venues using the parameters such as latitude, longitude and etc
         */
        
        let baseURL =
            "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&categories=\(category)&limit=\(limit)&sort_by=\(sortBy)&locale=\(locale)"
        
        let url = URL(string: baseURL)
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let resp = json as! NSDictionary?,
              let businesses = resp.value(forKey: "businesses") as? [NSDictionary] else {
            throw NSError(domain: "Parsing Error", code: 0, userInfo: nil)
        }
        
                
        var venueList : [Venue] = []
            
        for business in businesses {
            var venue = Venue()
            venue.name = business.value(forKey: "name") as? String
            venue.id = business.value(forKey: "id") as? String
            venue.rating = business.value(forKey: "rating") as? Float
            venue.price = business.value(forKey: "price") as? String
            venue.is_closed = business.value(forKey: "is_closed") as? Bool
            venue.distance = business.value(forKey: "distance") as? Double
            venue.imageURL = business.value(forKey: "image_url") as? String
            let address = business.value(forKeyPath: "location.display_address") as? [String]
            venue.address = address?.joined(separator: "\n")
            
            let latitude = business.value(forKeyPath: "coordinates.latitude") as? Double
            let longitude = business.value(forKeyPath: "coordinates.longitude") as? Double
            venue.latitude = latitude
            venue.longitude = longitude
            
            venueList.append(venue)
            
        }
        return venueList
    }

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "viewMoreSegue"{
            let destination = segue.destination as? ViewMoreCafeTableViewController
            destination?.location = self.location
        } else if segue.identifier == "nearbyShowLocationSegue"{
            // Pass the selected venue into LocationViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                let destination = segue.destination as! LocationViewController
                let venue = venues[indexPath.row]
                destination.currentLocation = self.location
                destination.selectedVenue = venue
            }
        }
    }
    

}
