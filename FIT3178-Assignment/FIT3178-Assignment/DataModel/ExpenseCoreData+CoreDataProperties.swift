//
//  ExpenseCoreData+CoreDataProperties.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 13/05/2023.
//
//

import Foundation
import CoreData


extension ExpenseCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExpenseCoreData> {
        return NSFetchRequest<ExpenseCoreData>(entityName: "ExpenseCoreData")
    }

    @NSManaged public var title: String?
    @NSManaged public var amount: Double
    @NSManaged public var category: String?
    @NSManaged public var date: String?
    @NSManaged public var locations: LocationCoreData?

}

extension ExpenseCoreData : Identifiable {

}
