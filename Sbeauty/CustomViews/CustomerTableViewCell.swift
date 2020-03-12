//
//  CustomerTableViewCell.swift
//  Sbeauty
//
//  Created by Aries on 10/13/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class CustomerTableViewCell: UITableViewCell {

    @IBOutlet weak var customerProfile: UIImageView!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var customerPhone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customerProfile.layer.masksToBounds = false
        customerProfile.layer.borderColor = UIColor.black.cgColor
        customerProfile.layer.cornerRadius = customerProfile.frame.height/2
        customerProfile.clipsToBounds = true
        customerName.textColor = SColor().colorWithName(name: .mainText);
        customerPhone.textColor = SColor().colorWithName(name: .secondary);
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
