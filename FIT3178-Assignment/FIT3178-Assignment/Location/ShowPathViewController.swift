//
//  ShowPathViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 08/06/2023.
// Reference:
// - https://www.kodeco.com/7738344-mapkit-tutorial-getting-started
// - "ChatGPT prompt": How to use mapkit to handle the callout and show the user the path to go in xcode
//

import UIKit
import MapKit

class ShowPathViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var destinationLocation: CLLocationCoordinate2D?
    var locationTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        guard let destinationLocation = destinationLocation else{
            return
        }
        
        guard let locationTitle = locationTitle else{
            return
        }
        
        let latitude = destinationLocation.latitude
        let longitude = destinationLocation.longitude
        
        let sourceLocation = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // MARK: Add annotation to mapview
        let annotation = MKPointAnnotation()
        annotation.coordinate = sourceLocation
        annotation.title = "\(locationTitle)"
        annotation.subtitle = ""
        
        mapView.addAnnotation(annotation)
        
        self.mapView.delegate = self
        
        // MARK: Zoom to the location
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: sourceLocation, span: span)
        self.mapView.setRegion(region, animated: true)

    }
    
    /// Customise the callout view when annotation is selected
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "pin") {
                return annotationView
            } else {
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                return annotationView
            }
    }
    
    ///Handle the Callout by launching maps when user clicks on the info button
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Handle the tap event on the callout accessory button
        if let annotation = view.annotation {
            // Use the annotation's coordinate to show the user directions
            let destinationPlacemark = MKPlacemark(coordinate: annotation.coordinate)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            destinationMapItem.name = annotation.title ?? ""
            
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            MKMapItem.openMaps(with: [destinationMapItem], launchOptions: launchOptions)
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

}
