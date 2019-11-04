//
//  PhotoCollectionReusableView.swift
//  Sbeauty
//
//  Created by Aries on 10/11/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

let borderColor:UIColor = UIColor(red:0.74, green:0.76, blue:0.78, alpha:1.0);


class PhotoCollectionReusableView: UICollectionReusableView, UITableViewDelegate, UITableViewDataSource {
        
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLbl:UILabel!
    @IBOutlet weak var addressLbl:UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var birthdayLbl: UILabel!
    @IBOutlet weak var genderLbl: UILabel!
    
    @IBOutlet weak var profileTitleView: UIView!
    @IBOutlet weak var photoTileView: UIView!
      @IBOutlet weak var servicesTitleView: UIView!
    
    @IBOutlet weak var servicesTableView: UITableView!
    
    var services:[Services] = [];
    
    override func awakeFromNib() {
        super.awakeFromNib();
        self.imageView.layer.cornerRadius = 80;
        self.imageView.layer.masksToBounds = true;
        self.nameLbl.textColor = SColor().colorWithName(name: .mainText)
        self.addressLbl.textColor = SColor().colorWithName(name: .secondary)
        self.phoneLbl.textColor = SColor().colorWithName(name: .secondary)
        self.genderLbl.textColor = SColor().colorWithName(name: .secondary)
        self.birthdayLbl.textColor = SColor().colorWithName(name: .secondary)
        
        self.photoTileView.addBorder(side: .top, color: borderColor, width: 0.5)
        self.profileTitleView.addBorder(side: .top, color:borderColor, width: 0.5)
        self.servicesTitleView.addBorder(side: .top, color:borderColor, width: 0.5)
        
        self.servicesTableView.separatorInset = UIEdgeInsets(top: 0, left:0, bottom: 0, right: 0)
        self.servicesTableView.separatorColor = UIColor.clear;
        self.servicesTableView.separatorStyle = .none;
        self.servicesTableView.delegate = self;
        self.servicesTableView.dataSource = self;
        NotificationCenter.default
            .addObserver(self,
                         selector: #selector(getDetailSuccess),
                         name: NSNotification.Name ("customer.get.detail"),object: nil)
        
    }
    
    @objc func getDetailSuccess(_ notification: Notification){
        if let data = notification.userInfo?["Services"] {
            self.services = data as! [Services];
            DispatchQueue.main.async {
                self.servicesTableView.reloadData();
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count > 0 ? services.count : 1;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  services.count > 0 ? 40 : 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell", for: indexPath) as! CustomerServiceTableViewCell
     
        if services.count > 0  {
            cell.nameLbl.text = services[indexPath.row].name;
            cell.quantityLbl?.textColor = SColor().colorWithName(name:.pimary)
            cell.quantityLbl?.text =  "\(services[indexPath.row].use_quantity)/\(services[indexPath.row].quantity)";
        }else {
            cell.nameLbl?.text = "Khách hàng chưa đăng ký dịch vụ nào...";
            cell.nameLbl?.textColor = SColor().colorWithName(name:.mainText)
            cell.quantityLbl?.text = "";
           
        }
        return cell;
    }
}




extension UIView {
    public func addBorder(side: BorderSide, color: UIColor, width: CGFloat) {
        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = color
        self.addSubview(border)

        let topConstraint = topAnchor.constraint(equalTo: border.topAnchor)
        let rightConstraint = trailingAnchor.constraint(equalTo: border.trailingAnchor)
        let bottomConstraint = bottomAnchor.constraint(equalTo: border.bottomAnchor)
        let leftConstraint = leadingAnchor.constraint(equalTo: border.leadingAnchor)
        let heightConstraint = border.heightAnchor.constraint(equalToConstant: width)
        let widthConstraint = border.widthAnchor.constraint(equalToConstant: width)


        switch side {
        case .top:
            NSLayoutConstraint.activate([leftConstraint, topConstraint, rightConstraint, heightConstraint])
        case .right:
            NSLayoutConstraint.activate([topConstraint, rightConstraint, bottomConstraint, widthConstraint])
        case .bottom:
            NSLayoutConstraint.activate([rightConstraint, bottomConstraint, leftConstraint, heightConstraint])
        case .left:
            NSLayoutConstraint.activate([bottomConstraint, leftConstraint, topConstraint, widthConstraint])
        }
    }
}
