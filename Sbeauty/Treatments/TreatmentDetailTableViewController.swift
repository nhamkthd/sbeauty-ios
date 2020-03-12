//
//  TreatmentDetailTableViewController.swift
//  Sbeauty
//
//  Created by Aries on 11/24/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class TreatmentDetailTableViewController: UITableViewController {
    
    var treatment:Treatment!;
    let cellIndentifier = "TreatmentServiceCell";
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = treatment.customer?.name ?? "";
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return treatment.services.count;
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIndentifier, for: indexPath) as! TreatmentServiceTableViewCell
        let service = treatment.services[indexPath.row];
        cell.serviceName.text = service.service_name;
        
        if service.service_type == 1 {
            cell.bonus.isHidden = false;
            cell.bonus.text = service.bonus?.asLocaleCurrency;
            if service.employee_name?.count ?? 0 > 0 {
                cell.employeeNames.text = service.employee_name;
            }else {
                cell.employeeNames.text = "Chưa set KTV";
                cell.employeeNames.textColor = SColor().colorWithName(name: .secondary);
            }
        }else {
            cell.bonus.isHidden = true;
            cell.employeeNames.textColor = SColor().colorWithName(name: .warning);
            cell.employeeNames.text = "free";
        }

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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Double {
    var asLocaleCurrency:String {
        let formater = NumberFormatter();
        formater.numberStyle = .currency;
        formater.locale = Locale.current;
        return formater.string(from: NSNumber(value: self))!
    }
}
