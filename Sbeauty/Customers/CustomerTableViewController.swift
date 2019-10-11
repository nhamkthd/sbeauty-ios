//
//  CustomerTableViewController.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class CustomerTableViewController: UITableViewController {
    
    let rest = RestManager();
    let apiDef = RestApiDefine();
    let auth = SAuthentication();
    let spinerView = SpinnerViewController();
    var customers:[Customer]?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getListCustomers();
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    
    func getListCustomers() {
        showSpiner();
        guard let url = URL(string: apiDef.getApiStringUrl(apiName: .getCustomers)) else {
            return;
        }
        
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type");
        let isAuth = auth.isLogged();
        if isAuth.0 {
            rest.requestHttpHeaders.add(value: "\(isAuth.1?.token_type ?? "") \(isAuth.1?.access_token ?? "")", forKey: "Authorization")
        }
       
        rest.makeRequest(toURL: url, withHttpMethod: .get, completion: {(results) in
            if results.response?.httpStatusCode == 200 {
                if let data = results.data{
                    do {
                        let decoder = JSONDecoder()
                        let getCustomerData = try! decoder.decode(GetListCutomersData.self, from: data)
                        self.customers = getCustomerData.data?.data;
                        DispatchQueue.main.async {
                            self.tableView.reloadData();
                            self.removeSpiner();
                        }
                    }
                }
            }
        })
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if customers != nil {
            return self.customers!.count;
        }else {
            return 0;
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath)
    
       let customer:Customer = self.customers![indexPath.row]
        cell.textLabel?.text = customer.name;
        cell.detailTextLabel?.text = customer.phone;
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotos" {
            let viewController:CustomerPhotoViewController = segue.destination as! CustomerPhotoViewController
            let indexPath = self.tableView.indexPathForSelectedRow;
            viewController.customer = self.customers![(indexPath?.row)!];
            
        }
    }

}
