//
//  NearbyTableViewCell.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 16/05/2023.
//

import UIKit

class NearbyTableViewCell: UITableViewCell {
    
    var selectedLocation: Venue?

    @IBOutlet weak var locationRating: UILabel!
    @IBOutlet weak var locationName: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
