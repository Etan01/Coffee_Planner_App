//
//  FirebaseController.swift
//  FIT3178-W07-Lab
//
//  Created by Tan Eng Teck on 06/04/2023.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseController: NSObject, DatabaseProtocol{
    
    // MARK: Properties
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    
    // MARK: Assign empty list for storing purposes
    var currencyList: [Currency]
    var expenseList: [Expense]
    var wishlistList: [Wishlist]
    var defaultRecord: Records
    
    // MARK: References to collection in firebase
    var currencyRef: CollectionReference?
    var expenseRef: CollectionReference?
    var wishlistRef: CollectionReference?
    var recordRef: CollectionReference?
    var usersRef: CollectionReference?
        
    var successfulSignUp: Bool = false
    
    override init(){
        print("FirebaseController is initiated")
        FirebaseApp.configure()
        
        // MARK: Assign empty herolist and team
        defaultRecord = Records()
        currencyList = [Currency]()
        expenseList = [Expense]()
        wishlistList = [Wishlist]()
        
        // MARK: Assign database
        authController = Auth.auth()
        database = Firestore.firestore()
        
        // MARK: Assign all reference
        currencyRef = database.collection("currency")
        expenseRef = database.collection("expense")
        wishlistRef = database.collection("wishlist")
        recordRef = database.collection("records")
        usersRef = database.collection("users")
        
        super.init()
        
        self.setupCurrencyListener()
        self.setupExpenseListener()
        self.setupWishlistListener()
        
    }
        
    func signInUser(email: String, password: String, completion: @escaping () -> Void){
        /**
         Perform sign in function using the email and password given
         */
        authController.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                // unsuccessful
                print("Error signing in: \(String(describing: error))")
            } else {
                // successful
                self.successfulSignUp = true
                UserSession.shared.email = email
                print("Successfully signed up as new user")
            }
            completion() // call the completion handler
        }
    }

    func signOutUser(){
        /**
         Sign out the current user
         */
        do {
            try authController.signOut()
        }
        catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        
        // MARK: Reset all variables
        expenseList = [Expense]()
        currencyList = [Currency]()
        defaultRecord = Records()
    }
    
    func addUser(){
        /**
         Add new user to firebase and create new field to the document
         */
        
        let newRecord: Records = self.addRecord(email: authController.currentUser!.email!)
        
        if let recordRef = recordRef?.document(newRecord.id!){
            usersRef?.document(authController.currentUser!.uid).setData(["records": recordRef])
        }
        
        let userRecordRef = recordRef?.document(newRecord.id!)
        let documentID = authController.currentUser!.uid
        let data = ["records": userRecordRef]
        database.collection("users").document(documentID).setData(data as [String: Any])
    }
    
    func addRecord(email: String) -> Records{
        /**
         Add email field into the new user
         
         - Returns: instance class of Records
         */
        let record = Records()
        record.email = email
        if let recordRef = recordRef?.addDocument(data: ["email": email]){
            record.id = recordRef.documentID
        }
        return record
    }
    
    func addExpenseToRecords(expense: Expense, records: Records) -> Bool{
        /**
        Write the new expense to the firebase in the field expenses
         - Parameters:
            - expense: instance of Expense
            - records: instance of Records
         - Returns: Boolean
         */
        guard let expenseID = expense.id, let recordID = records.id else{
            return false
        }
        
        if let newExpenseRef = expenseRef?.document(expenseID){
            recordRef?.document(recordID).updateData(["expenses": FieldValue.arrayUnion([newExpenseRef])])
        }
        
        return true
    }
    
    func createNewUser(email: String, password: String, completion: @escaping () -> Void) {
        /**
        Create user from authController using the parameters given
         */
        authController.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                // unsuccessful
                print("Error creating user: \(String(describing: error))")
            } else {
                // successful
                self.successfulSignUp = true
                self.addUser()  //create new user into firebase as well
                print("successfully signed up user")
                UserSession.shared.email = email
            }
            completion() // call the completion handler after setupHeroListener is finished
        }
    }

    func cleanup(){}
    
    func addCategory(category: String) -> Bool {
        return true
    }
    
    /// Create instance of Expense with the parameters given and store it in Firebase
    func addExpenseItem(name: String, categoryChosen: String, amount: Double, location: Location, date: Date) -> Expense{
        let expense = Expense()
        expense.name = name
        expense.category = categoryChosen
        expense.amount = amount
        expense.location = location
        expense.date = date
        
        let calendar = Calendar.current
        let resetDate = calendar.startOfDay(for: expense.date!)
        
        let expenseData: [String: Any] = [
            "name" : expense.name!,
            "category": expense.category!,
            "amount": expense.amount!,
            "location": [
                "name": expense.location?.name! ?? "",
                "latitude": expense.location?.latitude! ?? 0,
                "longitude": expense.location?.longitude! ?? 0,
            ],
            "date": resetDate
        ]
        
        // MARK: Store ExpenseData as document into the collection in firebase
        do {
            if let expenseRef = try expenseRef?.addDocument(data: expenseData) {
                expense.id = expenseRef.documentID
            }
            
            // Store expense as a reference to an array of records
            let _ = addExpenseToRecords(expense: expense, records: defaultRecord)
            
        }
        catch {
            print("Failed to serialize expense")
            
        }
        
        return expense
        
    }
    
    func editExpenseItem(expense: Expense, name: String, categoryChosen: String, amount: Double, location: Location, date: Date){
        /**
         Update document with the parameters given and write into firebase
         */
        let expenseID = expense.documentId
        
        let calendar = Calendar.current
        let resetDate = calendar.startOfDay(for: expense.date!)
        
        if let expenseRef = expenseRef?.document(expenseID!) {
            expenseRef.setData(
            [
                "name": name,
                "category": categoryChosen,
                "amount": amount,
                "documentID": expense.documentId!,
                "location": [
                    "name": location.name!,
                    "latitude": location.latitude!,
                    "longitude": location.longitude!,
                ],
                "date": resetDate
            ])
        } else{
            print("Document is not updated in firebase")
        }
        
    }
    
    func addToWishlist(name: String, distance: Double, isWorking: Bool, ratings: Double, imageUrl: String) -> Wishlist {
        /**
        - Functions deprecated as the core data controller replace this function
         
         Create instance of wishlist and store into firebase
         */
        let wishlist = Wishlist()
        wishlist.name = name
        wishlist.distance = distance
        wishlist.isWorking = isWorking
        wishlist.ratings = ratings
        wishlist.imageURL = imageUrl

        let wishlistData: [String: Any] = [
            "name" : name,
            "distance": distance,
            "isWorking": isWorking,
            "ratings": ratings,
            "imageURL": imageUrl
        ]

        do {
            if let wishlistRef = try wishlistRef?.addDocument(data: wishlistData) {
                wishlist.id = wishlistRef.documentID
            }
        }
        catch {
            print("Failed to serialize expense")

        }

        return wishlist
    }
    
    func removeFromWishlist(wishlist: Wishlist) {
        //
    }

    
    func addListener(listener: DatabaseListener) {
        /**
         Add listeners to all relevant listener type
         */
        listeners.addDelegate(listener)
        if listener.listenerType == .currencies || listener.listenerType == .all {
            listener.onAllCurrenciesChange(change: .update, currency: currencyList)
        }
        
        if listener.listenerType == .expenses || listener.listenerType == .all {
            listener.onAllExpensesChange(change: .update, expenses: expenseList)
        }
        if listener.listenerType == .wishlist || listener.listenerType == .all {
            listener.onAllWishlistChange(change: .update, wishlist: wishlistList)
        }
        
        if listener.listenerType == .records || listener.listenerType == .all {
            listener.onRecordChange(change: .update, records: defaultRecord.expenses)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        /**
         Remove the listener given from the list of listeners
         */
        listeners.removeDelegate(listener)
    }


    func setupCurrencyListener(){
        /**
         Setup the currency reference and ready to fetch snapshot from firebase
         */
        currencyRef = database.collection("currency")
        currencyRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                // If fetching is failed
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            
            //Fetch documents from firebase and store into relevant list
            self.parseCurrenciesSnapshot(snapshot: querySnapshot)
        }
    }
    
    func setupExpenseListener(){
        /**
         Setup the expense reference and ready to fetch snapshot from firebase
         */
        expenseRef = database.collection("expense")
        expenseRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            //Fetch documents from firebase and store into relevant list
            self.parseExpenseSnapshot(snapshot: querySnapshot)
            self.setupRecordListener()
        }
        
