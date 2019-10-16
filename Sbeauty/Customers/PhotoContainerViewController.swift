//
//  PhotoContainerViewController.swift
//  Sbeauty
//
//  Created by Aries on 10/15/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class PhotoContainerViewController: UIViewController, PhotoPageViewControllerDelegate {
   
    
    var photoPageViewController: PhotoPageContainerViewController?
    
    @IBOutlet weak var pageControl: UIPageControl!
       var photos: [Photo]!
       var photosLoaded:[Int:UIImage]?;
       var selectedImage:UIImage?
      var currentIndex = 0;

    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.addTarget(self, action: Selector(("didChangePageControlValue")), for: .valueChanged)
        pageControl.currentPage = currentIndex;
        
    }
    
    func didChangePageControlValue() {
        photoPageViewController?.scrollToViewController(index: pageControl.currentPage);
       }
    
    func photoPageViewController(photoPageViewController: PhotoPageContainerViewController, didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count;
       }
       
       func photoPageViewController(photoPageViewController: PhotoPageContainerViewController, didUpdatePageIndex index: Int) {
           pageControl.currentPage = index
       }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
   
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let pageController = segue.destination as? PhotoPageContainerViewController {
            pageController.photosLoaded = self.photosLoaded;
            pageController.currentIndex = self.currentIndex;
            pageController.photos = self.photos;
            self.photoPageViewController = pageController;
            self.photoPageViewController?.photoPageDelegate = self;
        }
       }

}
