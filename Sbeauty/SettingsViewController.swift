//
//  SettingsViewController.swift
//  Sbeauty
//
//  Created by Aries on 11/13/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

private let reuseIdentifier = "SettingsCell"

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var tableView: UITableView!
    var userInfoHeader: UserInfoHeader!
    let spinerView = SpinnerViewController();
    let rest = RestManager();
    let apiDef = RestApiDefine();
    let auth = SAuthentication();
    var user:User?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        getUserInfo()
        
        // Do any additional setup after loading the view.
    }
    
   
    
    // MARK: - Helper Functions
    
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
    
    func configureTableView() {
        tableView = UITableView()
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.rowHeight = 60
        
        tableView.register(SettingsCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableView)
        tableView.frame = view.frame
        
        let frame = CGRect(x: 0, y: 88, width: view.frame.width, height: 100)
        userInfoHeader = UserInfoHeader(frame: frame)
        tableView.tableHeaderView = userInfoHeader
        tableView.tableFooterView = UIView()
    }
    
    func configureUI() {
        configureTableView()
        self.navigationItem.setHidesBackButton(true, animated:true);

    }
    
    // MARK: - Rest Api
    
    func getUserInfo() {
        showSpiner();
              guard let url = URL(string: apiDef.getApiStringUrl(apiName: .getMe)) else {
                  return;
              }
              let isAuth = auth.isLogged();
        if isAuth.0 {
            rest.requestHttpHeaders.add(value: "Bearer \(isAuth.1?.access_token ?? "")", forKey: "Authorization")
            rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type");
            rest.requestHttpHeaders.add(value: "XMLHttpRequest", forKey: "X-Requested-With");
            
            rest.makeRequest(toURL: url, withHttpMethod: .post, completion: {(results) in
                
                if results.response?.httpStatusCode == 200 {
                    if let data = results.data{
                        do {
                            let decoder = JSONDecoder()
                            let getUserData = try! decoder.decode(User.self, from: data)
                            self.user = getUserData;
                            DispatchQueue.main.async {
                                self.userInfoHeader.usernameLabel.text = getUserData.name;
                                self.userInfoHeader.emailLabel.text = getUserData.email;
                                self.removeSpiner();
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.removeSpiner();
                        let alertController = UIAlertController(title: "Alert", message: "Oops...something went wrong!.", preferredStyle: .alert)
                        let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                            print("You've pressed ok");
                        }
                        alertController.addAction(action1);
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            });
        }
    }
    
    
    // MARK: - Tableview extention
    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let section = SettingsSection(rawValue: section) else { return 0 }
        
        switch section {
        case .Social: return SocialOptions.allCases.count
        case .Communications: return CommunicationOptions.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = SColor().colorWithName(name:.pimary);
                
        let title = UILabel()
        title.font = UIFont.boldSystemFont(ofSize: 16)
        title.textColor = .white
        title.text = SettingsSection(rawValue: section)?.description
        view.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        title.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SettingsCell
        guard let section = SettingsSection(rawValue: indexPath.section) else { return UITableViewCell() }
        
        switch section {
        case .Social:
            let social = SocialOptions(rawValue: indexPath.row)
            cell.sectionType = social
        case .Communications:
            let communications = CommunicationOptions(rawValue: indexPath.row)
            cell.sectionType = communications
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = SettingsSection(rawValue: indexPath.section) else { return }
        
        switch section {
        case .Social:
            print(SocialOptions(rawValue: indexPath.row)?.description as Any)
            if indexPath.row == 1 {
                let alert = UIAlertController(title: "Đăng xuất khỏi ứng dụng", message:nil, preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {action in
                    if  self.auth.logout() {
                        self.performSegue(withIdentifier: "ShowLoginView", sender: self);
                    }
                }));
                alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)
            } else if indexPath.row == 0 {
                self.performSegue(withIdentifier: "ChangePasswordView", sender: self)
            }
        case .Communications:
            print(CommunicationOptions(rawValue: indexPath.row)?.description as Any)
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}


