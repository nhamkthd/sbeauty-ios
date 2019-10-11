//
//  ViewController.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var rest = RestManager();
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
        rest.makeRequest(toURL: URL(string: "http://45.77.174.252:8080/api/auth/login")!, withHttpMethod: .get) { (results) in
            if results.response?.httpStatusCode == 200{
                if let data = results.data   {
                    DispatchQueue.main.async {
                        self.removeSpiner();
                    }
                    do {
                        let authJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        if let authObject = authJSON as? [String:Any] {
                            print(authObject)
                        }
                    } catch {
                        return
                    }
                    
                }
            }
           
        }
    }
}

