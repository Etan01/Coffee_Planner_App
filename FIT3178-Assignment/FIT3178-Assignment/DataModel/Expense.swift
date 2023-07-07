//
//  Expense.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 02/05/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import CoreLocation

class Expense: NSObject, Codable {
    @DocumentID var id: String?
    var documentId: String?
    var name: String?
    var category: String?
    var amount: Double?
    var location: Location?
    var date: Date?
}


enum ExpenseCodingKeys: String, CodingKey {
    case id
    case documentId
    case name
    case date
    case category
    case amount
    case location
}


