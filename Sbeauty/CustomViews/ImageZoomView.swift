//
//  ImageZoomView.swift
//  Sbeauty
//
//  Created by Trần Nhâm on 10/17/19.
//  Copyright © 2019 Trần Nhâm. All rights reserved.
//

import UIKit

class ImageZoomView: UIScrollView, UIScrollViewDelegate {

    var imageView: UIImageView!
    var gestureRecognizer: UITapGestureRecognizer!
    
    override func awakeFromNib() {
        imageView = UIImageView(frame: self.frame);
        imageView.contentMode = .scaleAspectFit;
        addSubview(imageView)
        
        setupScrollView()
        setupGestureRecognizer()
    }
    
    func setupScrollView()  {
        delegate = self;
        minimumZoomScale = 1.0
        maximumZoomScale = 2.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView;
    }
    
    // Sets up the gesture recognizer that receives double taps to auto-zoom
    func setupGestureRecognizer() {
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(gestureRecognizer)
    }
    @objc func handleDoubleTap() {
        if zoomScale == 1 {
            zoom(to: zoomRectForScale(maximumZoomScale, center: gestureRecognizer.location(in: gestureRecognizer.view)), animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
    func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }

}
