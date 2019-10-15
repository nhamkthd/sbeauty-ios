//
//  PhotoPageContainerViewController.swift
//  FluidPhoto
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

protocol PhotoPageContainerViewControllerDelegate: class {
    func containerViewController(_ containerViewController: PhotoPageContainerViewController, indexDidUpdate currentIndex: Int)
}

class PhotoPageContainerViewController: UIPageViewController, UIGestureRecognizerDelegate, UIPageViewControllerDelegate,UIPageViewControllerDataSource {

    enum ScreenMode {
        case full, normal
    }
    var currentMode: ScreenMode = .normal
    
   
    
    var pageViewController: UIPageViewController {
        return self.children[0] as! UIPageViewController
    }
    
    var currentViewController: ViewPhotoViewController {
        return self.pageViewController.viewControllers![0] as! ViewPhotoViewController
    }
    
    var photos: [Photo]!
    var photosLoaded:[Int:UIImage]?;
    var selectedImage:UIImage?
    var currentIndex = 0
    var nextIndex: Int?
    
    var panGestureRecognizer: UIPanGestureRecognizer!
    var singleTapGestureRecognizer: UITapGestureRecognizer!
    
    var transitionController = ZoomTransitionController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vc = UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "ViewPhoto") as! ViewPhotoViewController;
        vc.index = self.currentIndex
        if let image = self.photosLoaded![self.photos[self.currentIndex].id]{
            vc.image = image;
        }
        vc.photo = self.photos[self.currentIndex];

        let viewControllers = [
            vc
        ]
        self.pageViewController.setViewControllers(viewControllers, direction: .forward, animated: true, completion: nil);

    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = gestureRecognizer.velocity(in: self.view)
            
            var velocityCheck : Bool = false
            
            if UIDevice.current.orientation.isLandscape {
                velocityCheck = velocity.x < 0
            }
            else {
                velocityCheck = velocity.y < 0
            }
            if velocityCheck {
                return false
            }
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
//        if otherGestureRecognizer == self.currentViewController.photoScrollView.panGestureRecognizer {
//            if self.currentViewController.photoScrollView.contentOffset.y == 0 {
//                return true
//            }
//        }
//
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didPanWith(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
//            self.currentViewController.photoScrollView.isScrollEnabled = false
            self.transitionController.isInteractive = true
            let _ = self.navigationController?.popViewController(animated: true)
        case .ended:
            if self.transitionController.isInteractive {
//                self.currentViewController.photoScrollView.isScrollEnabled = true
                self.transitionController.isInteractive = false
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        default:
            if self.transitionController.isInteractive {
                self.transitionController.didPanWith(gestureRecognizer: gestureRecognizer)
            }
        }
    }
    
    @objc func didSingleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        if self.currentMode == .full {
            changeScreenMode(to: .normal)
            self.currentMode = .normal
        } else {
            changeScreenMode(to: .full)
            self.currentMode = .full
        }

    }
    
    func changeScreenMode(to: ScreenMode) {
        if to == .full {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.view.backgroundColor = .black
                            
            }, completion: { completed in
            })
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.view.backgroundColor = .white
            }, completion: { completed in
            })
        }
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
        
        guard let nextVC = pendingViewControllers.first as? PhotoZoomViewController else {
            return
        }
        
        self.nextIndex = nextVC.index
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if (completed && self.nextIndex != nil) {
            previousViewControllers.forEach { vc in
                let zoomVC = vc as! PhotoZoomViewController
                zoomVC.photoScrollView.zoomScale = zoomVC.photoScrollView.minimumZoomScale
            }
            
            self.currentIndex = self.nextIndex!
            //self.delegate?.containerViewController(self, indexDidUpdate: self.currentIndex)
        }
        
        self.nextIndex = nil
    }
}

extension PhotoPageContainerViewController: PhotoZoomViewControllerDelegate {
    
    func photoZoomViewController(_ photoZoomViewController: PhotoZoomViewController, scrollViewDidScroll scrollView: UIScrollView) {
        if scrollView.zoomScale != scrollView.minimumZoomScale && self.currentMode != .full {
            self.changeScreenMode(to: .full)
            self.currentMode = .full
        }
    }
}

//extension PhotoPageContainerViewController: ZoomAnimatorDelegate {
//
//    func transitionWillStartWith(zoomAnimator: ZoomAnimator) {
//    }
//
//    func transitionDidEndWith(zoomAnimator: ZoomAnimator) {
//    }
//
//    func referenceImageView(for zoomAnimator: ZoomAnimator) -> UIImageView? {
//        return self.currentViewController.imageView
//    }

//    func referenceImageViewFrameInTransitioningView(for zoomAnimator: ZoomAnimator) -> CGRect? {
//        return self.currentViewController.photoScrollView.convert(self.currentViewController.imageView.frame, to: self.currentViewController.view)
//    }
//}
