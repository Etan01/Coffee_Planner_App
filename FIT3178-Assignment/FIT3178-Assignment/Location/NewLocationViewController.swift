//
//  NewLocationViewController.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 4/5/2023.
//

import UIKit
import MapKit

class NewLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: Empty variables for storing
    weak var locationDelegate: EditExpenseDelegate?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var annotations: [MKAnnotation] = []

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var useCurrentLocationButton: UIButton!
    @IBOutlet weak var longtitudeTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.isUserInteractionEnabled = true
        
        // MARK: Configure Location Manager
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        
        // Do any additional setup after loading the view.
        let authorisationStatus = locationManager.authorizationStatus
        if authorisationStatus != .authorizedWhenInUse{
            useCurrentLocationButton.isHidden = true
            if authorisationStatus == .notDetermined{
                locationManager.requestWhenInUseAuthorization()
            }
        }
        
        // MARK: Zoom into user's current location
        if let userLocation = mapView.userLocation.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
        
        mapView.showsUserLocation = true
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
        }

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse{
            useCurrentLocationButton.isHidden = false
        }
    }
    
    /// get the last coordinate after location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        currentLocation = locations.last!.coordinate
    }
    
    /// Zoom into user's current location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    /// Save location and pass to locationDelegate
    @IBAction func saveLocation(_ sender: Any) {
        
        guard let latitude = Double(latitudeTextField.text ?? ""), let longitude = Double(longtitudeTextField.text ?? "") else{
            let alertController = UIAlertController(title: "Coordinates invalid", message: "Latitude and longitude must be numbers", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
            return
        }
        
        locationDelegate?.addLocation(locationName: self.titleTextField.text ?? "", latitude: latitude, longitude: longitude)
        navigationController?.popViewController(animated: true)
        return
    }
    
    /// Retrieve the current location and fill in the text field
    @IBAction func useCurrentLocation(_ sender: Any) {
        if let userLocation = mapView.userLocation.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
        
        let geocoder = CLGeocoder()
        if let currentLocation = currentLocation {
            
            latitudeTextField.text = "\(currentLocation.latitude)"
            longtitudeTextField.text = "\(currentLocation.longitude)"
            let location = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
            geocoder.reverseGeocodeLocation(location){
                (placemarks, error) in
                if error != nil{
                    print("reverse geocoding eror")
                    return
                }
                guard let placemark = placemarks?.first else{
                    print("No placements found")
                    return
                }
                let name = placemark.name ?? "Unknown Location"
                self.titleTextField.text = name
            }
            
        } else{
            displayMessage(title: "Error", message: "Location not available")
        }
    }

    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    /// Add pin to the mapkit and insert information into textfield
    @IBAction func clickPin(_ sender: UILongPressGestureRecognizer) {
        let geocoder = CLGeocoder()
        if sender.state == .began {
            let touchPoint = sender.location(in: mapView)
            
            let touchMapCoordinate =  mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
            geocoder.reverseGeocodeLocation(location){
                (placemarks, error) in
                if error != nil{
                    print("reverse geocoding eror")
                    return
                }
                guard let placemark = placemarks?.first else{
                    print("No placements found")
                    return
                }
                let name = placemark.name ?? "Unknown Location"
                let latitude = placemark.location?.coordinate.latitude
                let longitude = placemark.location?.coordinate.longitude
                
                self.titleTextField.text = name
                self.latitudeTextField.text = latitude?.description
                self.longtitudeTextField.text = longitude?.description
                
                self.mapView.removeAnnotations(self.annotations)
                self.annotations.removeAll()
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = placemark.location!.coordinate
                annotation.title = name
                
                self.mapView.addAnnotation(annotation)
                self.annotations.append(annotation)

                print("Location name: \(name)")
            }
        }
    }
}
