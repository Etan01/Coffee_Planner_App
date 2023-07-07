//
//  CoreDataController.swift
//  W03-lab
//
//  Created by Tan Eng Teck on 28/03/2023.
//

import UIKit
import CoreData

class CoreDataController: NSObject, NSFetchedResultsControllerDelegate, CoreDataProtocol {
    
    // MARK: -Properties
    
    // Create variables entity
    var currentWishlist: WishlistCoreData?
    
    // Fetch Results Controller
    var wishlistFetchedResultsController: NSFetchedResultsController<WishlistCoreData>?
    var listeners = MulticastDelegate<CoreDataListener>()
    var persistentContainer: NSPersistentContainer
    
    // MARK: Constructor
    override init() {
        // Define persistent container
        persistentContainer = NSPersistentContainer(name: "DataModel")
        persistentContainer.loadPersistentStores() { (description, error ) in
        if let error = error {
            fatalError("Failed to load Core Data Stack with error: \(error)")
        } }
        super.init()
    }
    
    func fetchAllWishlist() -> [WishlistCoreData]{
        /**
        Fetch data from wishlist which stores in core data persistent storage
         **/
        
        // Instantiate the fetch request
        let request: NSFetchRequest<WishlistCoreData> = WishlistCoreData.fetchRequest()
        let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        request.sortDescriptors = [nameSortDescriptor]
        
        
        // Initialise the fetch results controller
        wishlistFetchedResultsController = NSFetchedResultsController<WishlistCoreData>(fetchRequest: request, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        wishlistFetchedResultsController?.delegate = self
        
        // Perform fetching request
        do{
            try wishlistFetchedResultsController?.performFetch()
        } catch{
            print("Fetch Request Failed: \(error)")
        }
        
        if wishlistFetchedResultsController == nil{}
        if let wishlists = wishlistFetchedResultsController?.fetchedObjects{
            return wishlists
        }
        return [WishlistCoreData]()
    
    }
    
    func cleanup() {
        /**
         Save the changes into persistant storage
         */
        if persistentContainer.viewContext.hasChanges{
            do{
                try persistentContainer.viewContext.save()
            } catch{
                fatalError("Failed to save changes to Core Data with error: \(error)")
            }
        }
    }
    
    func addListener(listener: CoreDataListener) {
        /**
         Create listener that can fetch all wishlist whenever there is changes
         **/
        listeners.addDelegate(listener)
        listener.onWishlistChange(wishlist: fetchAllWishlist())
    }
    
    func removeListener(listener: CoreDataListener) {
        /**
         Remove listener
         */
        listeners.removeDelegate(listener)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        /**
         When changes happen to FetchedResultController, it will be called and update the wishlist
         */
        listeners.invoke(){
            listener in listener.onWishlistChange(wishlist: fetchAllWishlist())
        }
    }
    
    func addToWishlist(id: String, name: String, distance: Double, isWorking: Bool, ratings: Float, imageUrl: String, latitude: Double, longitude: Double) -> WishlistCoreData{
        /**
         Create instance of Wishlist from parameters and save it into core data
         */
        let wishlist = NSEntityDescription.insertNewObject(forEntityName: "WishlistCoreData", into: persistentContainer.viewContext) as! WishlistCoreData
    
        wishlist.id = id
        wishlist.name = name
        wishlist.distance = distance
        wishlist.ratings = ratings
        wishlist.imageURL = imageUrl
        wishlist.isWorking = isWorking
        wishlist.isInWishlist = true
        
        wishlist.location = NSEntityDescription.insertNewObject(forEntityName: "LocationCoreData", into: persistentContainer.viewContext) as? LocationCoreData
        
        wishlist.location?.title = name
        wishlist.location?.latitude = latitude
        wishlist.location?.longitude = longitude
        return wishlist
    }
    
    func removeFromWishlist(wishlist: WishlistCoreData) {
        /**
         Remove wishlist instance from core data
         */
        persistentContainer.viewContext.delete(wishlist)
    }
    
    func fetchWishlist(withId id: String) -> WishlistCoreData? {
        /**
         Fetch wishlist according to the id given
         */
        let fetchRequest: NSFetchRequest<WishlistCoreData> = WishlistCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        do{
            let results = try persistentContainer.viewContext.fetch(fetchRequest)
            guard let first = results.first else{
                return nil
            }
            return first
            
        } catch{
            print("Error: \(error)")
            return nil
        }
    }

    
}
