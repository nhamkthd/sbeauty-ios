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
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var birthdayLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    
    @IBOutlet weak var profileTitleView: UIView!
    @IBOutlet weak var photoTileView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib();
        self.imageView.layer.cornerRadius = 80;
        self.imageView.layer.masksToBounds = true;
        self.nameLbl.textColor = SColor().colorWithName(name: .mainText)
        self.addressLbl.textColor = SColor().colorWithName(name: .secondary)
        self.phoneLbl.textColor = SColor().colorWithName(name: .secondary)
        self.genderLbl.textColor = SColor().colorWithName(name: .secondary)
        self.birthdayLbl.textColor = SColor().colorWithName(name: .secondary)
        self.photoTileView.addBorder(side: .bottom, color: SColor().colorWithName(name: .secondary), width: 0.5)
        self.profileTitleView.addBorder(side: .bottom, color: SColor().colorWithName(name: .secondary), width: 0.5)
        
    }
}

extension UIView {
    public func addBorder(side: BorderSide, color: UIColor, width: CGFloat) {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = color
        self.addSubview(border)

        let topConstraint = topAnchor.constraint(equalTo: border.topAnchor)
        let rightConstraint = trailingAnchor.constraint(equalTo: border.trailingAnchor)
        let bottomConstraint = bottomAnchor.constraint(equalTo: border.bottomAnchor)
        let leftConstraint = leadingAnchor.constraint(equalTo: border.leadingAnchor)
        let heightConstraint = border.heightAnchor.constraint(equalToConstant: width)
        let widthConstraint = border.widthAnchor.constraint(equalToConstant: width)


        switch side {
        case .top:
            NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
        case .right:
            NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
        case .bottom:
            NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
        case .left:
            NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
        }
    }
}
