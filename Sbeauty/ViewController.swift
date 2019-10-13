//
//  ViewController.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let authentcation = SAuthentication();
    let spinerView = SpinnerViewController()
    @IBOutlet weak var errorLabel: UILabel!
    
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
    @IBOutlet weak var loginButton: SButton! {
        didSet {
            self.loginButton.buttonStyle = .pimary;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.errorLabel.textColor = SColor().colorWithName(name: .danger);
        self.errorLabel.isHidden = true;
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
        if email != "" && password != "" {
            self.authentcation.login(email: email!, password: password! ,completion:{(result,errMsg) in
                if result{
                    DispatchQueue.main.async() {
                        self.removeSpiner();
                        self.performSegue(withIdentifier: "ShowMainView", sender: self)
                    }
                }else {
                    DispatchQueue.main.async {
                        self.removeSpiner();
                        self.errorLabel.isHidden = false;
                        self.errorLabel.text = errMsg;
                    }
                }
            })
        }
    }

}

