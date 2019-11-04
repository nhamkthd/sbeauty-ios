//
//  ViewController.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit
import iOSDropDown
class ViewController: UIViewController {
    
    let authentcation = SAuthentication();
    let spinerView = SpinnerViewController()
    var isBranchSelectd:Bool = false;
    
    @IBOutlet weak var branchDropDown: DropDown!
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
        self.branchDropDown.selectedRowColor = .white
        self.branchDropDown.optionArray = ["125 Trung Kính", "83 Thiền Hiền","Develop"];
        self.branchDropDown.optionIds=[0,1,2];
        self.branchDropDown.didSelect{(selectedText , index ,id) in
            print("Selected String: \(selectedText) \n index: \(index)");
            self.isBranchSelectd = true;
            let branchUserDefault = UserDefaults.standard;
            if index == 0 {
                branchUserDefault.set("http://45.77.174.252", forKey: Constants.BRANCH_HOST);
            } else if index == 1 {
                branchUserDefault.set("http://207.148.116.171", forKey: Constants.BRANCH_HOST);
            } else {
                branchUserDefault.set("http://45.77.174.252:8080", forKey: Constants.BRANCH_HOST);
            }
            branchUserDefault.synchronize();
        }
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
        if isBranchSelectd == false {
            self.errorLabel.isHidden = false;
            self.errorLabel.text = "Vui lòng chọn chi nhánh!";
            return;
        }
        let email = emailText.text;
        let password = passwordText.text;
        if email != "" && password != "" {
             showSpiner();
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
        } else {
            self.errorLabel.isHidden = false;
            self.errorLabel.text = "Email hoặc mật khẩu không được để trống!";
            return;
        }
    }

}

