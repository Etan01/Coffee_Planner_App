//
//  NewLocationDelegate.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 4/5/2023.
//

import Foundation

/// Delegate for expenses editing
protocol EditExpenseDelegate: NSObject{
    /// Add annotation such as Location
    func annotationAdded(annotation: LocationAnnotation)
    
    /// Create location witht the parameters given
    func addLocation(locationName: String, latitude: Double, longitude: Double)
    
    /// check if the date is selected 
    func didSelectDate(_ date: Date)
}
