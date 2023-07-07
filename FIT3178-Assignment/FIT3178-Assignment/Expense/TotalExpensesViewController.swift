//
//  TotalExpensesViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 08/05/2023.
// Reference:
// - Chatgpt Prompt: How to create tableview with date section in xcode
//

import UIKit
import CoreData

struct SortedSections {
    var sections: [Date: [Expense]]
    var sectionDates: [Date]
}

class TotalExpensesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DatabaseListener {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalExpense: UILabel!
    @IBOutlet weak var saveOffline: UIBarButtonItem!
    
    // MARK: Configure cells for tableview
    let CELL_EXPENSES: String = "expenseCell"
    let CELL_TOTAL: String = "totalCell"
    
    let SECTION_EXPENSES: Int = 0
    let SECTION_TOTAL: Int = 1
    
    // MARK: Empty variables for storing
    var selectedExpense: Expense?
    var allExpenses: [Expense] = []
    var sortedExpenses: [Expense] = []
    
    // MARK: Variables for date heading
    var sections: [Date: [Expense]] = [:]
    var sectionDates: [Date] = []
    
    var isEditingExistingData: Bool = false
    var totalAmount: Double = 0.0
    var previousContentOffset: CGPoint?
    
    // MARK: Configure listener type for database changes
    var listenerType = ListenerType.records
    weak var databaseController: DatabaseProtocol?
    var sortedSections = SortedSections(sections: [:], sectionDates: [])
    
//    weak var coredataController: CoreDataController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
        
                
    }
    
    /// Format date to string format
    func formatDateToString(_ date: Date)-> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = Array(sections.keys)[section]
        return sections[date]?.count ?? 0

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let expenseCell = tableView.dequeueReusableCell(withIdentifier: CELL_EXPENSES, for: indexPath) as! RecordTableViewCell
        
        let date = Array(sections.keys)[indexPath.section]
        let expenseItems = sections[date]
        let expense = expenseItems![indexPath.row]
        
        expenseCell.titleLabel.text = expense.name
        expenseCell.locationLabel.text = expense.location?.name
        expenseCell.amountLabel.text = expense.amount?.description
        expenseCell.categoryLabel.text = expense.category
        
        if expense.category == "Matcha"{
            expenseCell.emojiLabel.text = "🍵"
        } else if expense.category == "Cold Drink"{
            expenseCell.emojiLabel.text = "🥤"
        } else if expense.category == "Chocolate"{
            expenseCell.emojiLabel.text = "🍫"
        }
        
        return expenseCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let sectionDate = formatDateToString(Array(sections.keys)[section])

        let today = formatDateToString(Date())
        if sectionDate == today{
            return "Today"
        }
        return sectionDate
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let date = Array(sections.keys)[indexPath.section]
        let expenseItems = sections[date]
        
        selectedExpense = expenseItems![indexPath.row]
        performSegue(withIdentifier: "updateExpenseSegue", sender: self)
    }
    
    func onAllCurrenciesChange(change: DatabaseChange, currency: [Currency]) {
        //
    }
    
    func onAllExpensesChange(change: DatabaseChange, expenses: [Expense]) {
        /**
         Detect the changes such as edit expense
         */
        print("Expense is update")
    }
    
    func onRecordChange(change: DatabaseChange, records: [Expense]) {
       /**
        Detect changes from database from the records reference
        */
        
        if self.allExpenses.count < records.count || self.allExpenses.count > records.count {
            sections.removeAll()
            
        } else{
            sections = sections.mapValues { _ in [] }
        }
        
        self.allExpenses = records
        sortedExpenses = allExpenses.sorted {$0.date!<$1.date!}
            
        for item in sortedExpenses{
            let date = item.date!
            if sections[date] == nil{
                sections[date] = [item]
            } else{
                sections[date]?.append(item)
            }
        }
        
        self.tableView.reloadData()
        
        self.totalAmount = records.reduce(0.0){ $0 + $1.amount!}
        print("Total Amount: \(totalAmount)")
        
        if let currency = UserSession.shared.currency{
            totalExpense.text = "\(currency.symbol ?? "$") \(totalAmount.description)"
        } else{
            totalExpense.text = "$ \(totalAmount.description)"
        }
    }
    
    func onAllWishlistChange(change: DatabaseChange, wishlist: [Wishlist]) {
        //
    }
    
    @IBAction func saveOfflineFunc(_ sender: Any) {
//        CoreDataController().saveAllExpenses(expenses: allExpenses)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let date = Array(sections.keys)[indexPath.section]
            let expenseItems = sections[date]
            
            let expense = (expenseItems?[indexPath.row])!
            databaseController?.deleteExpense(expense: expense)
        }
    }
        
        
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
         if segue.identifier == "createExpenseSegue"{
            let destination = segue.destination as! CreateExpenseTableViewController
             
//             if isEditingExistingData == true{
//                 destination.saveData = selectedExpense
//                 destination.isEdit = true
//             }
         }
         if segue.identifier == "updateExpenseSegue"{
             let destination = segue.destination as? UpdateExpenseTableViewController
             destination?.saveData = selectedExpense
             
         }
         
         
     }
     
        
}
