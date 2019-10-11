//
//  Authentication.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/11/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import Foundation

class SAuthentication  {
    var rest = RestManager();
    var apiDef = RestApiDefine();
    
    func login(email:String, password:String, completion: @escaping (_ result: Bool) -> Void) {
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.httpBodyParameters.add(value: email, forKey: "email");
        rest.httpBodyParameters.add(value: password, forKey: "password");
        rest.makeRequest(toURL: URL(string:apiDef.getApiStringUrl(apiName: .login) )!, withHttpMethod: .post) { (results) in
            if results.response?.httpStatusCode == 200{
                
                guard let data = results.data else { return }
                do {
                    let jsonRes =  try JSONSerialization.jsonObject(with: data, options: [])
                    if let object = jsonRes as? [String : Any] {
                        if let access_token = object["access_token"] as? String {
                            print("Login success - access_token : \(access_token)")
                            let now = Date()
                            if let expires_in = object["expires_in"] as? Double {
                                let expiry_date = now.addingTimeInterval(expires_in)
                                let auth = Auth(token: access_token, tokenType: object["token_type"] as? String, expiryDate:expiry_date);
                                let accessTokenUserDefault = UserDefaults.standard;
                                let authData = try NSKeyedArchiver.archivedData(withRootObject: auth, requiringSecureCoding: false) as Data;
                                accessTokenUserDefault.set(authData, forKey:Constants.AUTHENTICATION_USER_DEFAULT );
                                accessTokenUserDefault.synchronize();
                                completion(true)            
                            }
                            
                        }
                        
                        return ;
                    }
                } catch let parsingError {
                    print("Error: \(parsingError)")
                    completion(false)
                }
            }
        }
    }
    
    func logout() {
      
            
        
    }
    
    func isLogged() -> (Bool,Auth?) {
        let userDefault = UserDefaults.standard;
        let authData = userDefault.object(forKey: Constants.AUTHENTICATION_USER_DEFAULT);
        var result:(Bool,Auth?) = (false,nil);
        if authData != nil {
            let auth = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(authData as! Data) as? Auth;
            if auth?.access_token != nil {
                if auth!.checkExpiryDate(){
                    result = (true,auth);
                }
            }
        }
        return result;
    }
}
