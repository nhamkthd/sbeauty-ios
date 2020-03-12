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
        case getMe
        case getCustomers
        case getCustomerDetail
        case getCustomerPhotos
        case addCustomerPhotos
        case addCustomerProfilePicture
        case getTreatments
        case changePassword
        case deleteCustomerPhoto
        
    }

    func getApiStringUrl(apiName: AppApiName) -> String {
        var _host:String = "http://207.148.116.171";
        let sUserDefault =  UserDefaults.standard;
        if let serverIP = sUserDefault.value(forKey: Constants.SERVER_IP) {
            _host = serverIP as! String
        }
        switch apiName {
        case .login:
            return "\(_host)/api/auth/login";
        case .logout:
            return "\(_host)/api/auth/logout";
        case .getMe:
            return "\(_host)/api/auth/me";
        case .changePassword:
            return "\(_host)/api/auth/change-password";
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
        case .getTreatments:
            return "\(_host)/api/treatments/list";
        case .deleteCustomerPhoto:
            return "\(_host)/api/customers/delete-image";
        }
    }
}
