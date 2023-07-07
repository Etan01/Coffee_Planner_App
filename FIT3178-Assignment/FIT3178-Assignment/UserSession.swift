//
//  UserSession.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 30/5/2023.
//

import Foundation
import CoreLocation

class UserSession{
    
    // MARK: Class session to store user information
    static let shared = UserSession()
    
    var email: String?
    var currency: Currency?
    var currentLocation: CLLocationCoordinate2D?
    
    private init(){}
    
}


