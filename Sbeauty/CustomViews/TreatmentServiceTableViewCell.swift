//
//  TreatmentServiceTableViewCell.swift
//  Sbeauty
//
//  Created by Aries on 11/24/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class TreatmentServiceTableViewCell: UITableViewCell {

    @IBOutlet weak var serviceName: UILabel!
    @IBOutlet weak var employeeNames: UILabel!
    @IBOutlet weak var bonus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        serviceName.textColor = SColor().colorWithName(name: .mainText);
        employeeNames.textColor = SColor().colorWithName(name: .pimary);
        bonus.textColor = SColor().colorWithName(name: .success);
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
