//
//  SearchTableViewCell.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 01/05/2023.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cafeImage: UIImageView!
    @IBOutlet weak var cafeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
