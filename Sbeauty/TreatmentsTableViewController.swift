//
//  TreatmentsTableViewController.swift
//  Sbeauty
//
//  Created by Aries on 11/13/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit


class TreatmentsTableViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    let rest = RestManager();
    let apiDef = RestApiDefine();
    let auth = SAuthentication();
    let spinerView = SpinnerViewController();
    var treatments:[Treatment] = [];
    let treatmentCellIndentier = "TreatmentCell";
    let showDetailSegueId = "ShowTreatmentDetail";
    var searchController = UISearchController();
    var lastKnowContentOfsset:CGFloat = 0;
    var lastPage:Int! = 1;
    var page:Int! = 1;
    var selectedIndex:Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.searchController = ({
            let controller = UISearchController(searchResultsController: nil)
            controller.searchResultsUpdater = self
            controller.dimsBackgroundDuringPresentation = false
            controller.searchBar.sizeToFit()
            controller.searchResultsUpdater = self;
            controller.searchBar.autocapitalizationType = .none
            controller.searchBar.delegate = self;
            self.tableView.tableHeaderView = controller.searchBar
            
            return controller
            
        })()

//        getListTreatments(search: "");
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
    
    // MARK: - API function
    func getListTreatments(search:String?) {
        showSpiner();
        let getUrlString = apiDef.getApiStringUrl(apiName: .getTreatments)
        guard let url = URL(string: getUrlString) else {return}
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type");
        rest.requestHttpHeaders.add(value: "XMLHttpRequest", forKey: "X-Requested-With");
        if search != nil {
            rest.urlQueryParameters.add(value: search ?? "", forKey: "search");
        }
        rest.urlQueryParameters.add(value:"\(page ?? 1)", forKey: "page");
        let isAuth = auth.isLogged();
        if isAuth.0 {
            rest.requestHttpHeaders.add(value: "\(isAuth.1?.token_type ?? "") \(isAuth.1?.access_token ?? "")", forKey: "Authorization")
            rest.makeRequest(toURL: url, withHttpMethod: .get, completion: {(results) in
                if results.response?.httpStatusCode == 200 {
                    guard let data = results.data else { return }
                    do {
                        let decoder = JSONDecoder()
                        let getTreatmentData:TreatmentsData = try decoder.decode(TreatmentsData.self, from: data)
                        if self.page ?? 1 > 1 {
                            self.treatments.append(contentsOf: getTreatmentData.data.data)
                        } else {
                            self.lastPage = getTreatmentData.data.last_page;
                            self.treatments = getTreatmentData.data.data;
                        }
                        DispatchQueue.main.async {
                            self.removeSpiner()
                            self.tableView.reloadData();
                        }
                        
                        
                        
                    } catch {
                        print("Error when decoder treatment data...!")
                        DispatchQueue.main.async {
                            self.removeSpiner();
                            let alertController = UIAlertController(title: "Alert", message: "Can not decode response data.", preferredStyle: .alert)
                            let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                                print("You've pressed ok");
                            }
                            alertController.addAction(action1);
                            self.present(alertController, animated: true, completion: nil)
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return treatments.count
        return self.treatments.count;
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: treatmentCellIndentier, for: indexPath) as! TreatmentTableViewCell
        let treatmentItem:Treatment = self.treatments[indexPath.row]
        cell.customerName.text = treatmentItem.customer?.name;
        cell.createdDate.text = treatmentItem.created_at;
        if treatmentItem.status == 0 {
            cell.status.isHidden = false;
            cell.status.text = "new"
        }else {
            cell.status.isHidden = true;
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        self.performSegue(withIdentifier: showDetailSegueId, sender: self);
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
    
    // MARK: - Searchbar controller
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count > 1  || searchText.count == 0 {
            self.page = 1;
            self.getListTreatments(search: searchText);
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            let contentOffset = scrollView.contentOffset.y
            if (contentOffset > self.lastKnowContentOfsset) {
                if self.page < lastPage {
                    self.page = self.page + 1;
                    self.getListTreatments(search: nil)
                }
            }
            print("\(self.page ?? 1)")
        }
    }
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.tableView {
            self.lastKnowContentOfsset = scrollView.contentOffset.y
            if scrollView.contentOffset.y < -100 {
                self.getListTreatments(search: "");
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let controller:TreatmentDetailTableViewController = segue.destination as? TreatmentDetailTableViewController {
            controller.treatment = self.treatments[self.selectedIndex];
        }
    }
    

}
