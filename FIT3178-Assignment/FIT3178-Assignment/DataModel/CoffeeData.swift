//
//  CoffeeData.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 01/05/2023.
//

import Foundation
import UIKit

class CoffeeData: NSObject, Decodable {
    var title: String?
    var coffeeDescription: String?
    var ingredients: [String]?
    var imageURL: String?
    
    // Used to track image downloads:
    var image: UIImage?
    var imageIsDownloading: Bool = false
    var imageShown = true
    
    enum CodingKeys: String, CodingKey {
        case title
        case coffeeDescription = "description"
        case ingredients
        case imageURL = "image"
    }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decodeIfPresent(String.self, forKey: .title)
        self.coffeeDescription = try container.decodeIfPresent(String.self, forKey: .coffeeDescription)
        self.ingredients = try container.decodeIfPresent([String].self, forKey: .ingredients)
        self.imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)

    }
}
