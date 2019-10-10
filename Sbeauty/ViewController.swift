//
//  ViewController.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit
let USER_LOGIN_KEY = "USER_LOGIN_KEY";
class ViewController: UIViewController {
    
    var rest = RestManager();
    var apiDef = RestApiDefine();
    let spinerView = SpinnerViewController()

    @IBOutlet weak var emailText: STextField! {
        didSet{
            self.emailText.setIcon(UIImage(named: "icons8-user")!);
        }
    }
    @IBOutlet weak var passwordText: STextField! {
        didSet{
            self.passwordText.setIcon(UIImage(named: "icons8-lock")!);
        }
    }
    @IBOutlet weak var loginButton: SButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func showSpiner() {
        self.addChild(spinerView);
        spinerView.view.frame = self.view.frame;
        self.view.addSubview(spinerView.view);
        spinerView.didMove(toParent: self)
    }
    
    func removeSpiner() {
        spinerView.willMove(toParent: nil)
        spinerView.view.removeFromSuperview();
        spinerView.removeFromParent();
    }
  
    @IBAction func loginOnClick(_ sender: Any) {
        showSpiner();
        let email = emailText.text;
        let password = passwordText.text;
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type")
        rest.httpBodyParameters.add(value: email!, forKey: "email");
        rest.httpBodyParameters.add(value: password!, forKey: "password");
        rest.makeRequest(toURL: URL(string:apiDef.getApiStringUrl(apiName: .login) )!, withHttpMethod: .post) { (results) in
            if results.response?.httpStatusCode == 200{
                guard let data = results.data else { return }
                do {
                    let jsonRes =  try JSONSerialization.jsonObject(with: data, options: [])
                    if let object = jsonRes as? [String : Any] {
                        if let access_toke = object["access_token"] as? String {
                            print(access_toke)
                            let accessTokenUserDefault = UserDefaults.standard;
                            accessTokenUserDefault.set(object, forKey: USER_LOGIN_KEY);
                            DispatchQueue.main.async {
                                self.removeSpiner();
                            }
                        }
                        
                        return ;
                    }
                } catch let parsingError {
                    print("Error: \(parsingError)")
                    
                }
            }
            
        }
    }
}

