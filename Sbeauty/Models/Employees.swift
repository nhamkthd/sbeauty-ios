//
//  Employees.swift
//  Sbeauty
//
//  Created by Aries on 11/13/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import Foundation


struct User: Codable {
    var id:Int;
    var name:String;
    var email:String;
    var deleted_at:String?;
    var created_at:String?;
    var updated_at:String?
    var object_id:Int;
    var object_type:String;
}
