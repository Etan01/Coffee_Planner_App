//
//  CurrencyTableTableViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 23/04/2023.
//

import UIKit

class CurrencyTableTableViewController: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    let SECTION_CURRENCY = 0
    let SECTION_INFO = 1
    
    let CELL_CURRENCY = "currencyCell"
    let CELL_INFO = "totalCell"
    
    var allCurrencies: [Currency] = []
    var filteredCurrencies: [Currency] = []
    
    var listenerType = ListenerType.currencies
    weak var databaseController: DatabaseProtocol?
    
    weak var currencyDelegate: SelectCurrencyDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search All"
        navigationItem.searchController = searchController
                
        // This view controller decides how the search controller is presented
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        filteredCurrencies = allCurrencies
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
        navigationController?.popViewController(animated: true)

    }
    
    func onAllCurrenciesChange(change: DatabaseChange, currency: [Currency]) {
        allCurrencies = currency
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case SECTION_CURRENCY:
            return filteredCurrencies.count
        case SECTION_INFO:
            return 1
        default:
            return 0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_CURRENCY {
            
            let currencyCell = tableView.dequeueReusableCell(withIdentifier: CELL_CURRENCY, for: indexPath)
            
            var content = currencyCell.defaultContentConfiguration()
            let currency = filteredCurrencies[indexPath.row]
            content.text = currency.name
            content.secondaryText = currency.symbol
            currencyCell.contentConfiguration = content
            
            return currencyCell
        }
        
        else {
            let infoCell = tableView.dequeueReusableCell(withIdentifier: CELL_INFO, for: indexPath) as! CurrencyCountTableViewCell
                    
            infoCell.totalLabel?.text = "\(filteredCurrencies.count) currencies in the database"
            
            return infoCell
        }
        
        
    }
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.section == SECTION_CURRENCY {
            return true
        }
        
        return false
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete && indexPath.section == SECTION_CURRENCY {
//            let currency = filteredCurrencies[indexPath.row]
//            //            databaseController?.deleteSuperhero(hero: hero)
//        }
        
        
        /*
         // Override to support rearranging the table view.
         override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
         
         }
         */
        
        /*
         // Override to support conditional rearranging of the table view.
         override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the item to be re-orderable.
         return true
         }
         */
        
        /*
         // MARK: - Navigation
         
         // In a storyboard-based application, you will often want to do a little preparation before navigation
         override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         // Get the new view controller using segue.destination.
         // Pass the selected object to the new view controller.
         }
         */
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {
            return
        }

        if searchText.count > 0 {
            filteredCurrencies = allCurrencies.filter({ (currency: Currency) -> Bool in
                return (currency.name?.lowercased().contains(searchText) ?? false)
            })
        } else {
            filteredCurrencies = allCurrencies
        }

        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = filteredCurrencies[indexPath.row]
        currencyDelegate?.selectCurrency(currency: currency)
        navigationController?.popViewController(animated: false)
        return

    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [Wishlist]) {
        //
    }
    
    
    func onAllExpensesChange(change: DatabaseChange, expenses: [Expense]) {
        //
    }
    
    func onRecordChange(change: DatabaseChange, records: [Expense]) {
        //
    }
    
    
    
}
