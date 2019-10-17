//
//  PhotosCollectionViewController.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/16/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit
import Foundation
import ObjectiveC
import Alamofire;
import DKImagePickerController;
import Nuke;

private let reuseIdentifier = "PhotoCell"

class PhotosCollectionViewController: UICollectionViewController,UICollectionViewDelegateFlowLayout,ImagePickerDelegate {
    
    let rest = RestManager();
    let apiDef = RestApiDefine();
    let auth = SAuthentication();
    let spinerView = SpinnerViewController();
    var imagePicke:SImagePicker!
    var customer:Customer?;
    var newAvatar:UIImage?;
    var photos:[Photo] = [];
    var photoLoaded:[Int:UIImage] = [:];
    var alert:UIAlertController?;
    var isPostPhotos:Bool = true;
    var isUploading:Bool = false;
    var selectedIndexPath:IndexPath!
    let dkimagePickerController =  DKImagePickerController();
    var lastKnowContentOfsset:CGFloat = 0;
    var exportManually = false
    
    var assets: [DKAsset]?
    var currentLeftSafeAreaInset  : CGFloat = 0.0
    var currentRightSafeAreaInset : CGFloat = 0.0
    var loadImageOptions:ImageLoadingOptions!
    deinit {
        DKImagePickerControllerResource.customLocalizationBlock = nil
        DKImagePickerControllerResource.customImageBlock = nil
        
        DKImageExtensionController.unregisterExtension(for: .camera)
        DKImageExtensionController.unregisterExtension(for: .inlineCamera)
        
        DKImageAssetExporter.sharedInstance.remove(observer: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicke = SImagePicker(presentationController: self, delegate: self)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //Define Layout here
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        //Get collectionview width
        let width = self.view.frame.width;
        
        //set section inset as per your requirement.
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        //set cell item size here
        layout.itemSize = CGSize(width: width / 3 - 12, height: 120)
        
        //set Minimum spacing between 2 items
        layout.minimumInteritemSpacing = 4
        
        //set minimum vertical line spacing here between two lines in collectionview
        layout.minimumLineSpacing = 4
//        self. = layout;
//        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        getPhots();
        loadImageOptions = ImageLoadingOptions(
            placeholder: UIImage(named: "default-thumbnail"),
            transition: .fadeIn(duration: 0.33),
            failureImage:UIImage(named: "file-not-found"),
            contentModes: nil
        )
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
                        let decoder = JSONDecoder()
                        let photoData = try! decoder.decode(PhotoData.self, from: data)
                        if let photos = photoData.data?.data {
                            self.photos = photos;
                            DispatchQueue.main.async {
                                self.removeSpiner();
                                self.collectionView.reloadData();
                            }
                        }
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
                    var index:Int = 0;
                    for image in images {
                        multipartFromData.append(image.jpegData(compressionQuality: 0.5)!, withName: "image[\(index)]",fileName: "photo_\(index)", mimeType: "image/jpeg");
                        index = index + 1;
                    }
                    
                    multipartFromData.append("\(self.customer?.id ?? 0)".data(using: .utf8)!, withName: "customer_id");
                }else {
                    multipartFromData.append(images[0].jpegData(compressionQuality: 0.5)!, withName: "image",fileName: "avatar", mimeType: "image/jpeg" );
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
                                        self.photos.removeAll();
                                        if self.isUploading == false {
                                            self.getPhots();
                                        }
                                    }else {
                                        if let url = URL(string: rest){
                                            self.rest.getData(fromURL: url, completion: {data in
                                                if let image  = UIImage(data: data!) {
                                                    DispatchQueue.main.sync {
                                                        self.newAvatar = image;
                                                        self.collectionView.reloadData();
                                                    }
                                                }
                                            })
                                        }
                                    }
                                }
                            } else  if let rest = object["message"] as? String {
                                print(rest)
                                DispatchQueue.main.async {
                                    self.dismissUploadingAlert();
                                    let alertController = UIAlertController(title: "Alert", message:rest, preferredStyle: .alert)
                                    let action1 = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
                                        print("You've pressed ok");
                                    }
                                    alertController.addAction(action1);
                                    self.present(alertController, animated: true, completion: nil)
                                }
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
    
    @objc func dismissUploadingAlert() {
        self.alert?.dismiss(animated: false, completion: nil)
        self.isUploading = false;
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoContainer" {
            let vc = segue.destination as! PhotoContainerViewController
            vc.currentIndex = self.selectedIndexPath.row
            vc.photos = self.photos;
            vc.photosLoaded = self.photoLoaded;
        }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1;
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return photos.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell;
        cell.backgroundColor = .black
        cell.layer.cornerRadius = 2;
        Nuke.loadImage(with: URL(string: self.photos[indexPath.row].image!)!, options: loadImageOptions, into: cell.imageView)
        return cell

    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PhotoHeaderCell", for: indexPath) as! PhotoCollectionReusableView
            if newAvatar != nil {
                reusableview.imageView.image = newAvatar;
            }else if self.customer?.avatar != nil && self.customer?.avatar != "" {
                Nuke.loadImage(with: URL(string: (self.customer?.avatar!)!)!, options: loadImageOptions, into: reusableview.imageView)
            }else {
                reusableview.imageView.image = UIImage(named: "default-profile");
            }
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeProfilePictureOnClick(tapGestureRecognizer:)))
            reusableview.imageView.isUserInteractionEnabled = true
             reusableview.imageView.addGestureRecognizer(tapGestureRecognizer)
           
            reusableview.nameLbl.text = self.customer?.name;
            reusableview.addressLbl.text = self.customer?.address;
            reusableview.birthdayLbl.text = self.customer?.birthday;
            reusableview.phoneLbl.text = self.customer?.phone;
            reusableview.genderLbl.text = self.customer?.gender == 1 ? "Male" : "Female";
            return reusableview
            
            
        default:  fatalError("Unexpected element kind")
        }
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "ShowPhotoContainer", sender: self)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3 - 7, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5);
    }
    
    // MARK: scrolldelegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        if scrollView.contentOffset.y > 160 {
            self.navigationItem.title = self.customer?.name;
        }else{
            self.navigationItem.title = "";
        }
    }

}

// MARK: extension classes
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
        self.image = UIImage(named: "default-thumbnail");
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
