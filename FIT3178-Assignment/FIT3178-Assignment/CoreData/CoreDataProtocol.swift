//
//  CoreDataProtocol.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 22/5/2023.
//

import Foundation

// MARK: Listeners for the database changes
protocol CoreDataListener: AnyObject{
    func onWishlistChange( wishlist: [WishlistCoreData])
}

// MARK: Protocol for all functions for delegation
protocol CoreDataProtocol: AnyObject{
    var currentWishlist: WishlistCoreData? {get set}
    func cleanup()
    func addListener(listener: CoreDataListener)
    func removeListener(listener: CoreDataListener)
    func addToWishlist(id: String, name: String, distance: Double, isWorking:Bool, ratings: Float, imageUrl:String, latitude:Double, longitude: Double) -> WishlistCoreData
    func removeFromWishlist(wishlist: WishlistCoreData)
    func fetchWishlist(withId id: String) -> WishlistCoreData?
}
