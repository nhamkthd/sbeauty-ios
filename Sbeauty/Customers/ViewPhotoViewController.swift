////
////  ViewPhotoViewController.swift
////  Sbeauty
////
////  Created by Aries on 10/13/19.
////  Copyright © 2019 Trần Nhâm. All rights reserved.
////

import UIKit

class ViewPhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lable:UILabel!;

    var index:Int!;
    var photo:Photo?;
    var image:UIImage?;

    override func viewDidLoad() {
        super.viewDidLoad()
        lable.text = self.photo?.created_at;
        if image != nil {
            
        }else{
            self.imageView.load(url: URL(string: (self.photo?.image!)!)!);
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
