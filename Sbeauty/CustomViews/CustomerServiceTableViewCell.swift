//
//  CustomerServiceTableViewCell.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/28/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class CustomerServiceTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl:UILabel!
    @IBOutlet weak var quantityLbl:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
