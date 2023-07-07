//
//  Location.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 14/05/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import CoreLocation

class Location: NSObject, Codable {
    var name: String?
    var latitude: Double?
    var longitude: Double?
    
    required init(name: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

//enum LocationCodingKeys: String, CodingKey {
//    case id
//    case name
//    case latitude
//    case longitude
//}
