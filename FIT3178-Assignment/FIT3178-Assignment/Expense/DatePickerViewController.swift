//
//  DatePickerViewController.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 07/05/2023.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    weak var editExpenseDelegate: EditExpenseDelegate?
    
    var selectedDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.date = Date()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func dateChoose(_ sender: Any) {
        selectedDate = datePicker.date
    }
    
    @IBAction func saveDateValue(_ sender: Any) {
        if selectedDate == nil{
            selectedDate = Date()
        }
        editExpenseDelegate?.didSelectDate(selectedDate!)
        navigationController?.popViewController(animated: false)
        return
    }
    
}
