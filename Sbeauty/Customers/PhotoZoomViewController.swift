//
//  PhotoZoomViewController.swift
//  FluidPhoto
//
//  Created by UetaMasamichi on 2016/12/23.
//  Copyright © 2016 Masmichi Ueta. All rights reserved.
//

import UIKit

protocol PhotoZoomViewControllerDelegate: class {
    func photoZoomViewController(_ photoZoomViewController: PhotoZoomViewController, scrollViewDidScroll scrollView: UIScrollView)
}

class PhotoZoomViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    weak var delegate: PhotoZoomViewControllerDelegate?
    
    var imageURL: URL!
    var image:UIImage?
    var index: Int = 0
    var isRotating: Bool = false
    var firstTimeLoaded: Bool = true
    
    var doubleTapGestureRecognizer: UITapGestureRecognizer!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapWith(gestureRecognizer:)))
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.photoScrollView.delegate = self
        if #available(iOS 11, *) {
            self.photoScrollView.contentInsetAdjustmentBehavior = .never
        }
        if self.image != nil {
            self.imageView.image = self.image;
        }else {
             self.imageView.load(url: self.imageURL)
        }
        self.imageView.frame = CGRect(x: self.imageView.frame.origin.x,
                                      y: self.imageView.frame.origin.y,
                                      width: self.imageView.image!.size.width,
                                      height: self.imageView.image!.size.height)
        self.view.addGestureRecognizer(self.doubleTapGestureRecognizer)
        
        //Update the constraints to prevent the constraints from
        //being calculated incorrectly on certain iOS devices
        self.updateConstraintsForSize(self.view.frame.size)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        updateZoomScaleForSize(view.bounds.size)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        
        //When this view's safeAreaInsets change, propagate this information
        //to the previous ViewController so the collectionView contentInsets
        //can be updated accordingly. This is necessary in order to properly
        //calculate the frame position for the dismiss (swipe down) animation
        
        if #available(iOS 11, *) {
            
//            Get the parent view controller (ViewController) from the navigation controller
            guard let parentVC = self.navigationController?.viewControllers.first as? CustomerPhotoViewController else {
                return
            }
            
            //Update the ViewController's left and right local safeAreaInset variables
            //with the safeAreaInsets for this current view. These will be used to
            //update the contentInsets of the collectionView inside ViewController
            parentVC.currentLeftSafeAreaInset = self.view.safeAreaInsets.left
            parentVC.currentRightSafeAreaInset = self.view.safeAreaInsets.right
            
        }
        
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.isRotating = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func didDoubleTapWith(gestureRecognizer: UITapGestureRecognizer) {
        let pointInView = gestureRecognizer.location(in: self.imageView)
        var newZoomScale = self.photoScrollView.maximumZoomScale
        
        if self.photoScrollView.zoomScale >= newZoomScale || abs(self.photoScrollView.zoomScale - newZoomScale) <= 0.01 {
            newZoomScale = self.photoScrollView.minimumZoomScale
        }
        
        let width = self.photoScrollView.bounds.width / newZoomScale
        let height = self.photoScrollView.bounds.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)
        
        let rectToZoomTo = CGRect(x: originX, y: originY, width: width, height: height)
        self.photoScrollView.zoom(to: rectToZoomTo, animated: true)
    }
    
    fileprivate func updateZoomScaleForSize(_ size: CGSize) {
        
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)
        photoScrollView.minimumZoomScale = minScale
        
        //scrollView.zoomScale is only updated once when
        //the view first loads and each time the device is rotated
        if self.isRotating || self.firstTimeLoaded {
            photoScrollView.zoomScale = minScale
            self.isRotating = false
            self.firstTimeLoaded = false
        }
        
        photoScrollView.maximumZoomScale = minScale * 4
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        let contentHeight = yOffset * 2 + self.imageView.frame.height
        view.layoutIfNeeded()
        self.photoScrollView.contentSize = CGSize(width: self.photoScrollView.contentSize.width, height: contentHeight)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(self.view.bounds.size)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.photoZoomViewController(self, scrollViewDidScroll: scrollView)
    }
}
