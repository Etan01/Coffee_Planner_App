//
//  SettingsTableViewCell.swift
//  FIT3178-Assignment
//
//  Created by Tan Eng Teck on 25/04/2023.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detail: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray2
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            addSubview(titleLabel)
            addSubview(detail)
            
            // Constraints for the title label
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
            detail.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
            detail.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            detail.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 8).isActive = true
            detail.setContentHuggingPriority(.required, for: .horizontal)
        
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
