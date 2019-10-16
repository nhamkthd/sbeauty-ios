////
////  ViewPhotoViewController.swift
////  Sbeauty
////
////  Created by Aries on 10/13/19.
////  Copyright © 2019 Trần Nhâm. All rights reserved.
////

import UIKit
import EFImageViewZoom;
import Nuke;
class ViewPhotoViewController: UIViewController, EFImageViewZoomDelegate {

    @IBOutlet weak var efViewZoom: EFImageViewZoom!

    var index:Int!;
    var photo:Photo?;
    var image:UIImage?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        efViewZoom._delegate  = self;
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "default-thumbnail"),
            transition: .fadeIn(duration: 0.33)
        )
        if image != nil {
            efViewZoom.image = image;
        }else{
//            efViewZoom.imageView.load(url:URL(string: (self.photo?.image!)!)!)
            Nuke.loadImage(with: URL(string: (self.photo?.image!)!)!, options: options, into:efViewZoom.imageView)
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
