//
//  Records.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 1/6/2023.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift

class Records: NSObject, Codable{
    var id: String?
    var email: String?
    var expenses: [Expense] = []
    var currency: Currency?
}
