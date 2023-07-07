//
//  AllReviewsTableViewController.swift
//  FIT3178-Assignment
//
//  Created by Eng Tan on 19/5/2023.
// Acknowledgement of using ChatGPT in this view controller
// Reference
// 1. "How to make table cell collapse and expand"
// 2. "How to make text with more number of lines after expanded"
//

import UIKit

class AllReviewsTableViewController: UITableViewController {
    
    // MARK: Empty variables for storing data from delegate
    var currentVenue: Venue?
    var reviews: [Reviews] = []
    var expandedIndexPaths: [IndexPath: Bool] = [:]
    
    weak var databaseController: DatabaseProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
        
        print(reviews)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reviews.count
    }

    /// Initialise the text to the corresponding label
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "allReviewsCell", for: indexPath) as! ReviewTableViewCell
        
        let review = reviews[indexPath.row]
        cell.ratingLabel.text = "\(review.rating ?? 0.0)/5⭐️"
        cell.commentLabel.text = review.text
        cell.commentLabel.numberOfLines = expandedIndexPaths[indexPath] ?? false ? 4 : 2
        
        if review.name == nil{
            cell.userName.text = "User"
        } else {
            cell.userName.text = review.name
        }
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
//        if expandedIndexPaths.contains(indexPath){
//            collapseRow(at: indexPath, in: tableView)
//        } else {
//            expandRow(at: indexPath, in: tableView)
//        }
        
        expandedIndexPaths[indexPath] = !(expandedIndexPaths[indexPath] ?? false)
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let isExpanded = expandedIndexPaths[indexPath] ?? false
        if isExpanded{
            return 150
        } else{
            return 100
        }
        
        
        
    }
    
//    func expandRow(at indexPath: IndexPath, in tableView: UITableView){
//        expandedIndexPaths.append(indexPath)
//        tableView.reloadRows(at: [indexPath], with: .automatic)
//    }
//
//    func collapseRow(at indexPath: IndexPath, in tableView: UITableView){
//        if let index = expandedIndexPaths.firstIndex(of: indexPath){
//            expandedIndexPaths.remove(at: index)
//            tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
//    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
