//
//  Wishlist.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 15/5/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import CoreLocation

class Wishlist: NSObject, Codable {
    @DocumentID var id: String?
    var distance: Double?
    var name: String?
    var ratings: Double?
    var isWorking: Bool?
    var imageURL: String?
}


enum WishlistCodingKeys: String, CodingKey {
    case id
    case name
    case distance
    case ratings
    case isWorking
    case imageURL
}
