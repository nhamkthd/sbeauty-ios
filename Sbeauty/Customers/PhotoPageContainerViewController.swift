//
//  PhotoPageContainerViewController.swift
//  FluidPhoto
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

class PhotoPageContainerViewController: UIPageViewController, UIPageViewControllerDelegate,UIPageViewControllerDataSource {

    
//    var pageViewController: UIPageViewController {
//        return self.children[0] as! UIPageViewController
//    }
//
//    var currentViewController: ViewPhotoViewController {
//        return self.pageViewController.viewControllers![0] as! ViewPhotoViewController
//    }
    
     weak var photoPageDelegate: PhotoPageViewControllerDelegate?
    
    var photos: [Photo]!
    var photosLoaded:[Int:UIImage]?;
    var selectedImage:UIImage?
    var currentIndex = 0
    var nextIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self;
        self.dataSource = self;
        
        let vc = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "ViewPhotoStoryboard") as! ViewPhotoViewController;
        vc.index = self.currentIndex
        if let image = self.photosLoaded![self.photos[self.currentIndex].id]{
            vc.image = image;
        }
        vc.photo = self.photos[self.currentIndex];
        scrollToViewController(viewController: vc);
        photoPageDelegate?.photoPageViewController(photoPageViewController: self, didUpdatePageCount: self.photos.count)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollToViewController(index newIndex: Int) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewPhoto") as! ViewPhotoViewController
        
        vc.index = newIndex;
        if let image = self.photosLoaded![self.photos[newIndex].id]{
            vc.image = image;
        }
        vc.photo = self.photos[newIndex];
        scrollToViewController(viewController: vc, direction: .forward)
    }
    
    private func scrollToViewController(viewController: UIViewController,
                                        direction: UIPageViewController.NavigationDirection = .reverse) {
           setViewControllers([viewController],
               direction: direction,
               animated: true,
               completion: { (finished) -> Void in
                   self.notifyPhotoPageDelegateOfNewIndex()
           })
       }
    private func notifyPhotoPageDelegateOfNewIndex() {
        photoPageDelegate?.photoPageViewController(photoPageViewController: self, didUpdatePageIndex: 0)
    }
  
    // MARK: Pageviewcontroller delegate and datasource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == 0 {
            return nil
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewPhoto") as! ViewPhotoViewController
        
        vc.index = self.currentIndex - 1
        if let image = self.photosLoaded![self.photos[self.currentIndex - 1].id]{
            vc.image = image;
        }
        vc.photo = self.photos[self.currentIndex - 1];
        return vc;
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if currentIndex == (self.photos.count - 1) {
            return nil
        }
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewPhoto") as! ViewPhotoViewController
        
        vc.index = self.currentIndex + 1
        if let image = self.photosLoaded![self.photos[self.currentIndex - 1].id]{
            vc.image = image;
        }
        vc.photo = self.photos[self.currentIndex + 1];
        return vc;
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
//        guard let nextVC = pendingViewControllers.first as? PhotoContainerViewController else {
//            return
//        }
        
//        self.nextIndex = nextVC.index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed && self.nextIndex != nil) {
            previousViewControllers.forEach { vc in
               
            }
            
            self.currentIndex = self.nextIndex!
            //self.delegate?.containerViewController(self, indexDidUpdate: self.currentIndex)
        }
        
        self.nextIndex = nil
    }
}

protocol PhotoPageViewControllerDelegate: class {
    
    /**
     Called when the number of pages is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter count: the total number of pages.
     */
    func photoPageViewController(photoPageViewController: PhotoPageContainerViewController,
        didUpdatePageCount count: Int)
    
    /**
     Called when the current index is updated.
     
     - parameter tutorialPageViewController: the TutorialPageViewController instance
     - parameter index: the index of the currently visible page.
     */
    func photoPageViewController(photoPageViewController: PhotoPageContainerViewController,
        didUpdatePageIndex index: Int)
    
}

