//
//  TreatmentTableViewCell.swift
//  Sbeauty
//
//  Created by Aries on 11/17/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class TreatmentTableViewCell: UITableViewCell {
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var createdDate: UILabel!
    @IBOutlet weak var status: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customerName.textColor = SColor().colorWithName(name: .mainText);
        createdDate.textColor = SColor().colorWithName(name: .secondary);
        status.textColor = SColor().colorWithName(name: .pimary)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
