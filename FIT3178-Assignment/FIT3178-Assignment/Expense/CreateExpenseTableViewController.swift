//
//  ExpenseTableViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 02/05/2023.
//

import UIKit

class CreateExpenseTableViewController: UITableViewController, UITextFieldDelegate, AddCategoryDelegate, EditExpenseDelegate{
    
    let CELL_TITLE: String = "titleCell"
    let CELL_LOCATION: String = "locationCell"
    let CELL_CATEGORY: String = "categoryCell"
    let CELL_EXPENSES: String = "amountCell"
    let CELL_DATE: String = "dateCell"
    
    // Sections
    let SECTION_TITLE: Int = 0
    let SECTION_LOCATION: Int = 1
    let SECTION_CATEGORY: Int = 2
    let SECTION_EXPENSES: Int = 3
    let SECTION_DATE: Int = 4
    
    weak var databaseController: DatabaseProtocol?
    
    // MARK: variables for delegate
    var categoryChosen: String = ""
    var locationName: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var dateChosen: Date = Date()
    
    // MARK: variables for retain data
    var nameTemp: String = ""
    var amountTemp: Double?

    var saveData: Expense?
    var isEdit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController

    }
    
    func annotationAdded(annotation: LocationAnnotation) {
        //
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case SECTION_TITLE:
            return 1
        case SECTION_LOCATION:
            return 1
        case SECTION_CATEGORY:
            return 1
        case SECTION_EXPENSES:
            return 1
        case SECTION_DATE:
            return 1

        default:
            return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == SECTION_TITLE {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_TITLE, for: indexPath) as! ExpenseTableViewCell
            cell.label?.text = "Title"
            cell.textField?.delegate = self
            
            if self.nameTemp.count == 0{
                cell.textField.placeholder = "Enter Title"
            } else {
                cell.textField.text = self.nameTemp
            }
            
            return cell
        }
         else if indexPath.section == SECTION_LOCATION {
             let cell = tableView.dequeueReusableCell(withIdentifier: CELL_LOCATION, for: indexPath)
             
             if self.locationName.count == 0{
                 cell.textLabel?.text = "Choose Location"
             } else{
                 cell.textLabel?.text = self.locationName
             }
             
             return cell
            
        } else if indexPath.section == SECTION_CATEGORY {
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_CATEGORY, for: indexPath)
            if self.categoryChosen.count == 0{
                cell.textLabel?.text = "Choose Category"
            } else{
                cell.textLabel?.text = self.categoryChosen
            }
             
            return cell
            
            
        } else if indexPath.section == SECTION_EXPENSES{
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_EXPENSES, for: indexPath) as! ExpenseAmountTableViewCell
            
            cell.amountLabel?.text = "Amount"
            cell.amountTextField?.delegate = self
            
            if self.amountTemp == -1{
                cell.amountTextField.placeholder = "Enter Amount"
            } else {
                cell.amountTextField.text = self.amountTemp?.description
            }

            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: CELL_DATE, for: indexPath)
            
            if self.dateChosen == Date(){
                cell.textLabel?.text = "Today"
            } else{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                cell.textLabel?.text = dateFormatter.string(from: dateChosen)
            }
            
            
            return cell
        }
    }

    @IBAction func saveDetailFunc(_ sender: Any) {
        let name = (tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as! ExpenseTableViewCell).textField.text ?? ""
        let amountString = (tableView.cellForRow(at: IndexPath(row: 0, section: 3)) as! ExpenseAmountTableViewCell).amountTextField.text ?? ""
        let amount = Double(amountString) ?? -1
        
        if name.isEmpty || locationName.count == 0 || categoryChosen.count == 0{
            var errorMsg = "Please ensure all fields are filled:\n"
            if name.isEmpty {
                errorMsg += "- Must provide a name\n"
            }
            if locationName.isEmpty {
                errorMsg += "- Must provide location\n"
            }
            if categoryChosen.isEmpty{
                errorMsg += "- Must provide category\n"
            }
            if amount == -1{
                errorMsg += "- Must provide amount"
            }
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        } else if dateChosen > Date(){
            let errorMsg = "Please insert a valid date"
            displayMessage(title: "Future date is not allowed", message: errorMsg)
            return
        }
        
        let location = Location(name: locationName, latitude: latitude, longitude: longitude)
        
            
        let _ = databaseController?.addExpenseItem(name: name, categoryChosen: categoryChosen, amount: amount, location: location, date: dateChosen)


        navigationController?.popToRootViewController(animated: true)
    }
        
    func addCategory(category: String){
        self.categoryChosen = category
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: SECTION_CATEGORY)){
            cell.textLabel?.text = categoryChosen
            self.tableView.reloadSections([SECTION_CATEGORY], with: .automatic)
        }
    }
    
    
    func addLocation(locationName: String, latitude: Double, longitude: Double) {
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: SECTION_LOCATION)){
            cell.textLabel?.text = locationName
            self.tableView.reloadSections([SECTION_LOCATION], with: .automatic)
        }
    }
    
    func didSelectDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        self.dateChosen = date //dataFormatter.string(from: date)
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: SECTION_DATE)){
            cell.textLabel?.text = dateFormatter.string(from: date)
            self.tableView.reloadSections([SECTION_DATE], with: .automatic)
        }
    }

    // MARK: Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "chooseCategory"{
            let destination = segue.destination as! CategoryTableViewController
            destination.categoryDelegate = self
        }
        else if segue.identifier == "createLocationDetail"{
            let destination = segue.destination as! NewLocationViewController
            destination.locationDelegate = self
        }
        else if segue.identifier == "chooseDateSegue"{
            let destination = segue.destination as! DatePickerViewController
            destination.editExpenseDelegate = self
        }
    }
    

}

