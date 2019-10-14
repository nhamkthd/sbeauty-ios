////
////  ViewPhotoViewController.swift
////  Sbeauty
////
////  Created by Aries on 10/13/19.
////  Copyright © 2019 Trần Nhâm. All rights reserved.
////
//
//import UIKit
//
//class ViewPhotoViewController: UIViewController {
//
//    @IBOutlet weak var image: UIImageView!
//    @IBOutlet weak var lable:UILabel!;
//
//    var selectedIndex:IndexPath!;
//    var photos:[Photo] = [];
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        //load views
//        setPhotoView(selectedIndex: selectedIndex);
//
//        //reegister swipe action
//        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
//        leftSwipe.direction = .left
//        rightSwipe.direction = .right
//        view.addGestureRecognizer(leftSwipe)
//        view.addGestureRecognizer(rightSwipe)
//
//        //resgitser zoom photo action
//        image.isUserInteractionEnabled = true
//        let pinchMethod = UIPinchGestureRecognizer(target: self, action: #selector(pinchImage(sender:)))
//        image.addGestureRecognizer(pinchMethod)
//        // Do any additional setup after loading the view.
//    }
//
////    func setPhotoView(selectedIndex:IndexPath) {
////        lable.text = photoCollectionKeys[selectedIndex.section];
////        let key = self.photoCollectionKeys[selectedIndex.section];
////
////        if  let collection = self.photoCollections[key]  {
////            self.image.load(url: URL(string: collection[selectedIndex.row].imageUrlStr!)!);
////        }
////    }
//
//    @objc func pinchImage(sender: UIPinchGestureRecognizer) {
//        if let scale = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)) {
//            guard scale.a > 1.0 else { return }
//            guard scale.d > 1.0 else { return }
//            sender.view?.transform = scale
//            sender.scale = 1.0
//        }
//    }
//
//    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer){
//
//        switch sender.direction {
//        case .right:
//            if selectedIndex.row > 0 {
//                selectedIndex = IndexPath(row: selectedIndex.row - 1, section: selectedIndex.section);
//            }else if selectedIndex.section > 0{
//                selectedIndex = IndexPath(row: 0, section: selectedIndex.section - 1)
//            }else {
//                selectedIndex = IndexPath(row: self.photoCollections[self.photoCollectionKeys[selectedIndex.section]]!.count - 1, section: self.photoCollectionKeys.count - 1 )
//            }
//            break;
//        case .left:
//            if selectedIndex.row < self.photoCollections[self.photoCollectionKeys[selectedIndex.section]]!.count - 1 {
//                selectedIndex = IndexPath(row: selectedIndex.row + 1, section: selectedIndex.section);
//            }else if selectedIndex.section < self.photoCollectionKeys.count - 1{
//                selectedIndex = IndexPath(row: 0, section: selectedIndex.section + 1)
//            }else {
//                selectedIndex = IndexPath(row: 0, section: 0)
//            }
//            break;
//        default:
//            break;
//        }
//        self.setPhotoView(selectedIndex: selectedIndex);
//    }
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
