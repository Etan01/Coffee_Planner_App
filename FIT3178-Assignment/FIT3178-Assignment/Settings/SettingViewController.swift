//
//  SettingViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 25/04/2023.
//

import UIKit
import Firebase

class SettingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectCurrencyDelegate {
        
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    weak var databaseController: DatabaseProtocol?
    
    var authController: Auth?
    var authStateListener: AuthStateDidChangeListenerHandle?

    let sectionTitle = ["General", "Theme", "Helps and Support"]
    
    let generalCellTitles = ["Currency"]
    let themeCellTitles = ["Dark Theme"]
    let helpCellTitles = ["About Us"]
    
    var selectedCurrency: Currency?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: "settingsCell")
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        // Do any additional setup after loading the view.
        
        if let email = UserSession.shared.email{
            userEmail.text = email
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitle.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
           case 0:
               return generalCellTitles.count
            case 1:
                return themeCellTitles.count
            case 2:
                return helpCellTitles.count
           default:
               return 0
           }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath) //as! SettingsTableViewCell
            switch indexPath.section {
            case 0:
                var content = cell.defaultContentConfiguration()
                content.text = generalCellTitles[indexPath.row]
                content.secondaryText = selectedCurrency?.symbol
                cell.contentConfiguration = content
            case 1:
                cell.textLabel?.text = themeCellTitles[indexPath.row]
            case 2:
                cell.textLabel?.text = helpCellTitles[indexPath.row]
            default:
                break
            }
            return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected cell
        
        // Perform a segue based on the selected cell
        switch indexPath.section{
        case 0:
//            let profileVC = CurrencyTableTableViewController()
//            navigationController?.pushViewController(profileVC, animated: true)
            performSegue(withIdentifier: "showCurrencyOptionSegue", sender: self)
        case 1:
            performSegue(withIdentifier: "showThemeSegue", sender: self)
        case 2:
            performSegue(withIdentifier: "aboutUsSegue", sender: self)
        default:
            break
        }
    }

    @IBAction func logOutFunction(_ sender: Any) {
        databaseController!.signOutUser()
        UserSession.shared.email = nil
//        navigationController?.popToRootViewController(animated: true)
//        tabBarController?.setViewControllers([], animated: true)
        if let navController = self.navigationController?.tabBarController?.navigationController {
            navController.popToRootViewController(animated: true)
        }
    }
    
    func selectCurrency(currency: Currency) {
        self.selectedCurrency = currency
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)){
            cell.detailTextLabel?.text = selectedCurrency?.symbol
            self.tableView.reloadSections([0, 0], with: .automatic)
        }
        
        UserSession.shared.currency = currency
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "logoutSegue" {
            let destinationVC = segue.destination
            destinationVC.navigationItem.setHidesBackButton(true, animated: false)
            
        } else if segue.identifier == "showCurrencyOptionSegue"{
            let destination = segue.destination as! CurrencyTableTableViewController
            destination.currencyDelegate = self
        }
    }
    

}
