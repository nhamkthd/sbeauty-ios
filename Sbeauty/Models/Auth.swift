//
//  Auth.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import Foundation

class Auth: NSObject, NSCoding {
    var access_token:String?
    var token_type:String?
    var expiry_date:Date?
    
    init(token:String?, tokenType:String? ,expiryDate:Date?) {
        self.access_token = token;
        self.token_type = tokenType;
        self.expiry_date = expiryDate;
    }

    required convenience init?(coder aDecoder: NSCoder) {
        let token = aDecoder.decodeObject(forKey: "access_token") as! String
        let token_type = aDecoder.decodeObject(forKey: "token_type") as! String
        let expiry_date = aDecoder.decodeObject(forKey: "expiry_date") as! Date
        self.init(token: token, tokenType: token_type, expiryDate: expiry_date);
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(access_token, forKey: "access_token")
        aCoder.encode(token_type, forKey: "token_type")
        aCoder.encode(expiry_date, forKey: "expiry_date")
    }
    
    func checkExpiryDate() -> Bool {
        if self.expiry_date != nil{
            let now = Date()
            if now < self.expiry_date! {
                return true;
            } else {
                return false;
            }
        }else{
            return false;
        }
    }
}
