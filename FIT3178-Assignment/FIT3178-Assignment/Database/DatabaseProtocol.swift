//
//  DatabaseProtocol.swift
//  FIT3178-W04-Lab
//
//  Created by Jason Haasz on 4/1/2023.
//

import Foundation

enum DatabaseChange{
    case add
    case remove
    case update
}

enum ListenerType {
    case group
    case currencies
    case expenses
    case all
    case categories
    case wishlist
    case records
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onAllCurrenciesChange(change: DatabaseChange, currency: [Currency])
    func onAllExpensesChange(change: DatabaseChange, expenses: [Expense])
    func onAllWishlistChange(change: DatabaseChange, wishlist: [Wishlist])
    func onRecordChange(change: DatabaseChange, records: [Expense])
}

protocol DatabaseProtocol: AnyObject {
    func cleanup()
    
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
    
    func addExpenseItem(name: String, categoryChosen: String, amount: Double, location: Location, date: Date) -> Expense
    func deleteExpense(expense: Expense)
    func editExpenseItem(expense: Expense, name: String, categoryChosen: String, amount: Double, location: Location, date: Date)
    
    func addExpenseToRecords(expense: Expense, records: Records) -> Bool
    var defaultRecord: Records {get}
    
    func addToWishlist(name: String, distance: Double, isWorking:Bool, ratings: Double, imageUrl:String) -> Wishlist
    func removeFromWishlist(wishlist: Wishlist)

    var successfulSignUp: Bool {get set}
    func setupCurrencyListener()
    func setupExpenseListener()
    func setupWishlistListener()
    func setupRecordListener()
    
    func createNewUser(email: String, password: String, completion: @escaping () -> Void)
    func signInUser(email: String, password: String, completion: @escaping () -> Void)
    func signOutUser()
    
}