//        self.setupRecordListener()
    }
    
    func setupWishlistListener(){
        /**
         Setup the wishlist reference and ready to fetch snapshot from firebase
         */
        wishlistRef = database.collection("wishlist")
        wishlistRef?.addSnapshotListener() {
            (querySnapshot, error) in
            guard let querySnapshot = querySnapshot else {
                print("Failed to fetch documents with error: \(String(describing: error))")
                return
            }
            self.parseWishlistSnapshot(snapshot: querySnapshot)
        }
    }
    
    func setupRecordListener(){
        /**
         Setup the records reference and ready to fetch snapshot from firebase
         */
        if authController.currentUser != nil{
            let userRef = database.collection("users").document(authController.currentUser!.uid)
            userRef.getDocument{(document, error) in
                if let document = document, document.exists{
                    let recordRef = document.get("records") as! DocumentReference
                    
                    recordRef.addSnapshotListener(){ (documentSnapshot, error) in
                        guard let documentSnapshot = documentSnapshot else{
                            print("Error fetching document: \(error!)")
                            return
                        }
                        
                        self.parseRecordSnapshot(snapshot: documentSnapshot)
                    }
                } else {
                    print("User document does not exist")
                }
            }
        }
    }
    
    func parseRecordSnapshot(snapshot: DocumentSnapshot){
        /**
         Fetch documents from records and take data from expenses in order to append to the default record
         */
        
        defaultRecord = Records()
        defaultRecord.id = snapshot.documentID
        
        if let expenseReferences = snapshot.data()!["expenses"] as? [DocumentReference]{
            for reference in expenseReferences{

                if let expense = getExpenseByID(reference.documentID){
                    defaultRecord.expenses.append(expense)
                }
            }
        }
        
        // call listener to update the changes to the delegate method
        listeners.invoke{(listener) in
            if listener.listenerType == ListenerType.records || listener.listenerType == ListenerType.all || listener.listenerType == ListenerType.expenses{
                
                listener.onRecordChange(change: .update, records: defaultRecord.expenses)
            }
        }
        
    }
    
    func reflectChangeInRecords(snapshot: QuerySnapshot){
        let recordsRef = Firestore.firestore().collection("records")
        
        for documentChange in snapshot.documentChanges{
            let expenseDocument = documentChange.document
            
            let expenseData = expenseDocument.data()
            
            
        }
    }
    
    func parseCurrenciesSnapshot(snapshot: QuerySnapshot){
        /**
         Fetch documents from currencies and append into currencylist
         */
        snapshot.documentChanges.forEach {
            (change) in
            var parsedCurrency: Currency?
            do {
                parsedCurrency = try change.document.data(as: Currency.self)
            } catch {
                print("Unable to decode currency. Is the currency malformed?")
                return
            }

            guard let currency = parsedCurrency else {
                print("Document doesn't exist")
                return;
            }

            if change.type == .added {
                currencyList.insert(currency, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                currencyList[Int(change.oldIndex)] = currency
            }
            else if change.type == .removed {
                currencyList.remove(at: Int(change.oldIndex))
            }

            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.currencies || listener.listenerType == ListenerType.all{

                    listener.onAllCurrenciesChange(change: .update, currency: currencyList)
                }
            }
        }
    }
    
    
    
    func parseExpenseSnapshot(snapshot: QuerySnapshot){
        /**
         Fetch documents from expenses and append into expenseList
         */
        snapshot.documentChanges.forEach {
            (change) in
            var parsedExpense: Expense?
            do {
                var expenseData = try change.document.data()
                expenseData["documentId"] = change.document.documentID
                
                guard let locationData = expenseData["location"] as? [String: Any],
                      let locationName = locationData["name"] as? String,
                      let latitude = locationData["latitude"] as? Double,
                      let longitude = locationData["longitude"] as? Double else{
                    return
                }
                
                let location = Location(name: locationName, latitude: latitude, longitude:longitude)
                var expenseDataWithoutLocation = expenseData
                expenseDataWithoutLocation.removeValue(forKey: "location")
                
                parsedExpense = try Firestore.Decoder().decode(Expense.self, from: expenseDataWithoutLocation)
                
                parsedExpense?.location = location
                
            } catch {
                print("Unable to decode expense. Is the expense malformed?")
                return
            }

            guard let expense = parsedExpense else {
                print("Document doesn't exist")
                return;
            }

            if change.type == .added {
                expenseList.insert(expense, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                expenseList[Int(change.oldIndex)] = expense
            }
            else if change.type == .removed {
                expenseList.remove(at: Int(change.oldIndex))
            }

            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.expenses || listener.listenerType == ListenerType.all{

                    listener.onAllExpensesChange(change: .update, expenses: expenseList)
                }
            }
        }
    }
    
    func parseWishlistSnapshot(snapshot: QuerySnapshot){
        /**
         Fetch documents from wishlist and append into wishlistList
         */
        snapshot.documentChanges.forEach {
            (change) in
            var parseWishlist: Wishlist?
            do {
                parseWishlist = try change.document.data(as: Wishlist.self)
            } catch {
                print("Unable to decode wishlist. Is the currency malformed?")
                return
            }

            guard let wishlist = parseWishlist else {
                print("Document doesn't exist")
                return;
            }

            if change.type == .added {
                wishlistList.insert(wishlist, at: Int(change.newIndex))
            }
            else if change.type == .modified {
                wishlistList[Int(change.oldIndex)] = wishlist
            }
            else if change.type == .removed {
                wishlistList.remove(at: Int(change.oldIndex))
            }

            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.wishlist || listener.listenerType == ListenerType.all{

                    listener.onAllWishlistChange(change: .update, wishlist: wishlistList)
                }
            }
        }
    }
    
    func deleteExpense(expense: Expense) {
        /**
         Delete the instance of expense from document by the id
         */

        if let expenseID = expense.documentId {
            expenseRef?.document(expenseID).delete()
            deleteExpenseFromRecord(expense: expense, records: defaultRecord)
        }
        
    }
    
    func deleteExpenseFromRecord(expense: Expense, records: Records){
        if records.expenses.contains(expense), let recordID = records.id, let expenseID = expense.documentId {
            if let removedExpRef = expenseRef?.document(expenseID) { recordRef?.document(recordID).updateData(
                ["expenses": FieldValue.arrayRemove([removedExpRef])] )
                print("Successfully remove the expense")
            }
        }
    }
    
    func getExpenseByID(_ id: String) -> Expense?{
        /**
         Get instance of expense by the id given
         */
        return expenseList.first(where: {$0.documentId == id})
    }

    
}
