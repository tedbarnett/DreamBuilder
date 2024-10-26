//
//  PergolaModelCell.swift
//  DreamBuilder
//
//  Created by iMac on 22/10/24.
//

import UIKit

class PergolaModelCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewContainer: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewContainer.layer.shadowColor = UIColor.black.withAlphaComponent(0.31).cgColor
        viewContainer.layer.shadowOffset = .zero
        viewContainer.layer.shadowRadius = 4
        viewContainer.layer.shadowOpacity = 0.3
        viewContainer.layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
