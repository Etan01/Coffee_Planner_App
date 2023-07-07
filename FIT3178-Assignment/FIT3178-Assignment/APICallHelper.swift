//
//  APICall.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 7/6/2023.
//

import Foundation

public struct Venue{
    var name: String?
    var id: String?
    var rating: Float?
    var price: String?
    var is_closed: Bool?
    var distance: Double?
    var address: String?
    var imageURL: String?
    var isInWishlist: Bool?
    var latitude: Double?
    var longitude: Double?
}

public class APICallHelper{
    
    /// Retriev venue according to the parameters given and collect the first one
    public func retrieveVenues(latitude: Double, longitude: Double, category: String, limit: Int, sortBy: String, locale: String) async throws -> [Venue]{
        /**
         Ref 1: https://docs.developer.yelp.com/docs/fusion-intro
         Ref 2: https://medium.com/@khansaryan/yelp-fusion-api-integration-af50dd186a6e
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
              // valuable information are stored in the list of businesses
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
            venue.isInWishlist = false
            
            let latitude = business.value(forKeyPath: "coordinates.latitude") as? Double
            let longitude = business.value(forKeyPath: "coordinates.longitude") as? Double
            venue.latitude = latitude
            venue.longitude = longitude
            
            venueList.append(venue)
        }
        return venueList
    }
    
    /// Retrieve reviews from API GET method and decode it to save into review list
    func retrieveReview(id: String) async throws -> [Reviews]{
                
        let baseURL =
            "https://api.yelp.com/v3/businesses/\(id)/reviews"
        
        let url = URL(string: baseURL)
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apikey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        
        // MARK: Define url varibale
        // Initalise session and task
        let (data, _) = try await URLSession.shared.data(for: request)
        // Read data as JSON
        let json = try JSONSerialization.jsonObject(with: data, options: [])
                
        // Main Dictionary
        guard let resp = json as! NSDictionary?,
              let reviews = resp.value(forKey: "reviews") as? [NSDictionary] else {
            throw NSError(domain: "Parsing Error", code: 0, userInfo: nil)
        }
        
        // MARK: Store data into empty list
        var reviewList : [Reviews] = []
        
        for userReview in reviews {
            var review = Reviews()
            review.text = userReview.value(forKey: "text") as? String
            review.rating = userReview.value(forKey: "rating") as? Float
            review.name = userReview.value(forKey: "user.name") as? String
            
            reviewList.append(review)
        }
        return reviewList
    }
}
