//
//  RestApidefine.swift
//  S-Beauty
//
//  Created by Aries on 9/29/19.
//  Copyright © 2019 Aries. All rights reserved.
//

import Foundation

class RestApiDefine {
    
   
    
    enum AppApiName: String {
        case login
        case logout
        case getCustomers
        case getCustomerDetail
        case getCustomerPhotos
        case addCustomerPhotos
        case addCustomerProfilePicture
        
    }

    func getApiStringUrl(apiName: AppApiName) -> String {
        var _host:String = "http://45.77.174.252:8080";
        let branchUserDefault =  UserDefaults.standard;
        if let branchHost = branchUserDefault.value(forKey: Constants.BRANCH_HOST) {
            _host = branchHost as! String
        }
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
            return "\(_host)/api/customers";
        case .addCustomerPhotos:
            return "\(_host)/api/customers/upload-image";
        case .addCustomerProfilePicture:
            return "\(_host)/api/customers/";
        }
    }
}
