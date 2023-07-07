//
//  CurrencyAPI.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 10/05/2023.
//

import Foundation

class CurrencyAPI: NSObject, Decodable {
    var success: String?
    var symbols: [String: String]?
    
    enum CodingKeys: String, CodingKey {
        case success
        case symbols
    }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.success = try container.decodeIfPresent(String.self, forKey: .success)
        self.symbols = try container.decodeIfPresent([String:String].self, forKey: .symbols)

    }
}
