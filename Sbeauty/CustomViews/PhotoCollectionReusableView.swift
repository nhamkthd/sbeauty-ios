//
//  PhotoCollectionReusableView.swift
//  Sbeauty
//
//  Created by Aries on 10/11/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class PhotoCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLbl:UILabel!
    @IBOutlet weak var addressLbl:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib();
        self.imageView.layer.cornerRadius = 80;
        self.imageView.layer.masksToBounds = true;
        self.nameLbl.textColor = SColor().colorWithName(name: .mainText)
        self.addressLbl.textColor = SColor().colorWithName(name: .secondary)
        
    }
}

