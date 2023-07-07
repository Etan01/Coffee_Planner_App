//
//  LocationViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 14/05/2023.
// Reference:
// 1.Draw route and direction on Mapkit
//  https://www.youtube.com/watch?v=vEN5WzsAoxA
//

import UIKit
import MapKit

class customPin: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}


struct Reviews{
    // structure for reviews
    var url: String?
    var text: String?
    var rating: Float?
    var name: String?
}

class LocationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var addToWishlistButton: UIBarButtonItem!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var workingLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: empty variables for storing
    var currentLocation: Location?
    var venues: [Venue] = []
    var selectedVenue: Venue?
    var reviews: [Reviews] = []
    var twoReview: [Reviews] = []
        
    // MARK: empty variable to store the value from API
    var venueName: String?
    var rating: Float?
    var distance: Double?
    var isClosed: Bool?
    var id: String?
    var imageURL: String?
    var isInWishlist = false
    var destinationLocation: CLLocationCoordinate2D?

    weak var databaseController: DatabaseProtocol?
    weak var coredataController: CoreDataProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        coredataController = appDelegate?.coredataController

        
        // Do any additional setup after loading the view.
        guard let currentLocation = currentLocation else{
            return
        }

        Task{
            do{
                if selectedVenue == nil{
                    let venues = try await APICallHelper().retrieveVenues(latitude: currentLocation.latitude!, longitude: currentLocation.longitude!, category: "cafes", limit: 10,  sortBy: "distance", locale: "en_AU")
                    print(venues)
                    
                    selectedVenue = venues.first
                }
                
                id = selectedVenue?.id
                venueName = selectedVenue?.name
                topicLabel.text = venueName
                rating = selectedVenue?.rating
                ratingLabel.text = "\(rating ?? 0.0)/5⭐️"
                imageURL = selectedVenue?.imageURL
                
                // MARK: first time set isInWishlist to false
                if selectedVenue?.isInWishlist == nil{
                    selectedVenue?.isInWishlist = false
                    saveToUserDefaults(venue: selectedVenue!, status: false)
                }

                
                // MARK: Set the working label
                isClosed = selectedVenue?.is_closed
                if !isClosed! {
                    workingLabel.text = "Opened"
                    workingLabel.textColor = .systemGreen
                } else{
                    workingLabel.text = "Closed"
                    workingLabel.textColor = .systemRed
                }
                
                
                // Check if latitude and longitude is nil
                guard let latitude = currentLocation.latitude, let longitude = currentLocation.longitude else {
                    return
                }
                                
                // MARK: Update mapview according to the coordinate
                let realUserLocation = UserSession.shared.currentLocation
                let realLatitude = realUserLocation?.latitude
                let realLongitude = realUserLocation?.longitude
                
                let sourceLocation = CLLocationCoordinate2D(latitude: realLatitude!, longitude: realLongitude!)
                
                destinationLocation = CLLocationCoordinate2D(latitude: (selectedVenue?.latitude)!, longitude: (selectedVenue?.longitude)!)
                
                let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                let region = MKCoordinateRegion(center: sourceLocation, span: span)
                
                // MARK: Add annotation to source and destination
                let sourcePin = customPin(coordinate: sourceLocation, title: "You", subtitle: "")
                let destinationPin = customPin(coordinate: destinationLocation!, title: selectedVenue?.name, subtitle: "")
                
                self.mapView.addAnnotation(sourcePin)
                self.mapView.addAnnotation(destinationPin)
                
                let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation)
                let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation!)
                
                let directionRequest = MKDirections.Request()
                directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
                directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
                directionRequest.transportType = .automobile
                
                let directions = MKDirections(request: directionRequest)
                directions.calculate{ [self] (response, error) in
                    guard let directionResponse = response else {
                        if let error = error {
                            print("Error occurs in directions \(error.localizedDescription)")
                        }
                        return
                    }
                    
                    let route = directionResponse.routes[0]
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                    self.distance = route.distance
                    
                    // MARK: Convert distance to 2 decimal digit
                    if let distance = Double(self.distance!.description){
                        let roundedDistance = distance.rounded()
                        let numberFormatter = NumberFormatter()
                        numberFormatter.numberStyle = .decimal
                        numberFormatter.maximumFractionDigits = 2
                        
                        if let formattedDistance = numberFormatter.string(from: NSNumber(value: roundedDistance)) {
                            self.distanceLabel.text = "\(formattedDistance)m"
                        }
                    }
                    
                    let rec = route.polyline.boundingMapRect
//                    self.mapView.setRegion(MKCoordinateRegion(rec), animated: true)
                    self.mapView.setRegion(region, animated: true)
                }
                
                self.mapView.delegate = self
                
                
                // MARK: retrieve review list
                Task{
                    do{
                        self.reviews = try await APICallHelper().retrieveReview(id: self.id!)
                        self.twoReview = Array(self.reviews.prefix(2))
                        self.tableView.reloadData()
                        
                    }catch{
                        print("Error: \(error)")
                    }
                }
                
                retrieveWishlistStatus(venue: self.selectedVenue!)
                updateWishlistButton()
                
            } catch{
                print("Error: \(error)")
            }
        }
    }
    
    /// Add route line to the road on mapkit
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer{
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return twoReview.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as! ReviewTableViewCell
        
        let review = twoReview[indexPath.row]
        cell.ratingLabel.text = "\(review.rating ?? 0.0)/5⭐️"
        cell.commentLabel.text = review.text        
        if review.name == nil{
            cell.userName.text = "User"
        } else {
            cell.userName.text = review.name
        }
        
        return cell
    }
    
    /// Update the color of star button based on the status
    func updateWishlistButton(){
        if self.selectedVenue?.isInWishlist == true{
            addToWishlistButton.tintColor = .systemYellow
            addToWishlistButton.customView?.backgroundColor = .systemYellow
        } else{
            addToWishlistButton.tintColor = .systemGray
        }
    }
    
    /// Save the status of venue into user defaults
    func saveToUserDefaults(venue: Venue, status: Bool){
        /**
         - Parameters:
            - venue: the selected venue from controller: Venue
            - status: Boolean
         */
        self.selectedVenue?.isInWishlist = status
        let currentStatus = UserDefaults.standard.set(status, forKey: venue.id!)
        print(currentStatus)
    }
    
    /// Check the status of the venue from user defaults
    func retrieveWishlistStatus(venue: Venue){
        self.selectedVenue?.isInWishlist = UserDefaults.standard.bool(forKey: venue.id!)
    }
    
    
    ///Save the current venue into the list of wishlist as well as the core data persistent storage
    @IBAction func saveIntoWishlist(_ sender: Any) {
        
        let isWorking = !isClosed!
        if self.selectedVenue?.isInWishlist == false{
            
            // if the venue is not in wishlist, add into Core Data and save the status
            let _ = coredataController?.addToWishlist(id: id!, name: venueName!, distance: distance!, isWorking: isWorking, ratings: rating!, imageUrl: imageURL!, latitude: (currentLocation?.latitude)!, longitude: (currentLocation?.longitude)!)
            saveToUserDefaults(venue: self.selectedVenue!, status: true)

        } else{
            // Remove it from coredata and save the status of wishlist
            let id = (self.selectedVenue?.id)!
            guard let wishlist = coredataController?.fetchWishlist(withId: id) else{
                return
            }
            let _ = coredataController?.removeFromWishlist(wishlist: wishlist)
            saveToUserDefaults(venue: self.selectedVenue!, status: false)
        }
        
        // MARK: Code for saving into coredata
        updateWishlistButton()
       
        
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "seeMoreSegue"{
            let destination = segue.destination as? AllReviewsTableViewController
            destination?.reviews = self.reviews
        }
        
        if segue.identifier == "showPathSegue"{
            let destination = segue.destination as? ShowPathViewController
            destination?.destinationLocation = self.destinationLocation
            destination?.locationTitle = self.selectedVenue?.name
        }
        
        
    }
    

}
