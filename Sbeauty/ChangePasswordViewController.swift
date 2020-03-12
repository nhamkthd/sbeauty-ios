//
//  ChangePasswordViewController.swift
//  Sbeauty
//
//  Created by Aries on 11/20/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmNewPassword: UITextField!
    @IBOutlet weak var errorMsg: UILabel!
    
    @IBOutlet weak var submitBtn: SButton!
    @IBOutlet weak var cancelBtn: SButton!
    
    let auth = SAuthentication();
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMsg.text = "";
        submitBtn.buttonStyle = .pimary;
        cancelBtn.buttonStyle = .secondary;
        self.navigationItem.title = "Đổi mật khẩu";
       

        // Do any additional setup after loading the view.
    }
    

    @IBAction func submitChangeOnClick(_ sender: Any) {
        errorMsg.text = "";
        if currentPassword.text == "" {
            errorMsg.text = "Mật khẩu hiện tại không được để trống.";
            return;
        }
        if newPassword.text == "" {
            errorMsg.text = "Mật khẩu mới không được để trống.";
            return;
        }
        
        if confirmNewPassword.text == "" {
            errorMsg.text = "Xác nhận mật khẩu mới không khớp với mật khẩu mới.";
            return;
        }
        auth.changePassword(oldPW: currentPassword.text ?? "", newPW: newPassword.text ?? "", confirmNewPW: confirmNewPassword.text ?? "", comletion: {(result, msg
            ) in
            if result {
                DispatchQueue.main.async {
                    self.errorMsg.text = "";
                    let alert = UIAlertController(title: "Đổi mật khẩu thành công!", message:nil, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {action in
                         self.performSegue(withIdentifier: "ShowSettingsView", sender: self);
                    }))
                                  
                    self.present(alert, animated: true)
                }
            }else{
                DispatchQueue.main.async {
                    self.errorMsg.text = msg;
                }
            }
        })
    }
    
    @IBAction func cancelChangeOnClick(_ sender: Any) {
        self.performSegue(withIdentifier: "ShowSettingsView", sender: self);
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if let mainViewController: MainViewController = segue.destination as? MainViewController {
            mainViewController.selectedIndex = 2;
            mainViewController.navigationItem.title = "Cài đặt";
        }
        
    }
    

}
