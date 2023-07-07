//
//  WishlistCoreData+CoreDataProperties.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 31/5/2023.
//
//

import Foundation
import CoreData


extension WishlistCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WishlistCoreData> {
        return NSFetchRequest<WishlistCoreData>(entityName: "WishlistCoreData")
    }

    @NSManaged public var distance: Double
    @NSManaged public var id: String?
    @NSManaged public var imageURL: String?
    @NSManaged public var isInWishlist: Bool
    @NSManaged public var isWorking: Bool
    @NSManaged public var name: String?
    @NSManaged public var ratings: Float
    @NSManaged public var location: LocationCoreData?

}

extension WishlistCoreData : Identifiable {

}
