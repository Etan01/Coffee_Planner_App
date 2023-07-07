//
//  SelectCurrencyDelegate.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 29/05/2023.
//

import Foundation

/// Delegate for selecting currency in settings
protocol SelectCurrencyDelegate: AnyObject{
    // A protocol for delegation
    func selectCurrency(currency: Currency)
}
