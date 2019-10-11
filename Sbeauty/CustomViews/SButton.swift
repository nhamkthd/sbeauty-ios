//
//  Sbutton.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class SButton: UIButton {

    var buttonStyle:ColorName!;

    private var roundRectLayer: CAShapeLayer?
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.roundRectColor = SColor().colorWithName(name: self.buttonStyle);
        switch self.buttonStyle {
        case .info?, .pimary?, .success?:
            self.tintColor = .white;
            break;
        default:
            self.tintColor = SColor().colorWithName(name: .mainText);
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).cgPath
        shapeLayer.fillColor = roundRectColor.cgColor
        self.layer.insertSublayer(shapeLayer, at: 0)
        self.roundRectLayer = shapeLayer
    }
    
    // MARK: Public interface
    /// Corner radius of the background rectangle
    public var roundRectCornerRadius: CGFloat = 8 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// Color of the background rectangle
    public var roundRectColor: UIColor! {
        didSet {
            self.setNeedsLayout()
        }
    }

}
