//
//  CustomerTableViewController.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/10/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class CustomerTableViewController: UITableViewController, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating  {
    
    let rest = RestManager();
    let apiDef = RestApiDefine();
    let auth = SAuthentication();
    let spinerView = SpinnerViewController();
    var customers:[Customer]?;
    let searchController = UISearchController(searchResultsController: nil)
    var lastKnowContentOfsset:CGFloat = 0;
    var lastPage:Int! = 1;
    var page:Int! = 1;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self;
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self;
        
        
        if #available(iOS 11.0, *) {
            // For iOS 11 and later, place the search bar in the navigation bar.
            navigationItem.searchController = searchController
            
            // Make the search bar always visible.
            navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            tableView.tableHeaderView = searchController.searchBar
        }

        getListCustomers(search: nil);
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
    
   
    func getListCustomers(search:String?) {
        showSpiner();
        guard let url = URL(string: apiDef.getApiStringUrl(apiName: .getCustomers)) else {
            return;
        }
        let isAuth = auth.isLogged();
        if isAuth.0 {
            rest.requestHttpHeaders.add(value: "Bearer \(isAuth.1?.access_token ?? "")", forKey: "Authorization")
            rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type");
            rest.requestHttpHeaders.add(value: "XMLHttpRequest", forKey: "X-Requested-With");
            
            if search != nil {
                rest.urlQueryParameters.add(value: search ?? "", forKey: "search");
            }
            rest.urlQueryParameters.add(value:"\(page ?? 1)", forKey: "page");
                       
            rest.makeRequest(toURL: url, withHttpMethod: .get, completion: {(results) in
                
                if results.response?.httpStatusCode == 200 {
                    if let data = results.data{
                        do {
                            let decoder = JSONDecoder()
                            let getCustomerData = try! decoder.decode(GetListCutomersData.self, from: data)
                            
                            if self.page ?? 1 > 1 {
                                self.customers?.append(contentsOf: getCustomerData.data!.data)
                            } else {
                                self.lastPage = getCustomerData.data?.last_page;
                                self.customers = getCustomerData.data?.data;
                            }
                            DispatchQueue.main.async {
                                self.tableView.reloadData();
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
    
    @IBAction func logoutOnClick(_ sender: Any) {
           let alert = UIAlertController(title: "Đăng xuất khỏi ứng dụng", message:nil, preferredStyle: .alert)

           alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: {action in
            if  self.auth.logout() {
                self.performSegue(withIdentifier: "ShowLoginView", sender: self);
            }
           }));
           alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

           self.present(alert, animated: true)
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomerCell", for: indexPath) as! CustomerTableViewCell;
    
       let customer:Customer = self.customers![indexPath.row]
        cell.customerName.text = customer.name;
        cell.customerPhone.text = customer.phone;
        if customer.avatar == "" || customer.avatar == nil{
            cell.customerProfile.image = UIImage(named: "default-profile");
        }else {
            cell.customerProfile.load(url: URL(string: customer.avatar!)!);
        }
        
        return cell
    }
    
    // MARK: - Searchbar controller
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print(searchText)
        if searchText.count > 2  || searchText.count == 0 {
            self.page = 1;
            self.getListCustomers(search: searchText)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            let contentOffset = scrollView.contentOffset.y
            if (contentOffset > self.lastKnowContentOfsset) {
                if self.page < lastPage {
                    self.page = self.page + 1;
                    self.getListCustomers(search: nil)
                }
                
            }
            print("\(self.page ?? 1)")
        }
    }
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView == self.tableView {
            self.lastKnowContentOfsset = scrollView.contentOffset.y
            print("lastKnowContentOfsset: ", scrollView.contentOffset.y)
        }
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
