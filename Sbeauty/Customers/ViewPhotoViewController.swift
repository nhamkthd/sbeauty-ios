////
////  ViewPhotoViewController.swift
////  Sbeauty
////
////  Created by Aries on 10/13/19.
////  Copyright © 2019 Trần Nhâm. All rights reserved.
////

import UIKit
import EFImageViewZoom;
class ViewPhotoViewController: UIViewController, EFImageViewZoomDelegate {

    @IBOutlet weak var efViewZoom: EFImageViewZoom!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lable:UILabel!;

    var index:Int!;
    var photo:Photo?;
    var image:UIImage?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lable.text = self.photo?.created_at;
        efViewZoom._delegate  = self;
      
        if image != nil {
            efViewZoom.image = image;
//            self.imageView.image = image;
        }else{
            efViewZoom.imageView.load(url:URL(string: (self.photo?.image!)!)!)
//            self.imageView.load(url: URL(string: (self.photo?.image!)!)!);
        }
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
