
//
//  WishlistTableViewCell.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 21/05/2023.
//

import UIKit

class WishlistTableViewCell: UITableViewCell {

    @IBOutlet weak var isOpenedLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var wishlistImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
