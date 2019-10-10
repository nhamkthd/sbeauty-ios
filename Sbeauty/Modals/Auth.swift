//
//  Auth.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import Foundation

struct AuthResponse: Codable {
    var access_token:String?
    var token_type:String?
    var expires_in:Int?
    
}
