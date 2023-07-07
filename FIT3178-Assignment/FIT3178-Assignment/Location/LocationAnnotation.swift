//
//  LocationAnnotation.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 4/5/2023.
//

import Foundation
import MapKit

class LocationAnnotation: NSObject{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String? = nil, subtitle: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
