//
//  RestApidefine.swift
//  S-Beauty
//
//  Created by Aries on 9/29/19.
//  Copyright © 2019 Aries. All rights reserved.
//

import Foundation

class RestApiDefine {
    
    let _host = "http://45.77.174.252:8080";
    
    enum AppApiName: String {
        case login
        case logout
        case getCustomers
        case getCustomerDetail
        case getCustomerPhotos
        case addCustomerPhotos
        
    }

    func getApiStringUrl(apiName: AppApiName) -> String {
        switch apiName {
        case .login:
            return "\(_host)/api/auth/login";
        case .logout:
            return "\(_host)/api/auth/logout";
        case .getCustomers:
            return  "\(_host)/api/customers";
        case .getCustomerPhotos:
            return "\(_host)/api/customers/list-image";
        case .getCustomerDetail:
            return "\(_host)";
        default:
            return ""
        }
    }
}
