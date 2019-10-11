//
//  SColors.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/11/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import Foundation
import UIKit

class SColor {
    func colorWithName(name:ColorName) -> UIColor {
        switch name {
        case .pimary:
            return UIColor(red:0.00, green:0.59, blue:0.90, alpha:1.0);
       
        case .success:
            return UIColor(red:0.27, green:0.74, blue:0.20, alpha:1.0);
      
        case .warning:
            return UIColor(red:0.88, green:0.69, blue:0.17, alpha:1.0);
     
        case .danger:
            return UIColor(red:0.76, green:0.21, blue:0.09, alpha:1.0);
     
        case .secondary:
            return UIColor(red:0.44, green:0.50, blue:0.58, alpha:1.0);
        case .mainText:
            return UIColor(red:0.18, green:0.21, blue:0.25, alpha:1.0);
        default:
            return UIColor(red:0.96, green:0.96, blue:0.98, alpha:1.0);
        }
    }
}
