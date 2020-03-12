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
    
    func login(email:String, password:String, serverIP:String, completion: @escaping (_ result: Bool, _ errMsg:String?) -> Void) {
        if serverIP != "" {
            let sUserDefault = UserDefaults.standard;
            sUserDefault.set(serverIP, forKey: Constants.SERVER_IP);
            sUserDefault.synchronize();
        }
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.httpBodyParameters.add(value: email, forKey: "email");
        rest.httpBodyParameters.add(value: password, forKey: "password");
        rest.makeRequest(toURL: URL(string:apiDef.getApiStringUrl(apiName: .login) )!, withHttpMethod: .post) { (results) in
            if results.response?.httpStatusCode == 200 {
                
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
                                completion(true,"success")
                            }
                            
                        }
                        
                        return ;
                    }
                } catch let parsingError {
                    print("Error: \(parsingError)")
                    completion(false," \(parsingError)");
                }
            } else if results.response?.httpStatusCode == 401 {
                completion(false,"Sai email hoặc mật khẩu!");
            }
        }
    }
    
    func changePassword(oldPW:String, newPW:String, confirmNewPW:String, comletion: @escaping (_ result: Bool, _ msg:String)->Void) {
        let getUrlString = apiDef.getApiStringUrl(apiName: .changePassword)
        guard let url = URL(string: getUrlString) else {return}
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type");
        rest.requestHttpHeaders.add(value: "XMLHttpRequest", forKey: "X-Requested-With");
        rest.httpBodyParameters.add(value: oldPW, forKey: "current_password");
        rest.httpBodyParameters.add(value: newPW, forKey: "new_password");
        rest.httpBodyParameters.add(value: confirmNewPW, forKey: "new_confirm_password");
        let isAuth = self.isLogged();
        if isAuth.0 {
            rest.requestHttpHeaders.add(value: "\(isAuth.1?.token_type ?? "") \(isAuth.1?.access_token ?? "")", forKey: "Authorization")
            rest.makeRequest(toURL: url, withHttpMethod: .post, completion: {(results) in
                if results.response?.httpStatusCode == 200 {
                    comletion(true,"success");
                } else {
                    guard let data = results.data else { return }
                    do {
                        let resDict =  try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any];
                        if let msg:String = resDict!["message"] as? String {
                            comletion(false,msg)
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            });
        }
        
    }
    
    func logout() -> Bool{
        let userDefault = UserDefaults.standard;
        userDefault.removeObject(forKey: Constants.AUTHENTICATION_USER_DEFAULT);
        return true;
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
