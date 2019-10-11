//
//  CustomerPhotoViewController.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/11/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class CustomerPhotoViewController: UIViewController,ImagePickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    let rest = RestManager();
    let apiDef = RestApiDefine();
    let auth = SAuthentication();
    let spinerView = SpinnerViewController();
    var imagePicke:SImagePicker!
    var customer:Customer?;
    var photos:[Photo] = [];
    var photoListKeys:[String] = [];
    var photoCollections:[String: [Photo]] = [:];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicke = SImagePicker(presentationController: self, delegate: self)
        self.nameLabel.text = self.customer?.name;
        self.addressLabel.text = self.customer?.address;
        getPhots();
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
    func getPhots() {
        
        showSpiner()
        let getUrlString = apiDef.getApiStringUrl(apiName: .getCustomerPhotos)
        guard let url = URL(string:  getUrlString.appending("/\(self.customer?.id ?? 0)")) else {return}
        rest.requestHttpHeaders.add(value: "application/json", forKey: "Content-Type");
        let isAuth = auth.isLogged();
        if isAuth.0 {
            rest.requestHttpHeaders.add(value: "\(isAuth.1?.token_type ?? "") \(isAuth.1?.access_token ?? "")", forKey: "Authorization")
        }
        
        rest.makeRequest(toURL: url, withHttpMethod: .get, completion: {(results) in
            if results.response?.httpStatusCode == 200 {
                if let data = results.data{
                    do {
                        let jsonRes =  try JSONSerialization.jsonObject(with: data, options: [])
                        if let object = jsonRes as? [String : Any] {
                            if let photosDict = object["data"] as? [String: Any]{
                                for key  in photosDict.keys {
                                    self.photoListKeys.append(key)
                                    if let photoDict = photosDict[key] as? Any {
//                                        let photo = Photo(dictionary: photoDict);
//                                        self.photoCollections[key]?.append(photo);
                                    }
                                }
//                                self.photoCollections = photosDict
                                DispatchQueue.main.async {
                                    self.removeSpiner();
                                    self.photosCollectionView.reloadData();
                                }
                            }
                        }
                    } catch let error {
                        print(error)
                    }
                }
            }
        });
    }
    
    func generateBoundaryString() -> String
    {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
   
    func postPhoto(image:UIImage?) {
      
        guard let url = URL(string:apiDef.getApiStringUrl(apiName: .addCustomerPhotos) ) else {return}
        
        let boundary = generateBoundaryString();
        rest.requestHttpHeaders.add(value: "multipart/form-data; boundary=\(boundary)", forKey: "Content-Type");
        let isAuth = auth.isLogged();
        if isAuth.0 {
            rest.requestHttpHeaders.add(value: "\(isAuth.1?.token_type ?? "") \(isAuth.1?.access_token ?? "")", forKey: "Authorization")
        }
        
        rest.makeRequest(toURL: url, withHttpMethod: .post, completion: {(results) in
            
        });
    }
    
    
    @IBAction func takePhotoOnClick(_ sender: Any) {
        self.imagePicke.present(from: self.view)
    }
    
    func didSelect(image: UIImage?) {
        self.profileImage.image = image;
    }
    
     // MARK: - Collection views
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.photoListKeys.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoCollections[self.photoListKeys[section]]!.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for:indexPath)
        cell.backgroundColor = .black
        let key = self.photoListKeys[indexPath.row];
       
//        if  let collection = self.photoCollections[key]  as? [String:Any] {
//
//        }
        // Configure the cell
        return cell
    }
    
    private func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let headerCell = (collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PhotoHeaderCell", for: indexPath as IndexPath))
        
       // let headerCell = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "PhotoHeaderCell", forIndexPath: indexPath) as? UICollectionReusableView
        
        return headerCell;
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
