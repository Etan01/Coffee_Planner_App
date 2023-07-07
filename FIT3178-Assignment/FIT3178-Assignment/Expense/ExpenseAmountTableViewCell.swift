//
//  ExpenseAmountTableViewCell.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 02/05/2023.
//

import UIKit

class ExpenseAmountTableViewCell: UITableViewCell {
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
