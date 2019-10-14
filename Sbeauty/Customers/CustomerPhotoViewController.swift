//
//  CustomerPhotoViewController.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/11/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit
import Alamofire;
import DKImagePickerController;

class CustomerPhotoViewController: UIViewController,ImagePickerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var photosCollectionView: UICollectionView!

    
    let rest = RestManager();
    let apiDef = RestApiDefine();
    let auth = SAuthentication();
    let spinerView = SpinnerViewController();
    var viewPhotoController:ViewPhotoViewController?
    var imagePicke:SImagePicker!
    var customer:Customer?;
    var photos:[Photo] = [];
    var photoListKeys:[String] = [];
    var photoCollections:[String: [Photo]] = [:];
    var alert:UIAlertController?;
    var isPostPhotos:Bool = true;
    var isUploading:Bool = false;
    
    let dkimagePickerController =  DKImagePickerController();
    
    var exportManually = false
    
    var assets: [DKAsset]?
    
    // MARK: - init views
    deinit {
        DKImagePickerControllerResource.customLocalizationBlock = nil
        DKImagePickerControllerResource.customImageBlock = nil
        
        DKImageExtensionController.unregisterExtension(for: .camera)
        DKImageExtensionController.unregisterExtension(for: .inlineCamera)
        
        DKImageAssetExporter.sharedInstance.remove(observer: self)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicke = SImagePicker(presentationController: self, delegate: self)
        
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeProfilePictureOnClick(tapGestureRecognizer:)))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
        if self.customer?.avatar == nil || self.customer?.avatar == "" {
            profileImage.image = UIImage(named: "default-profile");
        } else {
            profileImage.load(url: URL(string: self.customer!.avatar!)!);
        }
        self.nameLabel.textColor = SColor().colorWithName(name: .mainText);
        self.nameLabel.text = self.customer?.name;
        self.addressLabel.textColor = SColor().colorWithName(name: .secondary);
        self.addressLabel.text = self.customer?.address;
        self.photosCollectionView.delegate = self;
        self.photosCollectionView.dataSource = self;
        //Define Layout here
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        //Get collectionview width
        let width = self.view.frame.width;
        
        //set section inset as per your requirement.
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        //set cell item size here
        layout.itemSize = CGSize(width: width / 3 - 7, height: 120)
        
        //set Minimum spacing between 2 items
        layout.minimumInteritemSpacing = 4
        
        //set minimum vertical line spacing here between two lines in collectionview
        layout.minimumLineSpacing = 4
        self.photosCollectionView.collectionViewLayout = layout;
        
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
    func showLoadingAlert() {
        self.alert = UIAlertController(title: nil, message: "uploading...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        self.alert!.view.addSubview(loadingIndicator)
        self.alert?.view.subviews.first?.isUserInteractionEnabled = true;
        self.alert?.view.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissUploadingAlert)))
        self.present(self.alert!, animated: true, completion: nil);
        self.isUploading = true;
    }
    
    @objc func dismissUploadingAlert() {
        self.alert?.dismiss(animated: false, completion: nil)
        self.isUploading = false;
    }
    
    // MARK: - rest api request
    
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
                DispatchQueue.main.async {
                    self.removeSpiner();
                }
                if let data = results.data{
                    do {
                        let jsonRes =  try JSONSerialization.jsonObject(with: data, options: [])
                        if let object = jsonRes as? [String : Any] {
                            if let photosDict = object["data"] as? [String: Any]{
                                for key  in photosDict.keys {
                                    self.photoListKeys.append(key)
                                    if let objects = photosDict[key] as? [Any] {
                                        var photos:[Photo] = [];
                                        for object in objects {
                                            print(object);
                                            if let photoObject = object as? [String:Any] {
                                                
                                                let photo = Photo(dictionary:photoObject);
                                                photos.append(photo);
                                            }
                                            
                                        }
                                        self.photoCollections[key] = photos;
                                    }
                                }
                                DispatchQueue.main.async {
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
    
    
    func postPhoto(images:[UIImage], url:URL) {
        
        let isAuth = auth.isLogged();
        if isAuth.0 {
            rest.requestHttpHeaders.add(value: "\(isAuth.1?.token_type ?? "") \(isAuth.1?.access_token ?? "")", forKey: "Authorization")
            let headersInfo : HTTPHeaders = [ "Content-Type" : "multipart/form-data",
                                              "Accept" : "application/json",
                                              "Authorization" :"Bearer \(isAuth.1!.access_token!)",
            ]
            
            showLoadingAlert();
            AF.upload(multipartFormData: {multipartFromData in
                if self.isPostPhotos {
                    for image in images {
                        multipartFromData.append(image.jpegData(compressionQuality: 0.5)!, withName: "image[]");
                    }
                    multipartFromData.append("\(self.customer?.id ?? 0)".data(using: .utf8)!, withName: "customer_id");
                }else {
                    multipartFromData.append(images[0].jpegData(compressionQuality: 0.5)!, withName: "image");
                }
            }, to: url,
               method: .post,
               headers: headersInfo,
               interceptor: nil,
               fileManager: .default).response(completionHandler: {(response) in
                
                switch response.result {
                case .success(let data):
                    do {
                        let jsonRes =  try! JSONSerialization.jsonObject(with: data!, options: [])
                        if let object = jsonRes as? [String : Any] {
                            if let rest = object["data"] as? String{
                                print(rest);
                                DispatchQueue.main.async {
                                    self.dismissUploadingAlert();
                                    if self.isPostPhotos {
                                        self.photoListKeys.removeAll();
                                        self.photoCollections.removeAll();
                                        if self.isUploading == false {
                                            self.getPhots();
                                        }
                                    }
                                }
                            } else  if let rest = object["message"] as? String {
                                print(rest)
                                let url = URL(string: rest);
                                self.profileImage.load(url: url!);
                            }
                        }
                    }
                    break;
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        self.dismissUploadingAlert();
                    }
                    break;
                    
                }
                
               });
            
        }
        
    }
    
    // MARK: - actions
    
    @IBAction func takePhotoOnClick(_ sender: Any) {
        isPostPhotos = true;
        self.showDKImagePicker()
        
    }
    
    @objc func changeProfilePictureOnClick(tapGestureRecognizer: UITapGestureRecognizer) {
        isPostPhotos  = false;
        self.imagePicke.present(from: self.view, title: "Thay ảnh đại diện")
    }
    
    // MARK: - dkimagepicker
    
    func didSelect(image: UIImage?) {
        if image == nil  {
            return;
        }
        var images:[UIImage] = [];
        images.append(image!);
        let url = URL(string: "\(apiDef.getApiStringUrl(apiName: .addCustomerProfilePicture))\(self.customer?.id ?? 0)/upload-avatar")!
        self.postPhoto(images: images, url: url);
        
    }
    func updateAssets(assets: [DKAsset]) {
        print("didSelectAssets")
        
        self.assets = assets
        let url = URL(string: apiDef.getApiStringUrl(apiName: .addCustomerPhotos))!
        var images:[UIImage] = [];
    
        for asset in assets {
            asset.fetchOriginalImage(completeBlock: {image, info in
                if let img = image{
                    images.append(img);
                    if images.count == assets.count {
                        self.postPhoto(images: images, url: url);
                    }
                }
            })
        }
      

    }
    
    
    
    func showDKImagePicker() {
        
        if self.exportManually {
            DKImageAssetExporter.sharedInstance.add(observer: self)
        }
        
        if let assets = self.assets {
            dkimagePickerController.select(assets: assets)
        }
        
        dkimagePickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            self.updateAssets(assets: assets)
        }
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            dkimagePickerController.modalPresentationStyle = .formSheet
        }
        
        if dkimagePickerController.UIDelegate == nil {
            dkimagePickerController.UIDelegate = AssetClickHandler()
        }
        
        self.present(dkimagePickerController, animated: true) {}
        
    }
    
    // MARK: - Collection views
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.photoListKeys.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.photoCollections[self.photoListKeys[section]]!.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for:indexPath) as! PhotoCollectionViewCell;
        cell.backgroundColor = .black
        cell.layer.cornerRadius = 2;
        let key = self.photoListKeys[indexPath.section];
        
        if  let collection = self.photoCollections[key]  {
            cell.image.load(url: URL(string: collection[indexPath.row].imageUrlStr!)!)
        }
        // Configure the cell
        return cell
    }
    
    func  collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PhotoHeaderCell", for:indexPath) as! PhotoCollectionReusableView;
            return headerCell;
        default:
            fatalError()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewPhotoController?.selectedIndex = indexPath;
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhoto" {
            viewPhotoController = (segue.destination as! ViewPhotoViewController);
            viewPhotoController?.photoCollectionKeys = self.photoListKeys;
            viewPhotoController?.photoCollections = self.photoCollections;
        }
    }
    
}

class AssetClickHandler: DKImagePickerControllerBaseUIDelegate {
    override func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset]) {
        //tap to select asset
        //use this place for asset selection customisation
        print("didClickAsset for selection")
    }
    
    override func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
        //tap to deselect asset
        //use this place for asset deselection customisation
        print("didClickAsset for deselection")
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

