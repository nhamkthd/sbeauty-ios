////
////  ViewPhotoViewController.swift
////  Sbeauty
////
////  Created by Aries on 10/13/19.
////  Copyright © 2019 Trần Nhâm. All rights reserved.
////

import UIKit
import Nuke;
class ViewPhotoViewController: UIViewController {

    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var imageZoomView: ImageZoomView!
    
    var index:Int!
    var photo:Photo!
    var image:UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        let options = ImageLoadingOptions(
            placeholder: UIImage(named: "default-thumbnail"),
            transition: .fadeIn(duration: 0.33),
            failureImage:UIImage(named: "file-not-found"),
            contentModes:nil
        )
        
        if image != nil {
            imageZoomView.imageView.image = image;
           
        }else {
            if let url:URL = URL(string: self.photo.image){
                Nuke.loadImage(with:url , options: options, into:imageZoomView.imageView,progress: nil, completion: {result in
                   print("load image completed")
                    DispatchQueue.main.async {
                        let imageSize = self.imageZoomView.imageView.image!.size;
                        self.imageZoomView.imageView.sizeThatFits(imageSize);
                        var imageViewCenter = self.imageZoomView.imageView.center;
                        imageViewCenter.y = CGRect(origin: self.imageZoomView.frame.origin, size: self.imageZoomView.frame.size).midY
                        self.imageZoomView.imageView.center = imageViewCenter;
                    }
                  
                })
            }

        }
        self.dateLbl.textAlignment = .center;
        self.dateLbl.text = self.photo.created_at;
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
