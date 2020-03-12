//
//  MainViewController.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
         self.navigationController?.navigationBar.tintColor = SColor().colorWithName(name: .pimary)
        self.navigationItem.title  = "Khách hàng";
        
        // Do any additional setup after loading the view.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item == (self.tabBar.items!)[0] {
//            self.navigationItem.title  = "Phiếu điều trị";
             self.navigationItem.title  = "Khách hàng";
        }else  if item == (self.tabBar.items!)[1] {
            self.navigationItem.title  = "Cài đặt";
//            self.navigationItem.title  = "Khách hàng";
        } else  if item == (self.tabBar.items!)[2] {
            self.navigationItem.title  = "Cài đặt";
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
