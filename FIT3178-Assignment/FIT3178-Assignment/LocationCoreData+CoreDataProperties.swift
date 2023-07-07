//
//  LocationCoreData+CoreDataProperties.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 26/5/2023.
//
//

import Foundation
import CoreData


extension LocationCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationCoreData> {
        return NSFetchRequest<LocationCoreData>(entityName: "LocationCoreData")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var title: String?
    @NSManaged public var expenses: ExpenseCoreData?
    @NSManaged public var wishlist: WishlistCoreData?

}

extension LocationCoreData : Identifiable {

}
