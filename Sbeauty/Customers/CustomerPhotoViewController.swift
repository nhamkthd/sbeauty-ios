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
    var imagePicke:SImagePicker!
    var customer:Customer?;
    var photos:[Photo] = [];
//    var PhotoLoaded:[UIImage] = [];
    var photoListKeys:[String] = [];
    var photoCollections:[String: [Photo]] = [:];
    var alert:UIAlertController?;
    var isPostPhotos:Bool = true;
    var isUploading:Bool = false;
    var selectedIndexPath:IndexPath!
    let dkimagePickerController =  DKImagePickerController();
    
    var exportManually = false
    
    var assets: [DKAsset]?
    var currentLeftSafeAreaInset  : CGFloat = 0.0
    var currentRightSafeAreaInset : CGFloat = 0.0
    
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
                        let decoder = JSONDecoder()
                        let photoData = try! decoder.decode(PhotoData.self, from: data)
                        if let photos = photoData.data?.data {
                            self.photos = photos;
                            DispatchQueue.main.async {
                                self.removeSpiner();
                                self.photosCollectionView.reloadData();
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
                                        self.photoListKeys.removeAll();
                                        self.photoCollections.removeAll();
                                        if self.isUploading == false {
                                            self.getPhots();
                                        }
                                    }else {
                                        if let url = URL(string: rest){
                                            self.profileImage.load(url: url);
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
        return 1;
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for:indexPath) as! PhotoCollectionViewCell;
        cell.backgroundColor = .black
        cell.layer.cornerRadius = 2;
        cell.image.load(url: URL(string: photos[indexPath.row].image!)!);
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
        self.selectedIndexPath = indexPath
        self.performSegue(withIdentifier: "ShowPhotoPageView", sender: self)
    }
    
    //This function prevents the collectionView from accessing a deallocated cell. In the event
    //that the cell for the selectedIndexPath is nil, a default UIImageView is returned in its place
    func getImageViewFromCollectionViewCell(for selectedIndexPath: IndexPath) -> UIImageView {
        
        //Get the array of visible cells in the collectionView
        let visibleCells = self.photosCollectionView.indexPathsForVisibleItems
        
        //If the current indexPath is not visible in the collectionView,
        //scroll the collectionView to the cell to prevent it from returning a nil value
        if !visibleCells.contains(self.selectedIndexPath) {
           
            //Scroll the collectionView to the current selectedIndexPath which is offscreen
            self.photosCollectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
            
            //Reload the items at the newly visible indexPaths
            self.photosCollectionView.reloadItems(at: self.photosCollectionView.indexPathsForVisibleItems)
            self.photosCollectionView.layoutIfNeeded()
            
            //Guard against nil values
            guard let guardedCell = (self.photosCollectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCollectionViewCell) else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.image;
        }
        else {
            
            //Guard against nil return values
            guard let guardedCell = self.photosCollectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCollectionViewCell else {
                //Return a default UIImageView
                return UIImageView(frame: CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0))
            }
            //The PhotoCollectionViewCell was found in the collectionView, return the image
            return guardedCell.image
        }
        
    }
    //This function prevents the collectionView from accessing a deallocated cell. In the
       //event that the cell for the selectedIndexPath is nil, a default CGRect is returned in its place
       func getFrameFromCollectionViewCell(for selectedIndexPath: IndexPath) -> CGRect {
           
           //Get the currently visible cells from the collectionView
           let visibleCells = self.photosCollectionView.indexPathsForVisibleItems
           
           //If the current indexPath is not visible in the collectionView,
           //scroll the collectionView to the cell to prevent it from returning a nil value
           if !visibleCells.contains(self.selectedIndexPath) {
               
               //Scroll the collectionView to the cell that is currently offscreen
               self.photosCollectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
               
               //Reload the items at the newly visible indexPaths
               self.photosCollectionView.reloadItems(at: self.photosCollectionView.indexPathsForVisibleItems)
               self.photosCollectionView.layoutIfNeeded()
               
               //Prevent the collectionView from returning a nil value
               guard let guardedCell = (self.photosCollectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCollectionViewCell) else {
                   return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
               }
               
               return guardedCell.frame
           }
           //Otherwise the cell should be visible
           else {
               //Prevent the collectionView from returning a nil value
               guard let guardedCell = (self.photosCollectionView.cellForItem(at: self.selectedIndexPath) as? PhotoCollectionViewCell) else {
                   return CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 100.0, height: 100.0)
               }
               //The cell was found successfully
               return guardedCell.frame
           }
       }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoPageView" {
            let nav = self.navigationController
            let vc = segue.destination as! PhotoPageContainerViewController
            nav?.delegate = vc.transitionController
            vc.transitionController.fromDelegate = self
            vc.transitionController.toDelegate = vc
            vc.delegate = self
            vc.currentIndex = self.selectedIndexPath.row
//            print(self.selectedIndexPath);
            vc.photos = self.photos;
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

extension CustomerPhotoViewController: PhotoPageContainerViewControllerDelegate {
 
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int) {
        self.selectedIndexPath = IndexPath(row: currentIndex, section: 0)
        self.photosCollectionView.scrollToItem(at: self.selectedIndexPath, at: .centeredVertically, animated: false)
    }
}

extension CustomerPhotoViewController: ZoomAnimatorDelegate {
    
    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
        
    }
    
    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
        let cell = self.photosCollectionView.cellForItem(at: self.selectedIndexPath) as! PhotoCollectionViewCell
        
        let cellFrame = self.photosCollectionView.convert(cell.frame, to: self.view)
        
        if cellFrame.minY < self.photosCollectionView.contentInset.top {
            self.photosCollectionView.scrollToItem(at: self.selectedIndexPath, at: .top, animated: false)
        } else if cellFrame.maxY > self.view.frame.height - self.photosCollectionView.contentInset.bottom {
            self.photosCollectionView.scrollToItem(at: self.selectedIndexPath, at: .bottom, animated: false)
        }
    }
    
    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
        
        //Get a guarded reference to the cell's UIImageView
        let referenceImageView = getImageViewFromCollectionViewCell(for: self.selectedIndexPath)
        
        return referenceImageView
    }
    
    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
        
        self.view.layoutIfNeeded()
        self.photosCollectionView.layoutIfNeeded()
        
        //Get a guarded reference to the cell's frame
        let unconvertedFrame = getFrameFromCollectionViewCell(for: self.selectedIndexPath)
        
        let cellFrame = self.photosCollectionView.convert(unconvertedFrame, to: self.view)
        
        if cellFrame.minY < self.photosCollectionView.contentInset.top {
            return CGRect(x: cellFrame.minX, y: self.photosCollectionView.contentInset.top, width: cellFrame.width, height: cellFrame.height - (self.photosCollectionView.contentInset.top - cellFrame.minY))
        }
        
        return cellFrame
    }
    
}
