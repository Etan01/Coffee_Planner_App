//
//  Currency.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 25/04/2023.
//

import Foundation
import FirebaseFirestoreSwift

class Currency: NSObject, Codable{
    @DocumentID var id:String?
    var symbol: String?
    var name: String?
}


enum CodingKeys: String, CodingKey{
    case id
    case symbol
    case name
}
